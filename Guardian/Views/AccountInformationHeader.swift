//
//  AccountInformationHeader
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
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
        manageAccountButton.setTitle(LocalizedString.settingsManageAccount.value, for: .normal)
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
}
