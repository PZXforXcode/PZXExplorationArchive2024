import UIKit
import PhotosUI
import AVFoundation
import ImageIO
import MobileCoreServices

class CreateLivePhotoViewController: UIViewController, PHPickerViewControllerDelegate {

    private var imageURL: URL?
    private var videoURL: URL?
    
    private var imageView: UIImageView!
    private var videoView: UIView!
    private var livePhotoView: PHLivePhotoView!
    
    // 自定义 Live Photo 资源类型
    private struct CustomLivePhotoResources {
        let pairedImage: URL
        let pairedVideo: URL
    }
    
    private var customLivePhotoResources: CustomLivePhotoResources?
    // 保留库方法的资源变量
    private var livePhotoResources: LivePhoto.LivePhotoResources?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    // 设置用户界面
    private func setupUI() {
        // 初始化并配置 imageView
        imageView = UIImageView()
        imageView.backgroundColor = .cyan
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        // 初始化并配置 videoView
        videoView = UIView()
        videoView.backgroundColor = .orange
        videoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoView)

        // 初始化并配置 livePhotoView
        livePhotoView = PHLivePhotoView()
        livePhotoView.contentMode = .scaleAspectFill
        livePhotoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(livePhotoView)

        // 初始化并配置选择图片按钮
        let selectImageButton = UIButton(type: .system)
        selectImageButton.setTitle("选择图片", for: .normal)
        selectImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        selectImageButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectImageButton)

        // 初始化并配置选择视频按钮
        let selectVideoButton = UIButton(type: .system)
        selectVideoButton.setTitle("选择视频", for: .normal)
        selectVideoButton.addTarget(self, action: #selector(selectVideo), for: .touchUpInside)
        selectVideoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectVideoButton)

        // 初始化并配置生成 Live Photo 按钮
        let createLivePhotoButton = UIButton(type: .system)
        createLivePhotoButton.setTitle("生成Live Photo", for: .normal)
        createLivePhotoButton.addTarget(self, action: #selector(createLivePhotoCustom), for: .touchUpInside)
        createLivePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createLivePhotoButton)

        // 初始化并配置保存 Live Photo 按钮
        let saveLivePhotoButton = UIButton(type: .system)
        saveLivePhotoButton.setTitle("保存Live Photo", for: .normal)
        saveLivePhotoButton.addTarget(self, action: #selector(saveLivePhotoCustom), for: .touchUpInside)
        saveLivePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveLivePhotoButton)

        // 设置布局约束
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),

            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            videoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            videoView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),

            livePhotoView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            livePhotoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            livePhotoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            livePhotoView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),

            selectImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -140),
            
            selectVideoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectVideoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            
            createLivePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createLivePhotoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),

            saveLivePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveLivePhotoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // 选择图片
    @objc private func selectImage() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    // 选择视频
    @objc private func selectVideo() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    // 自定义生成 Live Photo
    @objc private func createLivePhotoCustom() {
        guard let imageURL = imageURL, let videoURL = videoURL else {
            print("请先选择图片和视频")
            return
        }
        
        // 生成 Live Photo 的逻辑
        let assetIdentifier = UUID().uuidString
        guard let pairedImageURL = addAssetID(assetIdentifier, toImage: imageURL) else {
            print("无法为图片添加 Asset ID")
            return
        }
        
        // 为视频添加 Asset ID 并在完成后生成 Live Photo
        addAssetID(assetIdentifier, toVideo: videoURL) { [weak self] pairedVideoURL in
            guard let pairedVideoURL = pairedVideoURL else {
                print("无法为视频添加 Asset ID")
                return
            }
            
            // 请求生成 Live Photo
            PHLivePhoto.request(withResourceFileURLs: [pairedImageURL, pairedVideoURL], placeholderImage: nil, targetSize: CGSize.zero, contentMode: .aspectFit) { livePhoto, info in
                if let livePhoto = livePhoto {
                    DispatchQueue.main.async {
                        self?.livePhotoView.livePhoto = livePhoto
                        self?.livePhotoView.startPlayback(with: .full)
                        self?.customLivePhotoResources = CustomLivePhotoResources(pairedImage: pairedImageURL, pairedVideo: pairedVideoURL)
                        print("自定义 Live Photo 生成成功")
                    }
                } else {
                    print("自定义 Live Photo 生成失败")
                }
            }
        }
    }
    
    // 使用 LivePhoto.swift 生成 Live Photo
    @objc private func createLivePhotoUsingLibrary() {
        guard let imageURL = imageURL, let videoURL = videoURL else {
            print("请先选择图片和视频")
            return
        }
        
        LivePhoto.generate(from: imageURL, videoURL: videoURL, progress: { progress in
            print("生成进度: \(progress)")
        }) { [weak self] livePhoto, resources in
            if let livePhoto = livePhoto {
                print("Live Photo 生成成功")
                DispatchQueue.main.async {
                    self?.livePhotoView.livePhoto = livePhoto
                    self?.livePhotoView.startPlayback(with: .full)
                    self?.livePhotoResources = resources
                }
            } else {
                print("Live Photo 生成失败")
            }
        }
    }
    
    // 自定义保存 Live Photo
    @objc private func saveLivePhotoCustom() {
        guard let resources = customLivePhotoResources else {
            print("没有可保存的 Live Photo")
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            creationRequest.addResource(with: .pairedVideo, fileURL: resources.pairedVideo, options: options)
            creationRequest.addResource(with: .photo, fileURL: resources.pairedImage, options: options)
        }) { success, error in
            if success {
                print("自定义 Live Photo 保存成功")
            } else {
                print("自定义 Live Photo 保存失败: \(String(describing: error))")
            }
        }
    }
    
    // 使用 LivePhoto.swift 保存 Live Photo
    @objc private func saveLivePhotoUsingLibrary() {
        guard let resources = livePhotoResources else {
            print("没有可保存的 Live Photo")
            return
        }
        
        LivePhoto.saveToLibrary(resources) { success in
            if success {
                print("Live Photo 保存成功")
            } else {
                print("Live Photo 保存失败")
            }
        }
    }
    
    // 添加 Asset ID 到图片
    private func addAssetID(_ assetIdentifier: String, toImage imageURL: URL) -> URL? {
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        guard let imageDestination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypeJPEG, 1, nil),
              let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
              let imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, nil),
              var imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [AnyHashable: Any] else {
            return nil
        }
        
        // 添加 Asset ID 到图片的元数据
        let assetIdentifierKey = "17"
        let assetIdentifierInfo = [assetIdentifierKey: assetIdentifier]
        imageProperties[kCGImagePropertyMakerAppleDictionary] = assetIdentifierInfo
        CGImageDestinationAddImage(imageDestination, imageRef, imageProperties as CFDictionary)
        CGImageDestinationFinalize(imageDestination)
        
        return destinationURL
    }
    
    // 添加 Asset ID 到视频
    private func addAssetID(_ assetIdentifier: String, toVideo videoURL: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVURLAsset(url: videoURL)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
        
        do {
            let assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
            let assetReader = try AVAssetReader(asset: asset)
            
            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                completion(nil)
                return
            }
            
            let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: nil)
            assetReader.add(readerOutput)
            
            let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: nil)
            assetWriter.add(writerInput)
            
            let metadataAdaptor = createMetadataAdaptorForStillImageTime()
            assetWriter.metadata = [metadataForAssetID(assetIdentifier)]
            assetWriter.add(metadataAdaptor.assetWriterInput)
            
            assetWriter.startWriting()
            assetReader.startReading()
            assetWriter.startSession(atSourceTime: .zero)
            
            let group = DispatchGroup()
            group.enter()
            
            writerInput.requestMediaDataWhenReady(on: DispatchQueue(label: "videoQueue")) {
                while writerInput.isReadyForMoreMediaData {
                    if let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                        writerInput.append(sampleBuffer)
                    } else {
                        writerInput.markAsFinished()
                        group.leave()
                        break
                    }
                }
            }
            
            group.notify(queue: .main) {
                assetWriter.finishWriting {
                    if assetWriter.status == .completed {
                        print("视频写入成功")
                        completion(outputURL)
                    } else {
                        print("视频写入失败: \(String(describing: assetWriter.error))")
                        completion(nil)
                    }
                }
            }
        } catch {
            print("视频处理失败: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    // 创建元数据适配器
    private func createMetadataAdaptorForStillImageTime() -> AVAssetWriterInputMetadataAdaptor {
        let spec: NSDictionary = [
            kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier as NSString: "mdta/com.apple.quicktime.still-image-time",
            kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType as NSString: "com.apple.metadata.datatype.int8"
        ]
        
        var desc: CMFormatDescription? = nil
        CMMetadataFormatDescriptionCreateWithMetadataSpecifications(allocator: kCFAllocatorDefault, metadataType: kCMMetadataFormatType_Boxed, metadataSpecifications: [spec] as CFArray, formatDescriptionOut: &desc)
        
        let input = AVAssetWriterInput(mediaType: .metadata, outputSettings: nil, sourceFormatHint: desc)
        return AVAssetWriterInputMetadataAdaptor(assetWriterInput: input)
    }
    
    // 创建元数据项
    private func metadataForAssetID(_ assetIdentifier: String) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = "com.apple.quicktime.content.identifier" as (NSCopying & NSObjectProtocol)?
        item.keySpace = AVMetadataKeySpace.quickTimeMetadata
        item.value = assetIdentifier as (NSCopying & NSObjectProtocol)?
        item.dataType = "com.apple.metadata.datatype.UTF-8"
        return item
    }
    
    // 处理选择结果
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        guard let result = results.first else { return }

        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] (url, error) in
            if let url = url {
                self?.imageURL = self?.copyFileToDocumentsDirectory(from: url)
                DispatchQueue.main.async {
                    if let imagePath = self?.imageURL?.path {
                        self?.imageView.image = UIImage(contentsOfFile: imagePath)
                    }
                }
                print("图片选择成功: \(String(describing: self?.imageURL))")
            }
        }
        
        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] (url, error) in
            if let url = url {
                self?.videoURL = self?.copyFileToDocumentsDirectory(from: url)
                DispatchQueue.main.async {
                    if let videoPath = self?.videoURL {
                        self?.playVideo(videoPath)
                    }
                }
                print("视频选择成功: \(String(describing: self?.videoURL))")
            }
        }
    }
    
    // 播放视频的方法
    private func playVideo(_ url: URL) {
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        videoView.layer.sublayers?.forEach { $0.removeFromSuperlayer() } // 移除旧的图层
        videoView.layer.addSublayer(playerLayer)
        player.play()
    }
    
    // 将文件复制到文档目录
    private func copyFileToDocumentsDirectory(from url: URL) -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: url, to: destinationURL)
            return destinationURL
        } catch {
            print("文件复制失败: \(error.localizedDescription)")
            return nil
        }
    }
} 
