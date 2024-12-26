//
//  NetworkLivePhotoViewController.swift
//  LivePhotoDemo
//
//  Created by 彭祖鑫 on 2024/12/25.
//

import UIKit
import PhotosUI

class NetworkLivePhotoViewController: UIViewController {

    private var livePhotoView: PHLivePhotoView!
    private var imageURL: URL?
    private var videoURL: URL?
    private var activityIndicator: UIActivityIndicatorView! // 加载指示器，用于显示下载进度

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI() // 设置用户界面
        setupLivePhotoView() // 设置 Live Photo 视图
        setupActivityIndicator() // 设置加载指示器
    }

    private func setupUI() {
        // 添加提示标签
        let infoLabel = UILabel()
        infoLabel.text = "下载的图片和视频放在GitHub上，如果网络不好需要挂VPN，也可以替换成自己的可以用的图片视频地址。"
        infoLabel.font = UIFont.systemFont(ofSize: 12)
        infoLabel.textColor = .gray
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)

        // 添加加载按钮
        let loadButton = UIButton(type: .system)
        loadButton.setTitle("加载网络Live Photo", for: .normal)
        loadButton.addTarget(self, action: #selector(loadLivePhotoFromURL), for: .touchUpInside)
        loadButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadButton)

        // 设置布局约束
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            loadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func setupLivePhotoView() {
        // 初始化并配置 Live Photo 视图
        livePhotoView = PHLivePhotoView(frame: view.bounds)
        livePhotoView.contentMode = .scaleAspectFit
        livePhotoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(livePhotoView)

        // 设置 Live Photo 视图的布局约束
        NSLayoutConstraint.activate([
            livePhotoView.topAnchor.constraint(equalTo: view.topAnchor),
            livePhotoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            livePhotoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            livePhotoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        ])
    }

    private func setupActivityIndicator() {
        // 初始化并配置加载指示器
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true // 停止时隐藏
        view.addSubview(activityIndicator)
    }

    @objc private func loadLivePhotoFromURL() {
        activityIndicator.startAnimating() // 开始加载动画

        // 定义视频和图片的 URL
        let videoURL = URL(string: "https://github.com/PZXforXcode/PZXTooLTest/raw/refs/heads/main/2FA4E0D1-B471-462F-9B4D-21171FB49ED2.MOV")!
        let photoURL = URL(string: "https://github.com/PZXforXcode/PZXTooLTest/raw/refs/heads/main/IMG_1667.HEIC")!

        // 下载文件
        downloadFiles(videoURL: videoURL, photoURL: photoURL) { [weak self] videoFileURL, photoFileURL in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating() // 停止加载动画

                guard let videoFileURL = videoFileURL, let photoFileURL = photoFileURL else {
                    print("下载失败")
                    return
                }
                
                print("photoFileURL = \(photoFileURL)")
                print("videoFileURL = \(videoFileURL)")

                self?.imageURL = photoFileURL
                self?.videoURL = videoFileURL
                self?.createLivePhotoUsingLibrary() // 使用下载的文件生成 Live Photo
            }
        }
    }
    
    // 使用 LivePhoto.swift 生成 Live Photo
    @objc private func createLivePhotoUsingLibrary() {
        guard let imageURL = imageURL, let videoURL = videoURL else {
            print("请先选择图片和视频")
            return
        }
        
        // 生成 Live Photo
        LivePhoto.generate(from: imageURL, videoURL: videoURL, progress: { progress in
            print("生成进度: \(progress)")
        }) { [weak self] livePhoto, resources in
            if let livePhoto = livePhoto {
                print("Live Photo 生成成功")
                DispatchQueue.main.async {
                    self?.livePhotoView.livePhoto = livePhoto
                    self?.livePhotoView.startPlayback(with: .full)
                }
            } else {
                print("Live Photo 生成失败")
            }
        }
    }

    private func downloadFiles(videoURL: URL, photoURL: URL, completion: @escaping (URL?, URL?) -> Void) {
        let downloadGroup = DispatchGroup()
        var videoFileURL: URL?
        var photoFileURL: URL?

        // 下载视频文件
        downloadGroup.enter()
        downloadFile(from: videoURL) { url in
            videoFileURL = url
            if let url = url {
                print("Video downloaded to: \(url)")
            } else {
                print("Failed to download video.")
            }
            downloadGroup.leave()
        }

        // 下载图片文件
        downloadGroup.enter()
        downloadFile(from: photoURL) { url in
            photoFileURL = url
            if let url = url {
                print("Photo downloaded to: \(url)")
            } else {
                print("Failed to download photo.")
            }
            downloadGroup.leave()
        }

        // 下载完成后调用
        downloadGroup.notify(queue: .main) {
            completion(videoFileURL, photoFileURL)
        }
    }

    private func downloadFile(from url: URL, completion: @escaping (URL?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let localURL = localURL else {
                completion(nil)
                return
            }
            
            // 获取文件扩展名
            let fileExtension = url.pathExtension
            // 创建目标 URL
            let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(fileExtension)
            
            do {
                // 移动文件到目标 URL
                try FileManager.default.moveItem(at: localURL, to: destinationURL)
                completion(destinationURL)
            } catch {
                print("文件移动失败: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }
}
