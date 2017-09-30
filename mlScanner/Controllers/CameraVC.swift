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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    


}

