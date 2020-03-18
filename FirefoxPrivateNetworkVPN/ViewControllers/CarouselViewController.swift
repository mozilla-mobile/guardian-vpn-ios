//
//  CarouselViewController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class CarouselViewController: UIViewController, Navigating {
    static var navigableItem: NavigableItem = .carousel

    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    @IBOutlet weak private var getStartedButton: UIButton!
    @IBOutlet weak private var centerView: UIView!

    var type: CarouselViewType

    init(for type: CarouselViewType) {
        self.type = type
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        getStartedButton.cornerRadius = getStartedButton.frame.height/10
    }

    override func viewDidLayoutSubviews() {
        layoutCenterView()
    }

    private func setupView() {
        imageView.image = type.image
        titleLabel.text = type.title
        subtitleLabel.text = type.subtitle

        switch type {
        case .getStarted:
            getStartedButton.setTitle(LocalizedString.getStarted.value, for: .normal)
            getStartedButton.setBackgroundImage(UIImage.image(with: UIColor.custom(.blue80)), for: .highlighted)
        default:
            getStartedButton.isHidden = true
        }
    }

    private func layoutCenterView() {
        centerView.translatesAutoresizingMaskIntoConstraints = true
        centerView.center.y = getStartedButton.frame.minY/2
    }

    @IBAction func getStarted() {
        navigate(to: .login)
    }
}
