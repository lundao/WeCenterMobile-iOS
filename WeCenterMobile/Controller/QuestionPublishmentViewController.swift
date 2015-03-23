//
//  QuestionPublishmentViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/18.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit
import ObjectiveC

class QuestionPublishmentViewController: UIViewController, ZFTokenFieldDataSource, ZFTokenFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UzysAssetsPickerControllerDelegate {
    
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tagsField: ZFTokenField!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    let identifiers = ["ImageCell", "ButtonCell"]
    let imageViewTag = 23333
    let progressViewTag = 23334
    let buttonTag = 23335
    let overlayViewTag = 23336
    
    var tags = [String]()
    var images = [UIImage]()
    var uploadingProgresses = [Int]()
    let maxProgress = 100
    var imageAdditonButton = UIButton()
    
    var timeKey: NSTimeInterval = NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dismissButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        previewButton.addTarget(self, action: "preview", forControlEvents: .TouchUpInside)
        scrollView.alwaysBounceVertical = true
        tagsField.textField.textColor = UIColor.lightTextColor()
        tagsField.textField.font = UIFont.systemFontOfSize(14)
        tagsField.textField.attributedPlaceholder = NSAttributedString(string: "输入并以换行键添加，可添加多个", attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor().colorWithAlphaComponent(0.3)])
        tagsField.textField.keyboardAppearance = .Dark
        for identifier in identifiers {
            imageCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        }
        imageCollectionView.backgroundColor = UIColor.clearColor()
        imageAdditonButton.setImage(UIImage(named: "AddButton"), forState: .Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagsField.reloadData()
        imageCollectionView.reloadData()
    }
    
    // MARK: - ZFTokenFieldDataSource
    
    func lineHeightForTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 24
    }
    
    func numberOfTokenInField(tokenField: ZFTokenField!) -> UInt {
        return UInt(tags.count)
    }
    
    func tokenField(tokenField: ZFTokenField!, viewForTokenAtIndex index: UInt) -> UIView! {
        let tag = tags[Int(index)]
        let label = UILabel()
        label.text = tag
        label.font = UIFont.systemFontOfSize(14)
        label.sizeToFit()
        label.frame.size.height = lineHeightForTokenInField(tagsField)
        label.frame.size.width += 20
        label.textAlignment = .Center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 3
        label.backgroundColor = UIColor.lightTextColor()
        return label
    }
    
    // MARK: - ZFTokenFieldDelegate
    
    func tokenMarginInTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 5
    }
    
    func tokenField(tokenField: ZFTokenField!, didRemoveTokenAtIndex index: UInt) {
        tags.removeAtIndex(Int(index))
    }
    
    func tokenField(tokenField: ZFTokenField!, didReturnWithText text: String!) {
        tags.append(text)
        tagsField.reloadData()
    }
    
    // MARK: - UICollectionDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        println("RELOADING CELL AT (\(indexPath.row))")
        let cell: UICollectionViewCell!
        if indexPath.row < images.count {
            cell = imageCollectionView.dequeueReusableCellWithReuseIdentifier(identifiers[0], forIndexPath: indexPath) as! UICollectionViewCell
            var imageView: UIImageView! = cell.contentView.viewWithTag(imageViewTag) as? UIImageView
            if imageView == nil {
                imageView = UIImageView()
                imageView.tag = imageViewTag
                cell.contentView.addSubview(imageView)
                imageView.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                imageView.msr_addAllEdgeAttachedConstraintsToSuperview()
            }
            imageView!.image = images[indexPath.row]
            var overlayView: UIView! = cell.contentView.viewWithTag(overlayViewTag)
            if overlayView == nil {
                overlayView = UIView()
                overlayView.tag = overlayViewTag
                cell.contentView.insertSubview(overlayView, aboveSubview: imageView)
                overlayView.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                overlayView.msr_addAllEdgeAttachedConstraintsToSuperview()
                overlayView.backgroundColor = scrollView.backgroundColor!.colorWithAlphaComponent(0.6)
            }
            var progressView: EAColourfulProgressView! = cell.contentView.viewWithTag(progressViewTag) as? EAColourfulProgressView
            if progressView == nil {
                progressView = NSBundle.mainBundle().loadNibNamed("ImageUploadingProgressBar", owner: self, options: nil).first as! EAColourfulProgressView
                progressView.tag = progressViewTag
                progressView.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                progressView.msr_addHeightConstraintWithValue(8)
                cell.contentView.insertSubview(progressView, aboveSubview: overlayView)
                progressView.msr_addHorizontalEdgeAttachedConstraintsToSuperview()
                progressView.msr_addBottomAttachedConstraintToSuperview()
                progressView.maximumValue = UInt(self.maxProgress)
            }
            let maxProgress = self.maxProgress
            let uploadingProgress = Int(uploadingProgresses[indexPath.row])
            println("\(indexPath.row): \(uploadingProgress) of \(maxProgress)")
            UIView.animateWithDuration(0.5,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0.7,
                options: .BeginFromCurrentState,
                animations: {
                    overlayView.alpha = uploadingProgress == maxProgress ? 0 : 1
                    progressView.alpha = uploadingProgress == maxProgress ? 0 : 1
                    progressView.updateToCurrentValue(maxProgress - uploadingProgress, animated: false)
                    return
                },
                completion: {
                    finished in
                    if uploadingProgress == maxProgress {
                        progressView.updateToCurrentValue(1, animated: false)
                    }
                })
        } else {
            cell = imageCollectionView.dequeueReusableCellWithReuseIdentifier(identifiers[1], forIndexPath: indexPath) as! UICollectionViewCell
            var button: UIButton! = cell.contentView.viewWithTag(buttonTag) as? UIButton
            if button == nil {
                button = UIButton()
                button.tag = buttonTag
                cell.contentView.addSubview(button)
                button.msr_shouldTranslateAutoresizingMaskIntoConstraints = false
                button.msr_addAllEdgeAttachedConstraintsToSuperview()
                button.setImage(UIImage(named: "MSRAddButton")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                button.imageView!.tintColor = UIColor.msr_materialBlueGray800()
                button.addTarget(self, action: "showPickerController", forControlEvents: .TouchUpInside)
            }
        }
        return cell
    }
    
    // MARK: - UzysAssetsPickerControllerDelegate
    
    func uzysAssetsPickerController(picker: UzysAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        let rs = map(assets, { ($0 as! ALAsset).defaultRepresentation() })
        var images = [UIImage]()
        for r in rs {
            let image = UIImage(
                CGImage: r.fullResolutionImage().retain().takeRetainedValue(),
                scale: CGFloat(r.scale()),
                orientation: UIImageOrientation(rawValue: r.orientation().rawValue)!)!
            images.append(image)
            uploadingProgresses.append(0)
        }
        self.images.extend(images)
        imageCollectionView.reloadData()
        for image in images {
            let operation = NetworkManager.defaultManager!.request("Upload Attach",
                GETParameters: [
                    "id": "question",
                    "attach_access_key": "\(timeKey)".msr_MD5EncryptedString],
                POSTParameters: nil,
                constructingBodyWithBlock: {
                    [weak self] data in
                    if let self_ = self {
                        data?.appendPartWithFileData(UIImagePNGRepresentation(image), name: "qqfile", fileName: "image.png", mimeType: "image/png")
                    }
                    return
                },
                success: {
                    data in
                    println(data)
                    return
                },
                failure: {
                    [weak self] error in
                    println(error)
                    if let self_ = self {
                        if let index = find(self_.images, image) {
                            self_.images.removeAtIndex(index)
                            self_.uploadingProgresses.removeAtIndex(index)
                            self_.imageCollectionView.reloadData()
                        }
                    }
                    return
            })
            operation!.setUploadProgressBlock() {
                [weak self] bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                if let self_ = self {
                    if let index = find(self_.images, image) {
//                        println("\(index): sent \(totalBytesWritten) of \(totalBytesExpectedToWrite)")
                        self_.uploadingProgresses[index] = Int(totalBytesWritten * Int64(self_.maxProgress) / totalBytesExpectedToWrite)
                        self_.imageCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
                    }
                }
                return
            }
        }
    }
    
    
    func uzysAssetsPickerControllerDidExceedMaximumNumberOfSelection(picker: UzysAssetsPickerController!) {
        
    }
    
    func showPickerController() {
        let c = UzysAppearanceConfig()
        c.cameraImageName = "Camera-Line"
        c.closeImageName = "X"
        c.finishSelectionButtonColor = UIColor.msr_materialBlueGray()
        UzysAssetsPickerController.setUpAppearanceConfig(c)
        let pc = MediaPickerController()
        pc.delegate = self
        pc.maximumNumberOfSelectionPhoto = 10
        pc.maximumNumberOfSelectionVideo = 0
        presentViewController(pc, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func preview() {
    }
    
    deinit {
        
    }
    
}
