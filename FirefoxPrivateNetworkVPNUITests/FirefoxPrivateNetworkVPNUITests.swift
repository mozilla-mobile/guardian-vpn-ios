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

class FirefoxPrivateNetworkVPNUITests: BaseTestCase {

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // UI tests must launch the application that they test.
        app.launch()
        waitForExistence(app.staticTexts["Mozilla VPN"], timeout: 3)
        XCTAssertTrue(app.staticTexts["Mozilla VPN"].exists, "The main page is not loaded correctly")
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
        // XCTAssertTrue(app.pageIndicators["page 1 of 4"].exists)

        app.staticTexts["Device-level encryption"].swipeLeft()

        // Wait for the second onboarding card shown
        waitForExistence(app.staticTexts["Servers in 30+ countries"], timeout: 3)
        // XCTAssertTrue(app.pageIndicators["page 2 of 4"].exists
        app.staticTexts["Servers in 30+ countries"].swipeLeft()

        // Wait for the third onboarding card shown
        waitForExistence(app.staticTexts["No bandwidth restrictions"], timeout: 3)
        // XCTAssertTrue(app.pageIndicators["page 3 of 4"].exists)

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
}
