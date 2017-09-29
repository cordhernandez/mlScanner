//
//  RoundedShadowImage.swift
//  mlScanner
//
//  Created by Cordero Hernandez on 9/29/17.
//  Copyright © 2017 Cordero Hernandez. All rights reserved.
//

import UIKit

class RoundedShadowImage: UIImageView {
    
    override func awakeFromNib() {
        
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = 20
    }

}
