//
//  TouchExtensionButton.swift
//  ImageSearch
//
//  Created by ChAe on 12/11/2018.
//  Copyright © 2018 ChAe. All rights reserved.
//

import UIKit

@IBDesignable
class TouchExtensionButton: UIButton {
    @IBInspectable var extensionTop: CGFloat = 0
    @IBInspectable var extensionBottom: CGFloat = 0
    @IBInspectable var extensionLeft: CGFloat = 0
    @IBInspectable var extensionRight: CGFloat = 0
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchRect = self.bounds.inset(by: UIEdgeInsets(top: -self.extensionTop,
                                                           left: -self.extensionLeft,
                                                           bottom: -self.extensionBottom,
                                                           right: -self.extensionRight))
        
        if touchRect.contains(point) {
            return self
        }
        
        return super.hitTest(point, with: event)
    }
}
