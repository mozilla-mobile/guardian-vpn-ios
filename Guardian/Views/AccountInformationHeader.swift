// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit

class AccountInformationHeader: UITableViewHeaderFooterView {

    static let height: CGFloat = 280.0

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(with user: User) {
        nameLabel.text = user.displayName.isEmpty ? "User" : user.displayName
        emailLabel.text = user.email

        if let url = URL(string: user.avatarUrlString) {
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
