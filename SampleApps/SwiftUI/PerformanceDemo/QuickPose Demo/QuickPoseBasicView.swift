//
//  QuickPose_BasicDemoApp.swift
//  QuickPose Demo
//
//  Created by QuickPose.ai on 12/12/2022.
//

import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI

struct QuickPoseBasicView: View {

    private var quickPose = QuickPose(sdkKey: "01GS5J4JEQQZDZZB0EYSE974BV") // register for your free key at https://dev.quickpose.ai
    @State private var overlayImage: UIImage?
    @State private var frameRate: Double? = nil
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if false, ProcessInfo.processInfo.isiOSAppOnMac, let url = Bundle.main.url(forResource: "happy-dance", withExtension: "mov") {
                    QuickPoseSimulatedCameraView(useFrontCamera: true, delegate: quickPose, video: url)
                } else {
                    QuickPoseCameraView(useFrontCamera: true, delegate: quickPose, frameRate: $frameRate)
                }
                QuickPoseOverlayView(overlayImage: $overlayImage)
            }
            .frame(width: geometry.size.width)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                let modelConfig = QuickPose.ModelConfig(detailedFaceTracking: false, detailedHandTracking: false, modelComplexity: .light) // 14.48% faster than defaults
                quickPose.start(features: [.showPoints()], onFrame: { status, image, features, feedback, landmarks in
                    overlayImage = image
                    if case .success(let fps, let latency) = status {
                        print(fps, latency)
                    } else {
                        // show error feedback
                    }
                })
            }.onDisappear {
                quickPose.stop()
            }
            .overlay(alignment: .bottom) {
                Text("Powered by QuickPose.ai v\(quickPose.quickPoseVersion())") // remove logo here, but attribution appreciated
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                    .frame(maxHeight:  40 + geometry.safeAreaInsets.bottom, alignment: .center)
                    .padding(.bottom, 0)
            }
        }
    }
}

