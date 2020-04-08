//
//  ReleaseInfoSpec
//  FirefoxPrivateNetworkVPNTests
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation
import Quick
import Nimble
@testable import Firefox_Private_Network_VPN

//swiftlint:disable implicitly_unwrapped_optional
class ReleaseInfoSpec: QuickSpec {

    override func spec() {
        describe("ReleaseInfo") {

            var sut: ReleaseInfo!

            describe("its status") {

                context("when the current version matches both the latest version and the minimum version") {

                    it("is none") {
                        let version = "1.0.0"
                        sut = ReleaseInfo(latestVersion: version, minimumVersion: version, dateRetrieved: Date())

                        let status = sut.getUpdateStatus(of: version)
                        expect(status).to(equal(UpdateStatus.none))
                    }
                }

                context("when the current version matches the latest version and is greater than the minimum version") {

                    it("is none") {
                        sut = ReleaseInfo(latestVersion: "1.0.1", minimumVersion: "1.0.0", dateRetrieved: Date())

                        let status = sut.getUpdateStatus(of: "1.0.1")
                        expect(status).to(equal(UpdateStatus.none))
                    }
                }

                context("when the current version matches the latest version and is less than the minimum version") {

                    it("is required") {
                        sut = ReleaseInfo(latestVersion: "1", minimumVersion: "1.0.1", dateRetrieved: Date())

                        let status = sut.getUpdateStatus(of: "1.0")
                        expect(status).to(equal(UpdateStatus.required))
                    }
                }

                context("when the current version is less than the latest version and equal to the minimum version") {

                    it("is available") {
                        sut = ReleaseInfo(latestVersion: "6.6", minimumVersion: "6.5.9", dateRetrieved: Date())

                        let status = sut.getUpdateStatus(of: "6.5.9")
                        expect(status).to(equal(UpdateStatus.optional))
                    }
                }

                context("when the current version is less than both the latest version and the minimum version") {

                    it("is required") {
                        sut = ReleaseInfo(latestVersion: "2.2", minimumVersion: "2.1", dateRetrieved: Date())

                        let status = sut.getUpdateStatus(of: "2.0.2")
                        expect(status).to(equal(UpdateStatus.required))
                    }
                }

                context("when the current version is less than the latest version and is greater than the minimum version") {

                    it("is available") {
                        sut = ReleaseInfo(latestVersion: "2.2", minimumVersion: "1.1", dateRetrieved: Date())

                        let status = sut.getUpdateStatus(of: "2.0.0")
                        expect(status).to(equal(UpdateStatus.optional))
                    }
                }

                context("when the current version is greater than both the latest version and the minimum version") {

                    it("is none") {
                        sut = ReleaseInfo(latestVersion: "1.5.20", minimumVersion: "1.9", dateRetrieved: Date())

                        let status = sut.getUpdateStatus(of: "2.5.20")
                        expect(status).to(equal(UpdateStatus.none))
                    }
                }

                context("when the current version is greater than the latest version and matches the minimum version") {

                    it("is none") {
                        sut = ReleaseInfo(latestVersion: "1.5", minimumVersion: "7", dateRetrieved: Date())

                        let status = sut.getUpdateStatus(of: "7.0")
                        expect(status).to(equal(UpdateStatus.none))
                    }
                }

                context("when the current version is greater than the latest version and less than the minimum version") {

                    it("is required") {
                        sut = ReleaseInfo(latestVersion: "2.2", minimumVersion: "v13.0.0", dateRetrieved: Date())

                        let status = sut.getUpdateStatus(of: "12.0")
                        expect(status).to(equal(UpdateStatus.required))
                    }
                }
            }
        }
    }
}
