//
//  ViewController
//
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Cocoa
import WebKit

class ViewController: NSViewController {

    private let networkLayer: Networking = NetworkLayer()
    private let persistenceLayer: Persisting = PersistenceLayer()

    private var verificationURL: URL?
    private var verifyTimer: Timer?
    private var isVerifying = false

    lazy var accountStore: AccountStoring = AccountStore(persistenceLayer: persistenceLayer)
    lazy var guardianAPI = GuardianAPI(networkLayer: networkLayer, userAgentInfo: NetworkingUtilities.userAgentInfo)
    lazy var accountManager = AccountManager(guardianAPI: guardianAPI, accountStore: accountStore)
    var tunnelsManager: MacOSTunnelManager?

    lazy var webView: WKWebView = { [unowned self] in
        let configuration = WKWebViewConfiguration()
        let wkWebView = WKWebView(frame: self.view.frame, configuration: configuration)
        wkWebView.navigationDelegate = self
        return wkWebView
    }()

    var servers: [VPNCity]? {
        accountManager.availableServers.first(where: { $0.code.uppercased() == "US" })?.cities
    }

    @IBOutlet weak var selectedCityLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        TunnelsManager.create { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("\(error.alertText)")
            case .success(let tunnelsManager):
                self.tunnelsManager = MacOSTunnelManager(tunnelsManager: tunnelsManager, accountManager: self.accountManager)
            }
        }

        guardianAPI.initiateUserLogin { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let checkpointModel):
                guard let loginURL = checkpointModel.loginUrl else { return }
                self.verificationURL = checkpointModel.verificationUrl
                DispatchQueue.main.async {
                    self.view.addSubview(self.webView)
                    self.webView.translatesAutoresizingMaskIntoConstraints = false
                    self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
                    self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
                    self.webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                    self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
                    let request = URLRequest(url: loginURL)
                    self.webView.load(request)
                }
            case .failure(let error):
                let loginError = error.getLoginError()
                print("\(loginError.errorDescription ?? "ERROR!!!")")
            }
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.doubleAction = #selector(listDoubleClicked(sender:))
    }

    @objc private func verify() {
        print("verify")
        guard let verificationURL = verificationURL else { return }
        if isVerifying { return }
        isVerifying = true

        guardianAPI.verify(urlString: verificationURL.absoluteString) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let verification):
                print("verify succeed")
                self.accountManager.login(with: verification) { loginResult in
                    self.isVerifying = false
                    self.verifyTimer?.invalidate()
                    switch loginResult {
                    case .success:
                        self.tableView.reloadData()
                        self.webView.removeFromSuperview()
                    case .failure:
                        print("Verify error")
                    }
                }
            case .failure:
                print("verify fail")
                self.isVerifying = false
                return
            }
        }
    }

    @objc func listDoubleClicked(sender: AnyObject) {
        let tunnelIndex = tableView.clickedRow
        guard tunnelIndex >= 0 && tunnelIndex < (servers?.count ?? 0) else { return }
        if tunnelsManager?.selectedTunnel != nil {
            if let city = servers?[tunnelIndex] {
                tunnelsManager?.switchServer(city: city)
                selectedCityLabel.stringValue = city.name
            }
        } else {
            if let city = servers?[tunnelIndex] {
                accountManager.updateSelectedCity(with: city)
                tunnelsManager?.addVPNConfig()
            }
        }
    }

    @IBAction func connect(_ sender: NSButton) {
        self.tunnelsManager?.connect()
    }

    @IBAction func logOut(_ sender: NSButton) {
        self.accountManager.logout { result in
            switch result {
            case .success:
                print("log out success")
            case .failure(let error):
                print("log out fail: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension ViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if verifyTimer == nil {
            verifyTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(verify), userInfo: nil, repeats: true)
        }
    }
}

extension ViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return servers?.count ?? 0
    }
}

extension ViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell: TunnelListRow = tableView.dequeueReusableCell()
        if let city = servers?[row] {
            cell.config(city: city)
        }
        return cell
    }
}

extension NSTableView {
    func dequeueReusableCell<T: NSView>() -> T {
        let identifier = NSUserInterfaceItemIdentifier(NSStringFromClass(T.self))
        if let cellView = makeView(withIdentifier: identifier, owner: self) {
            //swiftlint:disable:next force_cast
            return cellView as! T
        }
        let cellView = T()
        cellView.identifier = identifier
        return cellView
    }
}

class TunnelListRow: NSView {

    let nameLabel: NSTextField = {
        let nameLabel = NSTextField()
        nameLabel.isEditable = false
        nameLabel.isSelectable = false
        nameLabel.isBordered = false
        nameLabel.maximumNumberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
        return nameLabel
    }()

    let statusImageView = NSImageView()

    private var statusObservationToken: AnyObject?
    private var nameObservationToken: AnyObject?

    init() {
        super.init(frame: CGRect.zero)

        addSubview(statusImageView)
        addSubview(nameLabel)
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.backgroundColor = .clear
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: statusImageView.leadingAnchor),
            statusImageView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            statusImageView.widthAnchor.constraint(equalToConstant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            statusImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func image(for status: TunnelStatus?) -> NSImage? {
        guard let status = status else { return nil }
        switch status {
        case .active, .restarting, .reasserting:
            return NSImage(named: NSImage.statusAvailableName)
        case .activating, .waiting, .deactivating:
            return NSImage(named: NSImage.statusPartiallyAvailableName)
        case .inactive:
            return NSImage(named: NSImage.statusNoneName)
        }
    }

    override func prepareForReuse() {
        nameLabel.stringValue = ""
        statusImageView.image = nil
    }

    func config(city: VPNCity) {
        nameLabel.stringValue = city.name
    }
}
