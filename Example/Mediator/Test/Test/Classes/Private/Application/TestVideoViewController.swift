//
//  TestVideoViewController.swift
//  Example
//
//  Created by wuyong on 2020/6/5.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import FWApplication

class TestPlayerView: VideoPlayerView, VideoPlayerDelegate {
    static func videoPlayer() -> VideoPlayer {
        let result = VideoPlayer()
        result.modalPresentationStyle = .fullScreen
        let playerView = TestPlayerView(frame: .zero)
        playerView.videoPlayer = result
        result.playerView = playerView
        return result
    }
    
    weak var videoPlayer: VideoPlayer? {
        didSet {
            videoPlayer?.playerDelegate = self
        }
    }
    
    private lazy var closeButton: ToolbarButton = {
        let result = ToolbarButton(image: Icon.closeImage)
        result.tintColor = Theme.textColor
        result.fw.addTouch { sender in
            Router.closeViewController(animated: true)
        }
        return result
    }()
    
    private lazy var playButton: ToolbarButton = {
        let result = ToolbarButton(image: FW.iconImage("octicon-playback-play", 24))
        result.tintColor = Theme.textColor
        result.fw.addTouch { [weak self] sender in
            guard let player = self?.videoPlayer else { return }
            
            if player.playbackState == .playing {
                player.pause()
            } else if player.playbackState == .paused {
                player.playFromCurrentTime()
            } else {
                player.playFromBeginning()
            }
        }
        return result
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.backgroundColor
        
        addSubview(closeButton)
        addSubview(playButton)
        closeButton.fw.layoutChain.left(toSafeArea: 8).top(toSafeArea: 8)
        playButton.fw.layoutChain.right(toSafeArea: 8).top(toSafeArea: 8)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playerPlaybackStateDidChange(_ player: VideoPlayer) {
        if player.playbackState == .playing {
            playButton.setImage(FW.iconImage("octicon-playback-pause", 24), for: .normal)
        } else {
            playButton.setImage(FW.iconImage("octicon-playback-play", 24), for: .normal)
        }
    }
}

@objcMembers class TestVideoViewController: TestViewController, VideoPlayerDelegate, VideoPlayerPlaybackDelegate {
    fileprivate var player = VideoPlayer()
    lazy var resourceLoader = PlayerCacheLoaderManager()
    
    @UserDefaultAnnotation("TestVideoCacheEnabled", defaultValue: false)
    private var cacheEnabled: Bool
    
    // MARK: object lifecycle
    deinit {
        self.player.willMove(toParent: nil)
        self.player.view.removeFromSuperview()
        self.player.removeFromParent()
    }

    // MARK: view lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.player.playerDelegate = self
        self.player.playbackDelegate = self
        
        self.player.playerView.playerBackgroundColor = Theme.backgroundColor
        
        self.addChild(self.player)
        self.view.addSubview(self.player.view)
        self.player.view.fw.pinEdges()
        self.player.didMove(toParent: self)
        
        self.playVideo()
        self.player.playbackLoops = true
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)
        
        __fw.showLoading()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !fw.isLoaded {
            fw.isLoaded = true
            self.player.playFromBeginning()
        }
    }
    
    override func renderModel() {
        fw.setRightBarItem(cacheEnabled ? "禁用缓存" : "启用缓存") { [weak self] sender in
            guard let strongSelf = self else { return }
            strongSelf.cacheEnabled = !strongSelf.cacheEnabled
            strongSelf.playVideo()
            strongSelf.renderModel()
        }
    }
    
    private func playVideo() {
        let videoUrl = URL(string: "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4")!
        if cacheEnabled {
            self.player.asset = resourceLoader.urlAsset(with: videoUrl)
        } else {
            self.player.url = videoUrl
        }
    }
    
    // MARK: -
    
    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        switch self.player.playbackState {
        case .stopped:
            self.player.playFromBeginning()
            break
        case .paused:
            self.player.playFromCurrentTime()
            break
        case .playing:
            self.player.pause()
            break
        case .failed:
            self.player.pause()
            break
        }
    }
    
    func playerReady(_ player: VideoPlayer) {
        print("\(#function) ready")
        
        __fw.hideLoading()
    }
    
    func playerPlaybackStateDidChange(_ player: VideoPlayer) {
        print("\(#function) \(player.playbackState.rawValue)")
    }
    
    func player(_ player: VideoPlayer, didFailWithError error: Error?) {
        print("\(#function) error.description")
        
        __fw.hideLoading()
    }
}
