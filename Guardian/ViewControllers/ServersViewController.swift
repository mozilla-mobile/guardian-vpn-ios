//
//  ServersViewController
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit

class ServersViewController: UIViewController, Navigating {
    static var navigableItem: NavigableItem = .servers

    @IBOutlet weak var nameLabel: UILabel!

    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setStrings()
    }

    private func setStrings() {
        nameLabel.accessibilityLabel = "ServersViewController_Name"
        nameLabel.text = NSLocalizedString(nameLabel.accessibilityLabel!, comment: "")
    }
}
