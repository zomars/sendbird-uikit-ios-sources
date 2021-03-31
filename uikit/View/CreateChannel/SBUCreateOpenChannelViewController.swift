//
//  SBUCreateOpenChannelViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/10/22.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

/*
import UIKit
import SendBirdSDK
import Photos
import MobileCoreServices

@objcMembers
open class SBUCreateOpenChannelViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - UI properties (Public)
    public lazy var titleView: UIView? = _titleView
    public lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    public lazy var rightBarButton: UIBarButtonItem? = _rightBarButton

    public lazy var coverImageButton: UIButton = _coverImageButton
    public lazy var channelNameField = UITextField()
    
    public var theme: SBUUserListTheme = SBUTheme.userListTheme
    public var customType: String? = nil
    
    
    // MARK: - UI properties (Private)
    private lazy var _coverImageButton: UIButton = {
       let button = UIButton()
        button.setImage(
            SBUIconType.iconCamera.image(with: self.theme.coverImageTintColor)
                .resize(with: .init(width: kCoverImageSize, height: kCoverImageSize))
                .withBackground(
                    color: self.theme.coverImageBackgroundColor,
                    margin: 24,
                    circle: true
            ),
            for: .normal
        )
        button.addTarget(self, action: #selector(selectChannelImage), for: .touchUpInside)
        button.layer.cornerRadius = kCoverImageSize/2
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var _titleView: SBUNavigationTitleView = {
        var titleView: SBUNavigationTitleView
        if #available(iOS 11, *) {
            titleView = SBUNavigationTitleView()
        } else {
            titleView = SBUNavigationTitleView(
                frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
            )
        }
        titleView.text = SBUStringSet.CreateChannel_Header_Title_Profile
        titleView.textAlignment = .center
        return titleView
    }()
    
    private lazy var _leftBarButton: UIBarButtonItem = {
        let barButtinItem =  UIBarButtonItem(
            title: SBUStringSet.Cancel,
            style: .plain,
            target: self,
            action: #selector(onClickBack)
        )
        barButtinItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return barButtinItem
    }()
    
    private lazy var _rightBarButton: UIBarButtonItem = {
        let barButtinItem =  UIBarButtonItem(
            title: SBUStringSet.CreateChannel_Create(0),
            style: .plain,
            target: self,
            action: #selector(onClickCreate)
        )
        barButtinItem.isEnabled = false
        barButtinItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return barButtinItem
    }()
    
    let kCoverImageSize: CGFloat = 80.0
    
    
    // MARK: - Logic properties (Public)

    
    // MARK: - Logic properties (Private)
    var setCoverImage = false
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUCreateOpenChannelViewController()")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
    }
    
    @available(*, unavailable, renamed: "SBUCreateOpenChannelViewController()")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
    }

    /// This function initializes
    public init() {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
    }
    
    open override func loadView() {
        super.loadView()
        SBULog.info("")
        
        // navigation bar
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        self.navigationItem.titleView = self.titleView
        
        // components
        self.channelNameField.addTarget(self, action: #selector(onEditingChangeTextField(_:)), for: .editingChanged)
        self.channelNameField.clearButtonMode = .whileEditing
        self.view.addSubview(self.coverImageButton)
        self.view.addSubview(self.channelNameField)
        
        // autolayout
        self.setupAutolayout()
        
        // Styles
        self.setupStyles()
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupAutolayout() {
        self.coverImageButton.sbu_constraint(equalTo: self.view, left: 15, top: 15)
        self.coverImageButton.sbu_constraint(width: kCoverImageSize, height: kCoverImageSize)
        
        self.channelNameField.sbu_constraint(equalTo: self.coverImageButton, top: 0, bottom: 0)
        self.channelNameField.sbu_constraint_equalTo(
            leadingAnchor: self.coverImageButton.trailingAnchor,
            leading: 15,
            trailingAnchor: self.view.trailingAnchor,
            trailing: -15
        )
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.theme = SBUTheme.userListTheme
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationShadowColor
        )

        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = theme.barButtonDisabledTintColor
        
        self.channelNameField.attributedPlaceholder = NSAttributedString(
            string: SBUStringSet.ChannelSettings_Enter_New_Channel_Name,
            attributes: [
                NSAttributedString.Key.foregroundColor: theme.placeholderTintColor
            ]
        )
        self.channelNameField.textColor = theme.textfieldTextColor
        self.view.backgroundColor = theme.backgroundColor
    }
    
    open func updateStyles() {
        self.theme = SBUTheme.userListTheme
        
        self.setupStyles()
        
        if let titleView = self.titleView as? SBUNavigationTitleView {
            titleView.setupStyles()
        }
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()

        self.updateStyles()
    }
    
    deinit {
        SBULog.info("")
    }

    
    // MARK: - SDK relations
    
    /// Creates the channel.
    public func createChannel() {
        // TODO: 인자들 받는거 고려
        
        // TODO: 채널명 필수로 받기
        var channelName: String? = nil
        if let channelNameText = self.channelNameField.text, channelNameText.count > 0 {
            channelName = channelNameText
        }
        let coverImage: Data = (self.setCoverImage
            ? self.coverImageButton.imageView?.image?.jpegData(compressionQuality: 1.0)
            : Data()) ?? Data()
        
        self.rightBarButton?.isEnabled = false
        
        SBDOpenChannel.createChannel(
            withName: channelName,
            channelUrl: nil,
            coverImage: coverImage,
            coverImageName: "cover_image",
            data: nil,
            operatorUserIds: [SBUGlobals.CurrentUser?.userId ?? ""],
            customType: customType,
            progressHandler: nil) { [weak self] (channel, error) in
                guard let self = self else { return }
                self.rightBarButton?.isEnabled = true
                if let error = error {
                    SBULog.error("""
                        [Failed] Create channel request:
                        \(String(error.localizedDescription))
                        """)
                    self.didReceiveError(error.localizedDescription)
                }
                
                guard let channel = channel else {
                    SBULog.error("[Failed] Create channel request: There is no channel url.")
                    return
                }
                
                SBULog.info("[Succeed] Create channel: \(channel.description)")
                SBUMain.moveToChannel(channelUrl: channel.channelUrl, basedOnChannelList: false, channelType: .open)
        }
    }

    
    // MARK: - Custom viewController relations
    
    
    // MARK: - Common
    
    
    // MARK: - Actions
    
    /// This function actions to pop or dismiss.
    public func onClickBack() {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /// This function calls `createChannel:` function..
    public func onClickCreate() {
        self.createChannel()
    }
    
    /// This function shows the channel image selection menu.
    public func selectChannelImage() {
        let removeItem = SBUActionSheetItem(
            title: SBUStringSet.RemovePhoto,
            color: theme.removeColor,
            textAlignment: .center
        )
        let cameraItem = SBUActionSheetItem(
            title: SBUStringSet.TakePhoto,
            textAlignment: .center
        )
        let libraryItem = SBUActionSheetItem(
            title: SBUStringSet.ChoosePhoto,
            textAlignment: .center
        )
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: theme.itemColor
        )
        SBUActionSheet.show(
            items: self.setCoverImage ? [removeItem, cameraItem, libraryItem] : [cameraItem, libraryItem],
            cancelItem: cancelItem,
            delegate: self
        )
    }
 
    func onEditingChangeTextField(_ sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sender.text?.isEmpty == true {
            self.rightBarButton?.isEnabled = false
            self.rightBarButton?.tintColor = theme.barButtonDisabledTintColor
        } else {
            self.rightBarButton?.isEnabled = true
            self.rightBarButton?.tintColor = theme.barButtonTintColor
        }
    }
    
    
    // MARK: - Error handling
    open func didReceiveError(_ message: String?) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
}


// MARK: SBUActionSheetDelegate
extension SBUCreateOpenChannelViewController: SBUActionSheetDelegate {
    public func didSelectActionSheetItem(index: Int, identifier: Int) {
        var sourceType: UIImagePickerController.SourceType = .photoLibrary
        let mediaType: [String] = [String(kUTTypeImage)]
        
        let type = self.setCoverImage ? index : index+1
        
        if type == 0 {
            // remove
        } else if type == 1 {
            // camera
            sourceType = .camera
        } else if type == 2 {
            sourceType = .photoLibrary
        }
        
        if type != 0 {
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = sourceType
                imagePickerController.mediaTypes = mediaType
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        else {
            self.coverImageButton.setImage(
                SBUIconType.iconCamera.image(with: self.theme.coverImageTintColor)
                    .resize(with: .init(width: kCoverImageSize, height: kCoverImageSize))
                    .withBackground(
                        color: self.theme.coverImageBackgroundColor,
                        margin: 24,
                        circle: true
                ),
                for: .normal
            )
            self.setCoverImage = false
        }
    }
}


// MARK: UIImagePickerViewControllerDelegate
extension SBUCreateOpenChannelViewController: UIImagePickerControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
            guard let originalImage = info[.originalImage] as? UIImage, let `self` = self else { return }
            
            self.coverImageButton.setImage(
                originalImage
                    .resize(with: .init(width: self.kCoverImageSize, height: self.kCoverImageSize))
                    .withBackground(color: .green, margin: 0, circle: true),
                for: .normal
            )
            
            self.setCoverImage = true
        }
    }
}
*/
