//
//  ChannelSettingsVC_Overriding.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/07.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit


/// ------------------------------------------------------
/// This section is related to overriding.
/// ------------------------------------------------------
class ChannelSettingsVC_Overriding: SBUChannelSettingsViewController {
    // MARK: - Show relations
    override func showMemberList() {
        // If you want to use your own MemberListViewController, you can override and customize it here.
        AlertManager.showCustomInfo(#function)
    }
    
    // MARK: - Error handling
    override func didReceiveError(_ message: String?) {
        // If you override and customize this function, you can handle it when error received.
        print(message as Any);
    }
}
