//
//  UpdateRecommendedViewController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit

class UpdateRecommendedViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var connectionSubtitleLabel: UILabel!
    @IBOutlet private weak var updateNowButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocalizedStrings()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction private func updateNowButtonTapped() {
        //go to app store
    }
    
    private func setLocalizedStrings() {
        titleLabel.text = LocalizedString.updateRecommended.rawValue
        subtitleLabel.text = LocalizedString.updateRecommendedSubtitle.rawValue
        connectionSubtitleLabel.text = LocalizedString.updateRecommendedConnection.rawValue
        updateNowButton.titleLabel?.text = LocalizedString.toastUpdateNow.rawValue
    }
}
