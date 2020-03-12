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

class AccountInformationHeader: UITableViewHeaderFooterView {
    static let height: CGFloat = UIScreen.isiPad ? 400.0 : 294.0

    @IBOutlet weak private var avatarImageView: UIImageView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var emailLabel: UILabel!
    @IBOutlet weak private var manageAccountButton: UIButton!

    private var user: User? { return DependencyFactory.sharedFactory.accountManager.account?.user }

    let buttonTappedSubject = PublishSubject<NavigableItem>()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupManageAccountButton()
        refreshUser()
    }

    override func prepareForReuse() {
        refreshUser()
    }

    private func setupManageAccountButton() {
        manageAccountButton.setTitle(LocalizedString.settingsManageAccount.value, for: .normal)
        manageAccountButton.setBackgroundImage(UIImage.image(with: UIColor.custom(.blue80)), for: .highlighted)
        manageAccountButton.cornerRadius = manageAccountButton.frame.size.height/10
    }

    private func refreshUser() {
        if let user = user {
            nameLabel.text = user.displayName.isEmpty ? LocalizedString.settingsDefaultName.value : user.displayName
            emailLabel.text = user.email
            if let url = user.avatarURL {
                GuardianAPI.downloadAvatar(url) { [weak self] result in
                    self?.setAvatar(result)
                }
            }
        }
    }
    
    @IBAction func accountButtonTapped() {
        buttonTappedSubject.onNext(.hyperlink(HyperlinkItem.account.url))
    }
    
    private func setAvatar(_ result: Result<Data?, GuardianAPIError>) {
        guard case .success(let data) = result,
            let imageData = data,
            let image = UIImage(data: imageData) else {
                return
        }
        DispatchQueue.main.async { [weak self] in
            self?.avatarImageView.image = image
        }
    }
}
