//
//  RoundedLabel.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 11/08/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

class RoundedLabel: UILabel {
    
    override func awakeFromNib() {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2
        self.clipsToBounds = true
        self.backgroundColor = .clear
        self.textColor = .black
    }
}
