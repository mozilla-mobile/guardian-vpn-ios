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

class AccountInformationHeader: UITableViewHeaderFooterView {
    static let height: CGFloat = 280.0

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var manageAccountButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        configureManageAccountButton()
    }

    private func configureManageAccountButton() {
        manageAccountButton.setTitle(LocalizedString.settingsManageAccount.value, for: .normal)
        manageAccountButton.setBackgroundImage(UIImage.image(with: UIColor.custom(.blue80)), for: .highlighted)
    }

    func setup(with user: User) {
        nameLabel.text = user.displayName.isEmpty ? LocalizedString.settingsDefaultName.value : user.displayName
        emailLabel.text = user.email

        if let url = user.avatarURL {
            downloadAvatar(url)
        }
    }

    func downloadAvatar(_ url: URL) {
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
        if let url = HyperlinkItem.account.url {
            UIApplication.shared.open(url)
        }
    }
}
