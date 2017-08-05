//
//  UIImageViewX.swift
//  whatsThat
//
//  Created by Olteanu Andrei on 04/08/2017.
//  Copyright © 2017 Olteanu Andrei. All rights reserved.
//

import UIKit

class UIImageViewX: UIImageView {
    
    override func awakeFromNib() {
        
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
    }
    
    @IBInspectable var cornerRadius: CGFloat = 30.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    func setupView() {
        layer.cornerRadius = cornerRadius
    }
}
