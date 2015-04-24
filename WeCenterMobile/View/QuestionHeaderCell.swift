//
//  QuestionHeaderCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/2.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class QuestionHeaderCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSignatureLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userButton.msr_setBackgroundImageWithColor(UIColor.whiteColor(), forState: .Highlighted)
    }
    
    func update(#user: User?, updateImage: Bool) {
        if updateImage {
            userAvatarView.wc_updateWithUser(user)
        }
        userNameLabel.text = user?.name ?? "匿名用户"
        userSignatureLabel.text = user?.signature ?? ""
        userButton.msr_userInfo = user
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
