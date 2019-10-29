// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit

class LandingViewController: UIViewController {
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var learnMoreButton: UIButton!

    weak var coordinatorDelegate: Navigating?

    init(coordinatorDelegate: Navigating) {
        self.coordinatorDelegate = coordinatorDelegate
        super.init(nibName: String(describing: LandingViewController.self), bundle: Bundle.main)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func getStarted(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self?.coordinatorDelegate?.navigate.onNext(.loginFailed)
        }
    }

    @IBAction func learnMore(_ sender: UIButton) {
        // TODO: Display information carousel
    }

}
