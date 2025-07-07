//
//  AnimatedButton.swift
//  Example
//
//  Created by Stas ProSky on 07.07.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import UIKit

class AnimatedButton: UIButton {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.backgroundColor = .colorPrimary
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 6,
                       options: .allowUserInteraction, animations: {
            self.backgroundColor = .colorAccent
        }, completion: nil)
        
        super.touchesBegan(touches, with: event)
    }

}
