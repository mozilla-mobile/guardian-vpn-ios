//
//  FirefoxPrivateNetworkVPNUITests
//  FirefoxPrivateNetworkVPNUITests
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import XCTest

let nonSubscribedEmail = "test-f5aefc1935@restmail.net"
let nonSubscribedPassword = "gkgJqyzJ"
let subscribedEmail = "test-5418393dc0@restmail.net"
let subscribedPassword = "OVSuBGwI"


class FirefoxPrivateNetworkVPNUITests: BaseTestCase {

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetStarted() {
        // The main screen is shown
        waitForExistence(app.staticTexts["Mozilla VPN"], timeout: 3)
        XCTAssertTrue(app.staticTexts["Mozilla VPN"].exists, "The main page is not loaded correctly")

        // Tap on Get started
        app.buttons["Get started"].tap()

        // Wait for the sing in page and verify that the Email text field is focused
        waitForExistence(app.toolbars["Toolbar"], timeout: 10)
        XCTAssertTrue((app.textFields.element(boundBy: 0).value != nil), "Keybard Focused")
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }

    func testOnboarding() {
        // Wait for main page to load where Mozilla VPN label is shown
        waitForExistence(app.buttons["Learn more"], timeout: 5)
        XCTAssertTrue(app.staticTexts["Mozilla VPN"].exists)

        // Start the onboaring cards
        app.buttons["Learn more"].tap()

        // Wait for the first onboarding card shown
        // Verify the close, skip and page indicator buttons
        waitForExistence(app.staticTexts["Device-level encryption"], timeout: 3)
        XCTAssertTrue(app.buttons["icon close"].exists)
        XCTAssertTrue(app.buttons["Skip"].exists)
        XCTAssertTrue(app.pageIndicators["page 1 of 4"].exists)

        app.staticTexts["Device-level encryption"].swipeLeft()

        // Wait for the second onboarding card shown
        waitForExistence(app.staticTexts["Servers in 30+ countries"], timeout: 3)
        XCTAssertTrue(app.pageIndicators["page 2 of 4"].exists)
        app.staticTexts["Servers in 30+ countries"].swipeLeft()

        // Wait for the third onboarding card shown
        waitForExistence(app.staticTexts["No bandwidth restrictions"], timeout: 3)
        XCTAssertTrue(app.pageIndicators["page 3 of 4"].exists)

        app.staticTexts["No bandwidth restrictions"].swipeLeft()

        // Wait for the final slide showing the get started button
        waitForExistence(app.scrollViews.otherElements.buttons["Get started"], timeout: 3)
        app.scrollViews.otherElements.buttons["Get started"].tap()

        // Wait for the FxASingIn page to be shown
        waitForExistence(app.webViews.textFields["Email"], timeout: 10)
        XCTAssertTrue(app.buttons["Done"].exists)
        XCTAssertTrue(app.buttons["ReloadButton"].exists)
        XCTAssertTrue(app.webViews.textFields["Email"].exists)
    }

    func testSignInAsNonSubscribedUser() {
        // The main screen is shown
        waitForExistence(app.staticTexts["Mozilla VPN"], timeout: 5)
        XCTAssertTrue(app.staticTexts["Mozilla VPN"].exists, "The main page is not loaded correctly")

        // Tap on Get started
        app.buttons["Get started"].tap()

        // Wait for the FxASingIn page to be shown
        waitForExistence(app.webViews.textFields["Email"], timeout: 10)
        app.textFields["Email"].tap()
        app.typeText(nonSubscribedEmail)
        waitForExistence(app.buttons["Continue"], timeout: 20)
        app.buttons["Continue"].firstMatch.tap()

        // Enter the password
        app.secureTextFields["Password"].tap()
        app.typeText(nonSubscribedPassword)
        app.buttons["Sign in"].tap()

        // Verify that a non subscibed VPN user can see the 'Try Mozilla link' message
        waitForExistence(app.staticTexts["Mozilla VPN"], timeout: 15)
        XCTAssertTrue(app.staticTexts["Subscribe to turn on VPN. Try Mozilla VPN"].exists)

        // Go to settings tab
        app.tabBars.buttons["Settings"].tap()

        // Click the signout option
        waitForExistence(app.staticTexts["VPN User"], timeout: 10)
        app.tables.staticTexts["Sign out"].tap()

        // Verify that the user is signed out and is at the home page
        waitForExistence(app.staticTexts["Mozilla VPN"], timeout: 15)
        XCTAssertTrue(app.staticTexts["Mozilla VPN"].exists, "The main page is not loaded correctly")
        }

    func testSignInAsSubscribedUser() {
            // The main screen is shown
            waitForExistence(app.staticTexts["Mozilla VPN"], timeout: 15)
            XCTAssertTrue(app.staticTexts["Mozilla VPN"].exists, "The main page is not loaded correctly")

            // Tap on Get started
            app.buttons["Get started"].tap()
            waitForExistence(app.staticTexts["Use a different account"], timeout: 15)
            app.staticTexts["Use a different account"].tap()

            // Enter an email for a subscribed VPN user
            waitForExistence(app.webViews.textFields["Email"], timeout: 15)

            for _ in 1...nonSubscribedEmail.count {
              // Remove char
              app.textFields["Email"].typeText("\u{0008}")
            }

            app.typeText(subscribedEmail)
            waitForExistence(app.buttons["Continue"], timeout: 10)
            app.buttons["Continue"].tap()

            // Enter the password
            app.secureTextFields["Password"].tap()
            app.typeText(subscribedPassword)
            app.buttons["Sign in"].tap()

            // Verify that a non subscibed VPN user can see the 'Try Mozilla link' message
            waitForExistence(app.staticTexts["Mozilla VPN"], timeout: 10)
            XCTAssertFalse(app.staticTexts["Subscribe to turn on VPN. Try Mozilla VPN"].exists)

            // Verify VPN is turned off
            XCTAssertTrue(app.staticTexts["VPN is off"].exists)
            let switchValue1 = app.otherElements.switches["VpnToggleSwitch"].value!
            XCTAssertEqual(switchValue1 as? String, "0")

            // Turn the VPN On and verify that it's turned on
            app.buttons["VpnToggleButton"].tap()
            waitForExistence(app.staticTexts["VPN is on"], timeout: 15)
            let switchValue2 = app.otherElements.switches["VpnToggleSwitch"].value!
            XCTAssertEqual(switchValue2 as? String, "1")

            // Go to Settings and sign out
            app.tabBars.buttons["Settings"].tap()
            waitForExistence(app.staticTexts["VPN User"], timeout: 10)
            app.tables.staticTexts["Sign out"].tap()

            // Verify that the user is signed out and is at the home page
            waitForExistence(app.staticTexts["Mozilla VPN"], timeout: 15)
            XCTAssertTrue(app.staticTexts["Mozilla VPN"].exists, "The main page is not loaded correctly")

        }
    }
