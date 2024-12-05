//
//  QRCodeScannerViewController.swift
//  二维码扫描探索
//
//  Created by 彭祖鑫 on 2024/12/5.
//

import UIKit
import AVFoundation

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // 捕获会话
    var captureSession: AVCaptureSession!
    // 预览层
    var previewLayer: AVCaptureVideoPreviewLayer!
    // 当前焦距
    var currentZoomFactor: CGFloat = 1.0

    deinit {
        print("deinit QRCodeScannerViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        captureSession = AVCaptureSession()

        // 获取后置摄像头
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showError(message: "设备不支持摄像头")
            return
        }

        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showError(message: "无法访问摄像头")
            return
        }

        // 添加输入设备
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showError(message: "无法添加摄像头输入")
            return
        }

        // 添加元数据输出
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            showError(message: "无法添加元数据输出")
            return
        }

        // 配置预览层
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // 添加双击手势
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)

        // 开始捕获
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 停止会话
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    // 处理双击手势
    @objc func handleDoubleTap() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            try videoCaptureDevice.lockForConfiguration()
            defer { videoCaptureDevice.unlockForConfiguration() }

            // 目标焦距
            let targetZoomFactor: CGFloat = (videoCaptureDevice.videoZoomFactor == 1.0) ? 4.0 : 1.0
            let duration: TimeInterval = 0.3 // 动画时长

            // 平滑调整焦距
            smoothZoom(for: videoCaptureDevice, to: targetZoomFactor, duration: duration)
        } catch {
            print("无法调整焦距: \(error)")
        }
    }

    func smoothZoom(for device: AVCaptureDevice, to targetZoomFactor: CGFloat, duration: TimeInterval) {
        let steps = Int(duration * 60) // 假设60帧动画
        let initialZoomFactor = device.videoZoomFactor
        let zoomStep = (targetZoomFactor - initialZoomFactor) / CGFloat(steps)

        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * (1.0 / 60.0)) {
                do {
                    try device.lockForConfiguration()
                    device.videoZoomFactor = min(max(initialZoomFactor + CGFloat(step) * zoomStep, 1.0), device.activeFormat.videoMaxZoomFactor)
                    device.unlockForConfiguration()
                } catch {
                    print("无法调整焦距: \(error)")
                }
            }
        }
    }

    // 处理捕获的元数据
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            showResult(message: stringValue)
        }
    }

    // 显示结果
    func showResult(message: String) {
        let alert = UIAlertController(title: "扫描结果", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    // 错误提示
    func showError(message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}


