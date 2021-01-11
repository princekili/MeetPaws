//
//  ProgressHUD + Wrapper.swift
//  Insdogram
//
//  Created by prince on 2021/1/8.
//

import Foundation
import ProgressHUD

class WrapperProgressHUD {
    
    static func showLoading() {
        ProgressHUD.colorStatus = .systemGray
        ProgressHUD.colorAnimation = .lightGray
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.show("Loading...", interaction: false)
    }
    
    static func showSuccess() {
        ProgressHUD.colorAnimation = .lightGray
        ProgressHUD.showSucceed()
    }
    
    static func dismiss() { ProgressHUD.dismiss() }
    
    static func showHeart() {
        ProgressHUD.colorStatus = .systemGray
        ProgressHUD.colorAnimation = UIColor.systemRed
        ProgressHUD.show(icon: .heart, interaction: false)
    }
    
    static func removeHeart() {
        ProgressHUD.colorStatus = .systemGray
        ProgressHUD.colorAnimation = .lightGray
        ProgressHUD.show(icon: .heart, interaction: false)
    }
    
    static func showFailed(with text: String) {
        ProgressHUD.colorStatus = .systemGray
        ProgressHUD.colorAnimation = .lightGray
        ProgressHUD.showFailed(text, interaction: false)
    }
}
