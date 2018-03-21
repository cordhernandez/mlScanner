//
//  ViewController.swift
//  mlScanner
//
//  Created by Cordero Hernandez on 9/29/17.
//  Copyright © 2017 Cordero Hernandez. All rights reserved.
//

import Archeota
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
        
        configurePreviewLayer()
    }
    
    @IBAction func flashButtonTapped(_ sender: Any) {
        
        manageFlashState()
    }
    
    fileprivate func manageFlashState() {
        
        switch flashControlState {
            
        case .off:
            flashButton.setTitle("FLASH ON", for: .normal)
            flashControlState = .on
            
        case .on:
            flashButton.setTitle("FLASH OFF", for: .normal)
            flashControlState = .off
        }
    }
    
    fileprivate func configurePreviewLayer() {
        
        previewLayer.frame = cameraView.bounds
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
                let previewLayer = addPreviewLayer(withLayer: self.previewLayer, andFrom: captureSession)
                
                cameraView.layer.addSublayer(previewLayer)
                cameraView.addGestureRecognizer(tap)
                
                captureSession.startRunning()
            }
        }
        catch {
            LOG.error("Error trying to capture device input from camera, error description: \(error.localizedDescription)")
        }
    }
    
    fileprivate func addPreviewLayer(withLayer layer: AVCaptureVideoPreviewLayer, andFrom session: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        
        var previewLayer = layer
        let captureSession = session
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer.connection?.videoOrientation = .portrait
        
        return previewLayer
    }
    
    @objc fileprivate func didTapCameraView() {
        
        self.cameraView.isUserInteractionEnabled = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        let settings = setSettingsFlashMode()
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    fileprivate func setSettingsFlashMode() -> AVCapturePhotoSettings {
        
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        
        if flashControlState == .off {
            
            settings.flashMode = .off
        }
        else {
            settings.flashMode = .on
        }
        
        return settings
    }
    
    func synthesizeSpeech(fromString string: String) {
        
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynthesizer.speak(speechUtterance)
    }
}

//MARK: AVCapturePhoto Delegate Methods
extension CameraVC: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            
            debugPrint("Error Processing Photo, error description: \(error.localizedDescription)")
            return
        }
        
        photoData = photo.fileDataRepresentation()
        
        do {
            let model = try VNCoreMLModel(for: SqueezeNet().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                
                self.getCoreMLRequest(from: request, and: error)
                } as? VNRequestCompletionHandler)
            
            let handler = VNImageRequestHandler(data: photoData ?? Data())
            try handler.perform([request])
        }
        catch {
            LOG.error("Error with Core Ml Model, error description: \(error.localizedDescription)")
        }
        
        let photoImage = UIImage(data: photoData ?? Data())
        self.thumbnailCameraImage.image = photoImage
    }
    
    func getCoreMLRequest(from request: VNRequest, and withError: NSError?) {
        
        if let error = withError {
            
            LOG.error("Error getting request from Core Ml Model, error description: \(error.localizedDescription)")
            return
        }
        
        guard let results = request.results as? [VNClassificationObservation] else {
            
            LOG.warn("Can't retreive request results from VNRequest")
            return
        }
        
        for classification in results {
            
            if classification.confidence < 0.5 {
                
                let message = "I'm sorry I don't know what this is. Please try again."
                lowConfidenceMessage(message)
                
                break
            }
            else {
                let identification = classification.identifier
                let confidence = Int(classification.confidence * 100)
                highConfidenceMessage(identification, confidence)
                
                break
            }
        }
    }
    
    func lowConfidenceMessage(_ message: String) {
        
        self.identificationLabel.text = message
        self.synthesizeSpeech(fromString: message)
        self.confidentLabel.isHidden = true
    }
    
    func highConfidenceMessage(_ message: String, _ confidence: Int) {
        
        self.identificationLabel.text = message
        self.confidentLabel.text = "CONFIDENCE: \(confidence)%"
        
        let completeSentence = "This looks like a \(message) and I'm \(confidence) percent sure!"
        self.synthesizeSpeech(fromString: completeSentence)
    }
}

//MARK: AV Speech Synthesizer Delegate Methods
extension CameraVC: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
        self.cameraView.isUserInteractionEnabled = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
}


