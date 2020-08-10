//
//  LandingViewController
//  MozillaVPNmacOS
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Cocoa

class LandingViewController: NSViewController {

    private let guardianAPI = DependencyManager.shared.guardianAPI
    private var verificationURL: URL?
    private var verifyTimer: Timer?
    private var isVerifying = false

    @IBOutlet weak var loadingView: NSView!
    @IBOutlet weak var resultView: NSView!

    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    deinit {
        verifyTimer?.invalidate()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    @objc private func verify() {
        guard let verificationURL = verificationURL else { return }
        if isVerifying { return }
        isVerifying = true

        guardianAPI.verify(urlString: verificationURL.absoluteString) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let verification):
                print("verify succeed")
                self.resultView.isHidden = false
                DependencyManager.shared.accountManager.login(with: verification) { loginResult in
                    self.isVerifying = false
                    self.verifyTimer?.invalidate()
                    switch loginResult {
                    case .success:
                        print("login succeed")
                    case .failure:
                        print("login fail")
                    }
                    self.verifyTimer?.invalidate()
                }
            case .failure:
                print("verify fail")
                self.isVerifying = false
                return
            }
        }
    }

    @IBAction func getStarted(_ sender: NSButton) {
        guardianAPI.initiateUserLogin { [weak self] result in
            switch result {
            case .success(let checkpointModel):
                guard let self = self, let loginURL = checkpointModel.loginUrl else { return }
                self.verificationURL = checkpointModel.verificationUrl
                NSWorkspace.shared.open(loginURL)
                self.loadingView.isHidden = false

                if self.verifyTimer == nil {
                    self.verifyTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.verify), userInfo: nil, repeats: true)
                }
            case .failure:
                print("init fail")
            }
        }
    }

    @IBAction func learnMore(_ sender: NSButton) {
        print("learn more")
    }

    @IBAction func cancelAndRetry(_ sender: NSButton) {
        print("cancel and try again")
    }

    @IBAction func `continue`(_ sender: NSButton) {
        print("continue")
        self.view.window?.close()

        let rootViewController = HomeViewController()
        let window = NSWindow(contentViewController: rootViewController)
        window.title = "Mozilla VPN"
        window.setContentSize(NSSize(width: 360, height: 176))
        window.setFrameAutosaveName(NSWindow.FrameAutosaveName("HomeWindow"))
        window.makeKeyAndOrderFront(nil)
    }
}
