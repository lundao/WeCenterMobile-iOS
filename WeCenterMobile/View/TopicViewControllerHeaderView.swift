//
//  TopicViewControllerHeaderView.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/12.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class TopicViewControllerHeaderView: UIView {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    lazy var backButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(named: "Arrow-Left")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        v.tintColor = UIColor.whiteColor()
        return v
    }()
    
    lazy var topicImageView: MSRRoundedImageView = {
        let v = MSRRoundedImageView(image: defaultTopicImage)
        return v
    }()
    
    lazy var topicTitleLabel: UILabel = {
        let v = UILabel()
        v.textColor = UIColor.whiteColor()
        v.font = UIFont.systemFontOfSize(17)
        return v
    }()
    
    lazy var topicDescriptionLabel: UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        v.textColor = UIColor.lightTextColor()
        v.font = UIFont.systemFontOfSize(15)
        return v
    }()
    
    lazy var focusButton: UIButton = {
        [weak self] in
        let v = UIButton()
        v.titleLabel!.font = UIFont.systemFontOfSize(14)
        v.frame.size = CGSize(width: 55, height: 24)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 3
        v.addSubview(self!.focusButtonActivityIndicatorView)
        self!.focusButtonActivityIndicatorView.msr_addAllEdgeAttachedConstraintsToSuperview()
        return v
    }()
    
    lazy var focusButtonActivityIndicatorView: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        v.stopAnimating()
        v.hidesWhenStopped = true
        v.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
        v.contentScaleFactor = 0.5
        return v
    }()
    
    var maxHeight: CGFloat = 150
    var minHeight: CGFloat = 64
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(backButton)
        addSubview(topicImageView)
        addSubview(topicTitleLabel)
        addSubview(topicDescriptionLabel)
        addSubview(focusButton)
        msr_shouldTranslateAutoresizingMaskIntoConstraints = false
    }
    
    func update(#topic: Topic) {
        topicImageView.wc_updateWithTopic(topic)
        backgroundImageView.wc_updateWithTopic(topic)
        topicTitleLabel.text = topic.title ?? "加载中……"
        topicTitleLabel.sizeToFit()
        topicDescriptionLabel.text = topic.introduction ?? ""
        topicDescriptionLabel.sizeToFit()
        if let focused = topic.focused {
            focusButtonActivityIndicatorView.stopAnimating()
            focusButtonActivityIndicatorView.color = focused ? UIColor.msr_materialGray900() : UIColor.lightTextColor()
            focusButton.setTitle(focused ? "已关注" : "关注", forState: .Normal)
            focusButton.setBackgroundImage(UIImage.msr_imageWithColor(focused ? UIColor.lightTextColor() : UIColor.clearColor()), forState: .Normal)
            focusButton.setTitleColor(focused ? UIColor.msr_materialGray900() : UIColor.lightTextColor(), forState: .Normal)
            focusButton.layer.borderWidth = focused ? 0 : 1
            focusButton.layer.borderColor = UIColor.lightTextColor().CGColor
        } else {
            focusButtonActivityIndicatorView.startAnimating()
            focusButton.setTitle("", forState: .Normal)
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let topicImageViewBeginSize = CGSize(width: 32, height: 32)
        let topicImageViewEndSize = CGSize(width: 80, height: 80)
        let titleBeginWidth = topicImageViewBeginSize.width + 10 + topicTitleLabel.bounds.width
        let backButtonBeginFrame = CGRect(x: 10, y: 20, width: 30, height: minHeight - 20)
        var backButtonEndFrame = CGRect(x: 10, y: 20, width: 30, height: maxHeight - 20)
        let topicImageViewBeginFrame = CGRect(origin: CGPoint(x: bounds.msr_center.x - titleBeginWidth / 2, y: backButtonBeginFrame.msr_center.y - topicImageViewBeginSize.height / 2), size: topicImageViewBeginSize)
        var topicImageViewEndFrame = CGRect(origin: CGPoint(x: backButtonEndFrame.msr_right + 10, y: backButtonEndFrame.msr_center.y - topicImageViewEndSize.height / 2), size: topicImageViewEndSize)
        let topicTitleLabelBeginFrame = CGRect(origin: CGPoint(x: topicImageViewBeginFrame.msr_right + 10, y: topicImageViewBeginFrame.msr_center.y - topicTitleLabel.bounds.height / 2), size: topicTitleLabel.bounds.size)
        var topicTitleLabelEndFrame = CGRect(origin: CGPoint(x: topicImageViewEndFrame.msr_right + 15, y: topicImageViewEndFrame.msr_top), size: topicTitleLabel.bounds.size)
        let focusButtonBeginFrame = CGRect(origin: CGPoint(x: bounds.width - 10 - focusButton.bounds.width, y: backButtonBeginFrame.msr_center.y - focusButton.bounds.height / 2), size: focusButton.bounds.size)
        var focusButtonEndFrame = CGRect(origin: CGPoint(x: bounds.width - 10 - focusButton.bounds.width, y: topicTitleLabelEndFrame.msr_center.y - focusButton.bounds.height / 2), size: focusButton.bounds.size)
        let progress = Double((max(bounds.height, minHeight) - minHeight) / (maxHeight - minHeight))
        backgroundImageView.alpha = CGFloat(max(0, progress * 2 - 1))
        topicDescriptionLabel.alpha = CGFloat(max(0, progress * 2 - 1))
        if progress <= 1 {
            backButton.frame = MSRLinearInterpolation(backButtonBeginFrame, backButtonEndFrame, progress)
            topicImageView.frame = MSRLinearInterpolation(topicImageViewBeginFrame, topicImageViewEndFrame, progress)
            topicTitleLabel.frame = MSRLinearInterpolation(topicTitleLabelBeginFrame, topicTitleLabelEndFrame, progress)
            focusButton.frame = MSRLinearInterpolation(focusButtonBeginFrame, focusButtonEndFrame, progress)
        } else {
            let offset = bounds.height - maxHeight
            backButtonEndFrame.origin.y += offset
            topicImageViewEndFrame.origin.y += offset
            topicTitleLabelEndFrame.origin.y += offset
            focusButtonEndFrame.origin.y += offset
            backButton.frame = backButtonEndFrame
            topicImageView.frame = topicImageViewEndFrame
            topicTitleLabel.frame = topicTitleLabelEndFrame
            focusButton.frame = focusButtonEndFrame
        }
        topicDescriptionLabel.frame = CGRect(x: topicTitleLabel.frame.msr_left, y: topicTitleLabel.frame.msr_bottom + 5, width: bounds.width - topicTitleLabel.frame.msr_left - 10, height: topicImageView.frame.height - topicTitleLabel.frame.height - 5)
        topicDescriptionLabel.sizeToFit()
    }
    
}
