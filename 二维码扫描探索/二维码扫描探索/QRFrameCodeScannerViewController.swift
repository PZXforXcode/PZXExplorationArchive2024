//
//  QRCodeScannerViewController.swift
//  二维码扫描探索
//
//  Created by 彭祖鑫 on 2024/12/5.
//

import UIKit
import AVFoundation

class QRFrameCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    // 捕获会话
    var captureSession: AVCaptureSession!
    // 预览层
    var previewLayer: AVCaptureVideoPreviewLayer!
    // 扫描框
    var scanFrameView: UIView!

    deinit {
        print("deinit QRFrameCodeScannerViewController")
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

        // 添加扫描框
        setupScanFrame()

        // 设置扫描区域
        let scanRect = self.scanFrameView.frame
        let scanRectConverted = self.previewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)
        metadataOutput.rectOfInterest = scanRectConverted

        // 开始捕获会话（放到后台线程中）
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 停止会话
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    // 添加扫描框
    private func setupScanFrame() {
        let frameSize: CGFloat = 200
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height

        scanFrameView = UIView()
        scanFrameView.frame = CGRect(
            x: (screenWidth - frameSize) / 2,
            y: (screenHeight - frameSize) / 2,
            width: frameSize,
            height: frameSize
        )
        scanFrameView.layer.borderColor = UIColor.green.cgColor
        scanFrameView.layer.borderWidth = 2
        scanFrameView.backgroundColor = UIColor.clear
        view.addSubview(scanFrameView)
    }

    // 处理捕获的元数据
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }

            // 转换二维码位置到视图坐标
            if let qrCodeObject = previewLayer.transformedMetadataObject(for: readableObject) {
                if scanFrameView.frame.contains(qrCodeObject.bounds) {
                    captureSession.stopRunning()
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    showResult(message: readableObject.stringValue ?? "未识别的二维码")
                    print(readableObject.stringValue ?? "未识别的二维码")

                }
            }
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
