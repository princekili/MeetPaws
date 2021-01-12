//
//  UILabel + Extension.swift
//  MeetPaws
//
//  Created by prince on 2020/12/1.
//

import UIKit

extension UILabel {
    
    var textCount: Int {
        
        return countLabelLines()
    }
    
    func countLabelLines() -> Int {
        
            // Call self.layoutIfNeeded() if your view uses auto layout
            let myText = self.text! as NSString
        
            let rect = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        
            let labelSize = myText.boundingRect(
                with: rect,
                options: .usesLineFragmentOrigin,
                attributes: [NSAttributedString.Key.font: self.font!],
                context: nil
            )
        
            return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
        }
}
