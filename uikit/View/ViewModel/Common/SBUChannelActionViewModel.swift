//
//  SBUChannelLoadViewModel.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/03/15.
//  Copyright © 2021 SendBird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK

typealias EmptyParamsCompletion = (SBDError?) -> Void

class SBUChannelActionViewModel: SBULoadableViewModel  {
    
    // MARK: - Properties
    private(set) var channel: SBDBaseChannel? = nil
    let channelLoadedObservable = SBUObservable<SBDBaseChannel>()
    let channelChangedObservable = SBUObservable<SBDBaseChannel>()
    let channelDeletedObservable = SBUObservable<Void>()
    
    private lazy var emptyParamsCompletion: EmptyParamsCompletion = {
        return { [weak self] error in
            guard let self = self else { return }
            
            self.loadingObservable.set(value: false)
            if let error = error {
                SBULog.error("""
                    [Failed] Delete channel request:
                    \(String(error.localizedDescription))
                    """)
                self.errorObservable.set(value: error)
                return
            }
            
            if let channel = self.channel {
                self.channelChangedObservable.set(value: channel)
            }
        }
    }()
    
    // MARK: - Group Channel
    
    func loadGroupChannel(with channelUrl: String) {
        self.loadingObservable.set(value: true)
        
        SBUMain.connectionCheck { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error {
                self.loadingObservable.set(value: false)
                self.errorObservable.set(value: error)
            } else {
                SBDGroupChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                    guard let self = self else { return }
                    
                    self.loadingObservable.set(value: false)
                    if let error = error {
                        self.errorObservable.set(value: error)
                    } else if let channel = channel {
                        self.channel = channel
                        self.channelLoadedObservable.set(value: channel)
                    }
                }
            }
        }
    }
    
    func updateChannel(params: SBDGroupChannelParams) {
        guard let groupChannel = self.channel as? SBDGroupChannel else { return }
        
        SBULog.info("[Request] Channel update")
        self.loadingObservable.set(value: true)
        
        groupChannel.update(with: params) { [weak self] channel, error in
            guard let self = self else { return }
            
            self.loadingObservable.set(value: false)
            if let error = error {
                SBULog.error("""
                    [Failed] Channel update request:
                    \(String(error.localizedDescription))
                    """)
                self.errorObservable.set(value: error)
            } else if let channel = channel {
                self.channel = channel
                self.channelChangedObservable.set(value: channel)
            }
        }
    }
    
    func leaveChannel() {
        guard let groupChannel = self.channel as? SBDGroupChannel else { return }
        
        self.loadingObservable.set(value: true)
        
        groupChannel.leave { [weak self] error in
            guard let self = self else { return }
            
            self.loadingObservable.set(value: false)
            if let error = error {
                SBULog.error("""
                    [Failed] Leave channel request:
                    \(String(error.localizedDescription))
                    """)
                self.errorObservable.set(value: error)
                return
            }
            
            self.channel = nil
            self.channelDeletedObservable.set(value: ())
        }
    }
    
    func freezeChannel(completionHandler: ((Bool) -> Void)? = nil) {
        guard let groupChannel = self.channel as? SBDGroupChannel else { return }
        
        self.loadingObservable.set(value: true)

        groupChannel.freeze { [weak self] error in
            guard let self = self else {
                completionHandler?(false)
                return
            }
            
            defer { self.loadingObservable.set(value: false) }
            
            if let error = error {
                SBULog.error("""
                    [Failed] Freeze channel request:
                    \(String(error.localizedDescription))
                    """)
                completionHandler?(false)
                return
            }
            
            if let channel = self.channel {
                self.channelChangedObservable.post(value: channel)
            }
            completionHandler?(true)
        }
    }
    
    func unfreezeChannel(completionHandler: ((Bool) -> Void)? = nil) {
        guard let groupChannel = self.channel as? SBDGroupChannel else { return }
        
        self.loadingObservable.set(value: true)
        
        groupChannel.unfreeze { [weak self] error in
            guard let self = self else {
                completionHandler?(false)
                return
            }
            
            defer { self.loadingObservable.set(value: false) }
            
            if let error = error {
                SBULog.error("""
                    [Failed] Unfreeze channel request:
                    \(String(error.localizedDescription))
                    """)
                completionHandler?(false)
                return
            }
            
            if let channel = self.channel {
                self.channelChangedObservable.post(value: channel)
            }
            completionHandler?(true)
        }
    }
    
    func changeNotification(triggerOption: SBDGroupChannelPushTriggerOption) {
        guard let groupChannel = self.channel as? SBDGroupChannel else { return }
        
        self.loadingObservable.set(value: true)
        
        groupChannel.setMyPushTriggerOption(triggerOption) { [weak self] error in
            guard let self = self else { return }
            
            self.loadingObservable.set(value: false)
            if let error = error {
                SBULog.error("""
                    [Failed] Channel push status request:
                    \(String(error.localizedDescription))
                    """)
                self.errorObservable.set(value: error)
                return
            }
            
            if let channel = self.channel {
                self.channelChangedObservable.post(value: channel)
            }
        }
    }

    func promoteToOperator(member: SBUUser) {
        guard let channel = self.channel else { return }
        self.loadingObservable.set(value: true)
        channel.addOperators(
            withUserIds: [member.userId],
            completionHandler: self.emptyParamsCompletion)
    }
    
    func dismissOperator(member: SBUUser) {
        guard let channel = self.channel else { return }
        self.loadingObservable.set(value: true)
        channel.removeOperators(
            withUserIds: [member.userId],
            completionHandler: self.emptyParamsCompletion)
    }
    
    func mute(member: SBUUser) {
        guard let channel = self.channel as? SBDGroupChannel else { return }
        self.loadingObservable.set(value: true)
        channel.muteUser(
            withUserId: member.userId,
            completionHandler: self.emptyParamsCompletion)
    }
    
    func unmute(member: SBUUser) {
        guard let channel = self.channel as? SBDGroupChannel else { return }
        self.loadingObservable.set(value: true)
        channel.unmuteUser(
            withUserId: member.userId,
            completionHandler: self.emptyParamsCompletion)
    }
    
    func ban(member: SBUUser) {
        guard let channel = self.channel as? SBDGroupChannel else { return }
        self.loadingObservable.set(value: true)
        channel.banUser(
            withUserId: member.userId,
            seconds: -1,
            description: nil,
            completionHandler: self.emptyParamsCompletion)
    }
    
    func unban(member: SBUUser) {
        if let groupChannel = self.channel as? SBDGroupChannel {
            self.loadingObservable.set(value: true)
            groupChannel.unbanUser(withUserId: member.userId,
                                   completionHandler: self.emptyParamsCompletion)
        } else if let openChannel = self.channel as? SBDOpenChannel {
            self.loadingObservable.set(value: true)
            openChannel.unbanUser(withUserId: member.userId,
                                  completionHandler: self.emptyParamsCompletion)
        }
    }
    
    
    // MARK: - Open Channel
    
    func loadOpenChannel(with channelUrl: String) {
        self.loadingObservable.set(value: true)
        
        SBUMain.connectionCheck { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error {
                self.loadingObservable.set(value: false)
                self.errorObservable.set(value: error)
            } else {
                SBDOpenChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                    guard let self = self else { return }
                    
                    self.loadingObservable.set(value: false)
                    if let error = error {
                        self.errorObservable.set(value: error)
                    } else if let channel = channel {
                        self.channel = channel
                        self.channelLoadedObservable.set(value: channel)
                    }
                }
            }
        }
    }
    
    func updateChannel(params: SBDOpenChannelParams) {
        guard let openChannel = self.channel as? SBDOpenChannel else { return }
        guard let operators = openChannel.operators as? [SBDUser] else { return }
        
        self.loadingObservable.set(value: true)
        
        let operatorUserIds = operators.map { $0.userId }
        
        SBULog.info("[Request] Channel update")
        
        openChannel.update(withName: params.name,
                           coverImage: params.coverImage,
                           coverImageName: "cover_image",
                           data: nil,
                           operatorUserIds: operatorUserIds,
                           customType: openChannel.customType,
                           progressHandler: nil) { [weak self] channel, error in
            guard let self = self else { return }
            
            self.loadingObservable.set(value: false)
            if let error = error {
                SBULog.error("""
                    [Failed] Channel update request:
                    \(String(error.localizedDescription))
                    """)
                self.errorObservable.set(value: error)
                return
            } else if let channel = channel {
                self.channel = channel
                self.channelChangedObservable.set(value: channel)
            }
        }
    }
    
    func deleteChannel() {
        guard let channel = self.channel as? SBDOpenChannel else { return }
        
        self.loadingObservable.set(value: true)
        
        channel.delete { [weak self] error in
            guard let self = self else { return }
            
            self.loadingObservable.set(value: false)
            if let error = error {
                SBULog.error("""
                    [Failed] Delete channel request:
                    \(String(error.localizedDescription))
                    """)
                self.errorObservable.set(value: error)
            }
            
            self.channel = nil
            self.channelDeletedObservable.set(value: ())
        }
    }
    
    
    // MARK: - Common
    
    func loadChannel(url: String, type: SBDChannelType) {
        switch type {
        case .group: self.loadGroupChannel(with: url)
        case .open: self.loadOpenChannel(with: url)
        }
    }
    
    // MARK: - SBUViewModelDelegate
    
    override func dispose() {
        super.dispose()
        self.channelLoadedObservable.dispose()
        self.channelChangedObservable.dispose()
        self.channelDeletedObservable.dispose()
    }
}

