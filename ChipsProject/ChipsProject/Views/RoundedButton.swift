//
//  RoundedButton.swift
//
//  Created by Mateusz Zacharski on 03/08/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    
    override func awakeFromNib() {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 4
        self.clipsToBounds = true
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.backgroundColor = .systemYellow
        self.setTitleColor(.black, for: .normal)
        self.titleLabel?.numberOfLines = 2
        self.isExclusiveTouch = true
        
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        self.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        self.addTarget(self, action: #selector(buttonCancel), for: .touchDragExit)
        self.addTarget(self, action: #selector(buttonDragInside), for: .touchDragInside)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 30, options: [], animations: {
            sender.transform = .identity
        })
    }
    
    @objc func buttonDown(_ sender: UIButton) {
       UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 30, options: [], animations: {
        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
       })
    }
    
    @objc func buttonCancel(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 30, options: [], animations: {
            sender.transform = .identity
        })
    }
    
    @objc func buttonDragInside(_ sender: UIButton) {
       UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 30, options: [], animations: {
        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
       })
    }
    
}
