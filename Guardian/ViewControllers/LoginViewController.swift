//
//  LoginViewController
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit
import SafariServices

class LoginViewController: SFSafariViewController, Navigating {
    static var navigableItem: NavigableItem = .login
    
    override func viewDidLoad() {
        delegate = self
    }
}

extension LoginViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        //
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        //
    }
}
