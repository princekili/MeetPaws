//
//  ProfileTabsCollectionReusableView.swift
//  Yogogo
//
//  Created by prince on 2020/12/2.
//

import UIKit

protocol ProfileTabsCollectionReusableViewDelegate: AnyObject {
    
    func gridButtonDidTap()
    func listButtonDidTap()
}

class MyProfileTabsCollectionReusableView: UICollectionReusableView {
        
    static let identifier = "ProfileTabsCollectionReusableView"
    
    weak var delegate: ProfileTabsCollectionReusableViewDelegate?
    
    struct Constants {
        static let padding: CGFloat = 12
    }
    
    private let gridButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.tintColor = .label
        button.setBackgroundImage(UIImage(systemName: "rectangle.split.3x3"), for: .normal)
        return button
    }()
    
    private let listButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.tintColor = .lightGray
        button.setBackgroundImage(UIImage(systemName: "heart.text.square"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        addSubview(gridButton)
        addSubview(listButton)
        
        gridButton.addTarget(self,
                             action: #selector(gridButtonDidTap),
                             for: .touchUpInside)
        
        listButton.addTarget(self,
                             action: #selector(listButtonDidTap),
                             for: .touchUpInside)
    }
    
    @objc private func gridButtonDidTap() {
        gridButton.tintColor = .label
        listButton.tintColor = .lightGray
        delegate?.gridButtonDidTap()
    }
    
    @objc private func listButtonDidTap() {
        gridButton.tintColor = .lightGray
        listButton.tintColor = .label
        delegate?.listButtonDidTap()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = height - (Constants.padding * 2)
        let gridButtonX = ((width/2) - size) / 2
        
        gridButton.frame = CGRect(x: gridButtonX,
                                  y: Constants.padding,
                                  width: size,
                                  height: size)
        
        listButton.frame = CGRect(x: gridButtonX + (width/2),
                                  y: Constants.padding,
                                  width: size,
                                  height: size)
    }
}
