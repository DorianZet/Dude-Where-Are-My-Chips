//
//  HandStateLabel.swift
//  ChipsProject
//
//  Created by Mateusz Zacharski on 24/10/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

class HandStateLabel: UILabel {
    override func awakeFromNib() {
        self.textAlignment = .center
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)))
    }
    

}
