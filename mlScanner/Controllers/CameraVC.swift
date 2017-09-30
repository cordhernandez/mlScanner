//
//  ViewController.swift
//  mlScanner
//
//  Created by Cordero Hernandez on 9/29/17.
//  Copyright © 2017 Cordero Hernandez. All rights reserved.
//

import AVFoundation
import CoreML
import UIKit
import Vision

enum FlashState {
    case off
    case on
}

class CameraVC: UIViewController {
    
    @IBOutlet var identificationLabel: UILabel!
    @IBOutlet var confidentLabel: UILabel!
    @IBOutlet var roundedLabelView: RoundedShadowView!
    @IBOutlet var flashButton: RoundedShadowButton!
    @IBOutlet var cameraView: UIView!
    @IBOutlet var thumbnailCameraImage: RoundedShadowImage!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?
    var flashControlState: FlashState = .off
    var speechSynthesizer = AVSpeechSynthesizer()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechSynthesizer.delegate = self
        activityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureCaptureSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        previewLayer.frame = cameraView.bounds
    }
    
    @IBAction func flashButtonTapped(_ sender: Any) {
        
        switch flashControlState {
            
        case .off:
            flashButton.setTitle("FLASH ON", for: .normal)
            flashControlState = .on
            
        case .on:
            flashButton.setTitle("FLASH OFF", for: .normal)
            flashControlState = .off
        }
    }
    
    fileprivate func configureCaptureSession() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            
            cameraOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(cameraOutput) == true {
                captureSession.addOutput(cameraOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer.connection?.videoOrientation = .portrait
                
                cameraView.layer.addSublayer(previewLayer)
                cameraView.addGestureRecognizer(tap)
                captureSession.startRunning()
            }
        }
        catch {
            debugPrint("Error trying to capture device input from camera, error description: \(error)")
        }
    }
    
    @objc fileprivate func didTapCameraView() {
        
        self.cameraView.isUserInteractionEnabled = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        
        if flashControlState == .off {
            
            settings.flashMode = .off
        }
        else {
            settings.flashMode = .on
        }
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }

    


//MARK: AV Speech Synthesizer Delegate Methods
extension CameraVC: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
        self.cameraView.isUserInteractionEnabled = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    
}

