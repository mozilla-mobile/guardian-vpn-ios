//
//  AppDelegate
//
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let rootViewController = LandingViewController()
        window = NSWindow(contentViewController: rootViewController)
        window?.title = "Mozilla VPN"
        window?.setContentSize(NSSize(width: 360, height: 176))
        window?.setFrameAutosaveName(NSWindow.FrameAutosaveName("ManageTunnelsWindow"))
        window?.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
