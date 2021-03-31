//
//  SBUDownloadManager.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/03/05.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK
import Photos

class SBUDownloadManager: NSObject {

    static func saveImage(parent: UIViewController?, url: URL, fileName: String) {
        DispatchQueue.global(qos: .background).async {
            guard let urlData = NSData(contentsOf: url) else { return }
            let documentsPath = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask,
                true)[0]
            let filePath = "\(documentsPath)/\(fileName)"
            DispatchQueue.main.async {
                urlData.write(toFile: filePath, atomically: true)
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCreationRequest.forAsset()
                        .addResource(with: .photo, data: urlData as Data, options: nil)
                }) { completed, error in
                    
                    guard error == nil else {
                        SBULog.error("[Failed] Save image: \(String(describing: error))")
                        return
                    }
                    
                    if completed {
                        SBULog.info("[Succeed] Image saved.")
                        
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: SBUStringSet.Channel_Success_Download_file,
                                                          message: nil,
                                                          preferredStyle: .alert)
                            parent?.present(alert, animated: true) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    alert.dismiss(animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func saveVideo(with url: URL, fileName: String) {
        DispatchQueue.global(qos: .background).async {
            guard let urlData = NSData(contentsOf: url) else { return }
            let documentsPath = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask,
                true)[0]
            let filePath = "\(documentsPath)/\(fileName)"
            DispatchQueue.main.async {
                urlData.write(toFile: filePath, atomically: true)
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest
                        .creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                }) { completed, error in
                    if let error = error {
                        SBULog.error("[Failed] Save video: \(error.localizedDescription)")
                        return
                    }
                    
                    if completed {
                        SBULog.info("[Succeed] Video is saved.")
                    }
                }
            }
        }
    }
    
    static func saveFile(with fileMessage: SBDFileMessage, parent: UIViewController?) {
        weak var parent = parent

        let channelVC = parent as? SBUBaseChannelViewController
        channelVC?.setLoading(true, true)

        DispatchQueue.global(qos: .background).async {
            guard
                let parent = parent,
                let url = URL(string: fileMessage.url),
                let urlData = NSData(contentsOf: url) else {
                    channelVC?.setLoading(false, true)
                    return
            }
            
            let documentsPath = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask,
                true)[0]
            let filePath = "\(documentsPath)/\(fileMessage.name)"
            urlData.write(toFile: filePath, atomically: true)
            SBULog.info("[Succeed] File is saved.")
            
            let fileURL = URL(fileURLWithPath: filePath)
            
            DispatchQueue.main.async {
                channelVC?.setLoading(false, true) 
                let activityVC = UIActivityViewController(
                    activityItems: [fileURL],
                    applicationActivities: nil
                )
                let transparentVC = UIViewController()
                transparentVC.view.isOpaque = true
                transparentVC.modalPresentationStyle = .overFullScreen
                
                activityVC.completionWithItemsHandler = { type, completed, _, _ in
                    // For iOS 13 issue
                    transparentVC.dismiss(animated: true, completion: nil)
                    parent.presentedViewController?.dismiss(animated: true, completion: nil)
                    
                }
                
                if #available(iOS 13.0, *) {
                    // For iOS 13 issue
                    parent.present(transparentVC, animated: true) { [weak transparentVC] in
                        transparentVC?.present(activityVC, animated: true)
                    }
                } else {
                    parent.present(activityVC, animated: true)
                }
                
            }
        }
    }
    
    static func save(fileMessage: SBDFileMessage, parent: UIViewController?) {
        switch SBUUtils.getFileType(by: fileMessage) {
        case .image:
            guard let url = URL(string: fileMessage.url) else { return }
            SBUDownloadManager.saveImage(parent: parent, url: url, fileName: fileMessage.name)
        default:
            SBUDownloadManager.saveFile(with: fileMessage, parent: parent)
        }
    }
}
