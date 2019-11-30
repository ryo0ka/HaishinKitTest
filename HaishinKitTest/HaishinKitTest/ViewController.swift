//
//  ViewController.swift
//  HaishinKitTest
//
//  Created by Ryoichiro Oka on 11/30/19.
//  Copyright © 2019 Ryoichiro Oka. All rights reserved.
//

import UIKit
import HaishinKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet private weak var lfView: GLHKView!
    
    private var rtmpConnection = RTMPConnection()
    private var rtmpStream: RTMPStream!
    
    let streamAddress = "rtmp://172.20.10.4/live"
    let streamKey = "stream"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        rtmpStream = RTMPStream(connection: rtmpConnection)
        
        rtmpStream.captureSettings = [
            .sessionPreset: AVCaptureSession.Preset.hd1280x720,
            .continuousAutofocus: true,
            .continuousExposure: true
            // .preferredVideoStabilizationMode: AVCaptureVideoStabilizationMode.auto
        ]
        
        rtmpStream.videoSettings = [
            .width: 720,
            .height: 1280
        ]
        
        rtmpStream.audioSettings = [
            .sampleRate: 44_100
        ]
        
        rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpConnection.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
        rtmpConnection.connect(streamAddress)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        rtmpStream.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
            debugPrint(error.description)
        }
        
        rtmpStream.attachCamera(DeviceUtil.device(withPosition: .back)) { error in
            debugPrint(error.description)
        }
        
        lfView?.attachStream(rtmpStream)
    }
    
    @objc private func rtmpStatusHandler(_ notification: Notification) {
        let e = Event.from(notification)
        guard let data: ASObject = e.data as? ASObject, let code: String = data["code"] as? String else {
            return
        }
        
        switch code {
        case RTMPConnection.Code.connectSuccess.rawValue:
            rtmpStream!.play(streamKey)
            debugPrint("success")
        case RTMPConnection.Code.connectFailed.rawValue:
            debugPrint("failed")
        case RTMPConnection.Code.connectClosed.rawValue:
            debugPrint("closed")
        default:
            break
        }
    }
    
    @objc private func rtmpErrorHandler(_ notification: Notification) {
        let e = Event.from(notification)
        debugPrint("rtmpErrorHandler: \(e)")
    }
}

