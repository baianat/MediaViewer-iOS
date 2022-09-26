//
//  InteractiveImageView.swift
//  Nuke
//
//  Created by Omar on 2/24/21.
//

import Foundation
class InteractiveImageView: UIImageView {
    
    private var scaleFactor: CGFloat = 0.8
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 1.0
            UIView.animate(withDuration: 0.15,
                           delay: 0.0,
                           options: .curveLinear,
                           animations: {
                self.transform = CGAffineTransform.init(scaleX: self.scaleFactor, y: self.scaleFactor)
            }, completion: nil)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15,
                           delay: 0.0,
                           options: .curveLinear,
                           animations: {
                self.transform = .identity
            }, completion: nil)
        }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.15,
                           delay: 0.0,
                           options: .curveLinear,
                           animations: {
                self.transform = .identity
            }, completion: nil)
        }
    }
    
}
