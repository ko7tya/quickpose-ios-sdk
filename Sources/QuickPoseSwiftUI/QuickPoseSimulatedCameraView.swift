//
//  QuickPoseSimulatedCameraView.swift
//
//
//  Created by QuickPose.ai on 12/01/2023.
//

import Foundation
import SwiftUI
import AVFoundation

#if targetEnvironment(simulator)

#else
#if QUICKPOSECORE
#else
import QuickPoseCore
import QuickPoseCamera
#endif
#endif

public protocol MockQuickPoseCaptureAVAssetOutputSampleBufferDelegate: AnyObject {
    func captureAVOutput(didOutput: CVPixelBuffer, timestamp: CMTime, isFrontCamera: Bool)
}

#if targetEnvironment(simulator)
public typealias QuickPoseDelegate = MockQuickPoseCaptureAVAssetOutputSampleBufferDelegate
#else
public typealias QuickPoseDelegate = QuickPoseCaptureAVAssetOutputSampleBufferDelegate
#endif

#if targetEnvironment(simulator)
typealias Camera = QuickPoseSimulatedCameraMock
#else
typealias Camera = QuickPoseSimulatedCamera
#endif

struct QuickPoseSimulatedCameraMock {

    var player: AVPlayer?

    init(useFrontCamera: Bool, asset: AVAsset, onVideoLoop: (()->())?) {
        fatalError("Not supported by simulator")
    }

    func stop() {
        fatalError("Not supported by simulator")
    }

    func start(delegate: QuickPoseDelegate?) throws {
        fatalError("Not supported by simulator")
    }
}

public struct QuickPoseSimulatedCameraView: View {

    let delegate: QuickPoseDelegate?
    let videoGravity: AVLayerVideoGravity
    @State var cameraReady: Bool = false
    @State var camera: Camera? = nil

    public init(useFrontCamera: Bool, delegate: QuickPoseDelegate?, video: URL,  onVideoLoop: (()->())? = nil, videoGravity: AVLayerVideoGravity = .resizeAspectFill) {
        self.camera = Camera(useFrontCamera: useFrontCamera, asset: AVAsset(url: video), onVideoLoop: onVideoLoop)
        self.delegate = delegate
        self.videoGravity = videoGravity
    }

    public var body: some View {
        ZStack(alignment: .top) {
            if cameraReady, let avAssetPlayer = camera?.player {
                QuickPoseAssetRenderView(player: avAssetPlayer, videoGravity: videoGravity)
            } else {
                EmptyView()
            }
        }.onAppear {
            do {
                try camera?.start(delegate: delegate)
                cameraReady = true
                
            } catch let error {
                print(error)
            }
        }.onDisappear(){
            camera?.stop()
        }
    }
}
