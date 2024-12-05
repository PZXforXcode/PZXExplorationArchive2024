import UIKit
import AVFoundation

class DualCameraPreviewViewController: UIViewController {
    var multiCamSession: AVCaptureMultiCamSession!
    var frontPreviewLayer: AVCaptureVideoPreviewLayer!
    var backPreviewLayer: AVCaptureVideoPreviewLayer!
    var frontPhotoOutput: AVCapturePhotoOutput!
    var backPhotoOutput: AVCapturePhotoOutput!
    
    var frontCapturedImage: UIImage?
    var backCapturedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        // 检查是否支持 AVCaptureMultiCamSession
        guard AVCaptureMultiCamSession.isMultiCamSupported else {
            print("该设备不支持多摄像头会话")
            return
        }
        // 异步设置摄像头会话，避免阻塞主线程
//            DispatchQueue.global(qos: .userInitiated).async {
//                self.setupSession()
//                DispatchQueue.main.async {
//                    self.setupPreviewLayers()
//                }
//            }
        self.setupSession()
        self.setupPreviewLayers()
            setupCaptureButton()

      
    }
    override func viewIsAppearing(_ animated: Bool) {

        //
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)


        multiCamSession.startRunning()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        multiCamSession.stopRunning()
        multiCamSession = nil

    }
    func setupSession() {
        multiCamSession = AVCaptureMultiCamSession()
        multiCamSession.beginConfiguration()
        
        // 配置前摄像头
        if let frontDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ),
           let frontInput = try? AVCaptureDeviceInput(device: frontDevice),
           multiCamSession.canAddInput(frontInput) {
            multiCamSession.addInput(frontInput)
            
            frontPhotoOutput = AVCapturePhotoOutput()
            if multiCamSession.canAddOutput(frontPhotoOutput) {
                multiCamSession.addOutput(frontPhotoOutput)
            }
        }
        
        // 配置后摄像头
        if let backDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ),
           let backInput = try? AVCaptureDeviceInput(device: backDevice),
           multiCamSession.canAddInput(backInput) {
            multiCamSession.addInput(backInput)
            
            backPhotoOutput = AVCapturePhotoOutput()
            if multiCamSession.canAddOutput(backPhotoOutput) {
                multiCamSession.addOutput(backPhotoOutput)
            }
        }
        
        multiCamSession.commitConfiguration()
    }
    
    func setupPreviewLayers() {

        // 创建前摄像头预览层
        frontPreviewLayer = AVCaptureVideoPreviewLayer(session: multiCamSession)
        frontPreviewLayer.videoGravity = .resizeAspectFill
        
        // 设置前置摄像头的预览层大小与位置：左上角，竖直长方形，距离左边和上边20的边距，手机比例竖向（9:16）
        let frontWidth = view.frame.width * 0.45
        let frontHeight = frontWidth * 16 / 9  // 按9:16的比例
        frontPreviewLayer.frame = CGRect(
            x: 20,
            y: 20,
            width: frontWidth,
            height: frontHeight
        )
        
        // 创建后摄像头预览层
        backPreviewLayer = AVCaptureVideoPreviewLayer(session: multiCamSession)
        backPreviewLayer.videoGravity = .resizeAspectFill
        
        // 设置后置摄像头的预览层：全屏，铺满底部
        backPreviewLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: view.frame.height
        )
        
        view.layer.addSublayer(backPreviewLayer)
        view.layer.addSublayer(frontPreviewLayer)
    }
    
    // 拍照并合成图片
    func capturePhotoAndCombine() {
        // 创建捕捉前置摄像头图像
        let photoSettingsFront = AVCapturePhotoSettings()
        frontPhotoOutput.capturePhoto(with: photoSettingsFront, delegate: self)
        
        // 创建捕捉后置摄像头图像
        let photoSettingsBack = AVCapturePhotoSettings()
        backPhotoOutput.capturePhoto(with: photoSettingsBack, delegate: self)
    }
    
    // 设置拍照按钮
    func setupCaptureButton() {
        let captureButton = UIButton(type: .system)
        captureButton.frame = CGRect(
            x: (view.frame.width - 120) / 2,
            y: view.frame.height - 120,
            width: 120,
            height: 50
        )
        captureButton.setTitle("Capture", for: .normal)
        captureButton.backgroundColor = .systemBlue
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.layer.cornerRadius = 10
        captureButton
            .addTarget(
                self,
                action: #selector(captureButtonTapped),
                for: .touchUpInside
            )
        
        view.addSubview(captureButton)
    }
    
    // 按钮点击事件
    @objc func captureButtonTapped() {
        capturePhotoAndCombine()
    }
}

