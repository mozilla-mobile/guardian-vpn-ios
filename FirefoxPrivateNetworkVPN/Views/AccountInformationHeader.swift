//
//  AccountInformationHeader
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit
import RxSwift

class AccountInformationHeader: UIView {
    static let height: CGFloat = UIScreen.isiPad ? 400.0 : 294.0

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var manageAccountButton: UIButton!

    var user = DependencyFactory.sharedFactory.accountManager.account?.user

    let buttonTappedSubject = PublishSubject<NavigableItem>()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupManageAccountButton()
    }

    override func reloadInputViews() {
        refreshUserInfo()
    }

    private func setupManageAccountButton() {
        manageAccountButton.setTitle(LocalizedString.settingsManageAccount.value, for: .normal)
        manageAccountButton.setBackgroundImage(UIImage.image(with: UIColor.custom(.blue80)), for: .highlighted)
        manageAccountButton.cornerRadius = manageAccountButton.frame.size.height/10
    }

    private func refreshUserInfo() {
        if let user = user {
            nameLabel.text = user.displayName.isEmpty ? LocalizedString.settingsDefaultName.value : user.displayName
            emailLabel.text = user.email

            if let url = user.avatarURL {
                downloadAvatar(url)
            }
        }
    }

    private func downloadAvatar(_ url: URL) {
        let dataTask = URLSession.shared.dataTask(with: url) { [weak self] maybeData, _, _ in
            if let data = maybeData, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.avatarImageView.image = image
                }
            }
        }
        dataTask.resume()
    }

    @IBAction func accountButtonTapped() {
        buttonTappedSubject.onNext(.hyperlink(HyperlinkItem.account.url))
    }
}
