import UIKit
import PhotosUI
import UniformTypeIdentifiers

class LivePhotoViewController: UIViewController, PHPickerViewControllerDelegate {

    // 用于显示 Live Photo 的视图
    private var livePhotoView: PHLivePhotoView!
    // 用于存储分解后的图片和视频的 URL
    var photoURL: URL?
    var videoURL: URL?
    
    // 用于显示分解后的图片
    private var imageView: UIImageView!
    // 用于播放分解后的视频
    private var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLivePhotoView() // 设置 Live Photo 视图
        setupUI() // 设置用户界面
    }

    // 设置用户界面，包括选择按钮和网络按钮
    private func setupUI() {
        let selectButton = UIButton(type: .system)
        selectButton.setTitle("选择Live Photo", for: .normal)
        selectButton.addTarget(self, action: #selector(selectLivePhoto), for: .touchUpInside)
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectButton)

        let networkButton = UIButton(type: .system)
        networkButton.setTitle("网络Live Photo", for: .normal)
        networkButton.addTarget(self, action: #selector(openNetworkLivePhoto), for: .touchUpInside)
        networkButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(networkButton)

        let createButton = UIButton(type: .system)
        createButton.setTitle("创建Live Photo", for: .normal)
        createButton.addTarget(self, action: #selector(openCreateLivePhotoVC), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)

        NSLayoutConstraint.activate([
            selectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            
            networkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            networkButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),

            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    // 设置 Live Photo 视图和其他视图的布局
    private func setupLivePhotoView() {
        livePhotoView = PHLivePhotoView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 0.5))
        livePhotoView.contentMode = .scaleAspectFill
        livePhotoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(livePhotoView)

        imageView = UIImageView()
        imageView.backgroundColor = .cyan
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        videoView = UIView()
        videoView.backgroundColor = .orange
        videoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoView)

        NSLayoutConstraint.activate([
            livePhotoView.topAnchor.constraint(equalTo: view.topAnchor),
            livePhotoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            livePhotoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            livePhotoView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),

            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),

            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            videoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            videoView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25)
        ])
    }
    
    /// 使用自定义方法分解 Live Photo
    /// 这个方法从 PHLivePhoto 中提取资源，并将其保存到临时目录中
    /// 然后将提取的图片显示在 imageView 中，并播放提取的视频
    private func disassembleLivePhotoCustom() {
        // 确保 livePhotoView 中有 Live Photo
        guard let livePhoto = self.livePhotoView.livePhoto else {
            return
        }

        // 获取 Live Photo 的资源
        let assetResources = PHAssetResource.assetResources(for: livePhoto)
        let group = DispatchGroup() // 用于同步多个异步任务
        var keyPhotoURL: URL?
        var videoURL: URL?

        // 遍历资源，提取数据
        for resource in assetResources {
            let buffer = NSMutableData()
            let options = PHAssetResourceRequestOptions()
            options.isNetworkAccessAllowed = true
            group.enter() // 进入任务组
            PHAssetResourceManager.default().requestData(for: resource, options: options, dataReceivedHandler: { (data) in
                buffer.append(data) // 收集数据
            }) { (error) in
                if error == nil {
                    // 获取文件扩展名
                    if let fileExtension = UTType(resource.uniformTypeIdentifier)?.preferredFilenameExtension {
                        let fileName = UUID().uuidString
                        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
                        
                        do {
                            try buffer.write(to: fileURL) // 将数据写入文件
                            if resource.type == .pairedVideo {
                                videoURL = fileURL // 保存视频 URL
                            } else {
                                keyPhotoURL = fileURL // 保存图片 URL
                            }
                        } catch {
                            print("保存资源失败: \(error.localizedDescription)")
                        }
                    }
                } else {
                    print("请求资源失败: \(error?.localizedDescription ?? "未知错误")")
                }
                group.leave() // 离开任务组
            }
        }

        // 当所有资源提取完成后，更新 UI
        group.notify(queue: DispatchQueue.main) {
            self.photoURL = keyPhotoURL
            self.videoURL = videoURL

            print("self.photoURL = \(String(describing: self.photoURL))")
            print("self.videoURL = \(String(describing: self.videoURL))")

            if let keyPhotoPath = self.photoURL {
                if FileManager.default.fileExists(atPath: keyPhotoPath.path) {
                    guard let keyPhotoImage = UIImage(contentsOfFile: keyPhotoPath.path) else {
                        return
                    }
                    self.imageView.image = keyPhotoImage // 显示图片
                }
            }
            if let pairedVideoPath = self.videoURL?.path {
                if FileManager.default.fileExists(atPath: pairedVideoPath) {
                    let fileURL = URL(fileURLWithPath: pairedVideoPath)
                    self.playVideo(fileURL) // 播放视频
                }
            }
        }
    }

    /// 使用 LivePhoto.swift 分解 Live Photo
    /// 这个方法使用 LivePhoto.swift 中的 extractResources 方法来提取资源
    private func disassembleLivePhotoUsingLibrary() {
        guard let livePhoto = self.livePhotoView.livePhoto else {
            return
        }
        
        LivePhoto.extractResources(from: livePhoto) { resources in
            self.photoURL = resources?.pairedImage
            self.videoURL = resources?.pairedVideo
            
            print("self.photoURL = \(String(describing: self.photoURL))")
            print("self.videoURL = \(String(describing: self.videoURL))")

            DispatchQueue.main.async {
                if let keyPhotoPath = self.photoURL {
                    if FileManager.default.fileExists(atPath: keyPhotoPath.path) {
                        guard let keyPhotoImage = UIImage(contentsOfFile: keyPhotoPath.path) else {
                            return
                        }
                        self.imageView.image = keyPhotoImage
                    }
                }
                if let pairedVideoPath = self.videoURL?.path {
                    if FileManager.default.fileExists(atPath: pairedVideoPath) {
                        let fileURL = URL(fileURLWithPath: pairedVideoPath)
                        self.playVideo(fileURL)
                    }
                }
            }
        }
    }

    // 播放视频的方法
    private func playVideo(_ url: URL) {
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        player.play()
    }

    // 选择 Live Photo 的方法
    @objc private func selectLivePhoto() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .livePhotos
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    // 打开网络 Live Photo 的方法
    @objc private func openNetworkLivePhoto() {
        let networkVC = NetworkLivePhotoViewController()
        present(networkVC, animated: true, completion: nil)
    }

    // 打开创建 Live Photo 的视图控制器
    @objc private func openCreateLivePhotoVC() {
        let createVC = CreateLivePhotoViewController()
        present(createVC, animated: true, completion: nil)
    }

    // 处理选择结果的方法
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: PHLivePhoto.self) { [weak self] (livePhoto, error) in
            if let livePhoto = livePhoto as? PHLivePhoto {
                DispatchQueue.main.async {
                    self?.livePhotoView.livePhoto = livePhoto
                    // 使用自定义方法分解
                    self?.disassembleLivePhotoCustom()
                    // 或者使用库方法分解
                    // self?.disassembleLivePhotoUsingLibrary()
                }
            }
        }
    }
}