// 扩展实现 AVCapturePhotoCaptureDelegate 协议
extension DualCameraPreviewViewController: AVCapturePhotoCaptureDelegate {
    
    // 处理拍照完成后的回调
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let photoData = photo.fileDataRepresentation() else {
            print("No photo data available")
            return
        }
        
        // 将捕获的图片转为 UIImage
        let capturedImage = UIImage(data: photoData)
        
        // 使用 DispatchGroup 等待两张图像都捕获完成
        let dispatchGroup = DispatchGroup()
        
        // 判断是前置还是后置摄像头捕获的图像
        if output == frontPhotoOutput {
            dispatchGroup.enter()
            let flippedImage = capturedImage?.withHorizontallyFlippedOrientation()
            // 如果前置摄像头图像是上下颠倒的，进行旋转调整
            frontCapturedImage = flippedImage?.rotate(radians: .pi) // 将图像旋转180度
            dispatchGroup.leave()
        } else if output == backPhotoOutput {
            dispatchGroup.enter()
            backCapturedImage = capturedImage
            dispatchGroup.leave()
        }
        
        // 等待两个图像都捕获完成
        dispatchGroup.notify(queue: .main) {
            // 两张图片都捕获完成后，进行合成
            self.combineImages()
        }
    }
    
    // 合成前后摄像头的图片
    func combineImages() {
        guard let frontImage = frontCapturedImage, let backImage = backCapturedImage else {
            print("Error: one of the images is nil")
            return
        }
        
        // 获取前后摄像头的图片的尺寸
        let frontWidth = view.frame.width * 0.45
        let frontHeight = frontWidth * 16 / 9
        let backWidth = view.frame.width
        let backHeight = view.frame.height
        
        // 开始合成图像
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        
        // 将后置摄像头图像绘制为背景
        backImage
            .draw(in: CGRect(x: 0, y: 0, width: backWidth, height: backHeight))
        
        // 将前置摄像头图像绘制到左上角
        frontImage
            .draw(
                in: CGRect(x: 20, y: 20, width: frontWidth, height: frontHeight)
            )
        
        // 获取合成后的图像
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 保存合成图片
        if let combinedImage = combinedImage {
            UIImageWriteToSavedPhotosAlbum(combinedImage, nil, nil, nil)
            
            // 如果你希望显示合成图片
            let imageView = UIImageView(image: combinedImage)
            imageView.frame = view.bounds
            view.addSubview(imageView)
        }
    }
}


extension UIImage {
    // 用于旋转图像的方法
    func rotate(radians: CGFloat) -> UIImage? {
        var newSize: CGSize
        // 如果图像方向是 `.left` 或 `.right`，需要交换宽高
        if self.imageOrientation == .left || self.imageOrientation == .right {
            newSize = CGSize(width: self.size.height, height: self.size.width)
        } else {
            newSize = self.size
        }
        
        // 创建图形上下文
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        
        // 将上下文平移到中心
        context?.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        // 旋转上下文
        context?.rotate(by: radians)
        // 绘制图像到上下文中
        self.draw(
            in: CGRect(
                x: -self.size.width / 2,
                y: -self.size.height / 2,
                width: self.size.width,
                height: self.size.height
            )
        )
        
        // 获取旋转后的图像
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
}

