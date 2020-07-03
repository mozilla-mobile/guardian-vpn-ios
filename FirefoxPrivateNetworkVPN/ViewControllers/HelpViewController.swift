//
//  HelpViewController
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
import MessageUI

class HelpViewController: UIViewController, Navigating {
    // MARK: Properties
    static var navigableItem: NavigableItem = .help

    @IBOutlet weak var tableView: UITableView!

    private var dataSource: HelpDataSource?
    private let disposeBag = DisposeBag()

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()

        dataSource = HelpDataSource(with: tableView)
        tableView.tableFooterView = UIView()

        subscribeToRowSelected()
    }

    // MARK: Setup
    func setupNavigationBar() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil // enables back swipe

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = LocalizedString.helpTitle.value
        navigationItem.titleView?.tintColor = UIColor.custom(.grey50)
        let chevron = UIImage(named: "icon_backChevron")?.withRenderingMode(.alwaysTemplate)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: chevron, style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.custom(.grey40)
    }

    @objc func goBack() {
        navigate(to: .settings)
    }

    private func subscribeToRowSelected() {
        //swiftlint:disable:next trailing_closure
        dataSource?.rowSelected
            .subscribe(onNext: { [weak self] item in
                if item == .debug {
                    self?.presentMailForDebugSupport()
                    return
                }
                self?.navigate(to: .safari, context: .url(item.url))
            })
            .disposed(by: disposeBag)
    }
}

extension HelpViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //handle fail case
        controller.dismiss(animated: true)
    }

    private func presentMailForDebugSupport() {
        let emailManager = EmailManager()
        guard let emailVC = emailManager.getDebugLogMailTemplate() else {
            // Open the Mail app if the user has not set up email accounts
            let destinationURL = URL(string: "message://")!
            if UIApplication.shared.canOpenURL(destinationURL) {
                UIApplication.shared.open(destinationURL, options: [:])
            }
            return
        }

        emailVC.mailComposeDelegate = self

        FileManager.getDebugLogs { [weak self] logData in
            emailVC.setDebugLogAttachment(with: logData)
            DispatchQueue.main.async {
                self?.present(emailVC, animated: true)
            }
        }
    }
}
