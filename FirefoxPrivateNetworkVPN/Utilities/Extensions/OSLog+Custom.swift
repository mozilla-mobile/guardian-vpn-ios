//
//  OSLog+Custom
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation
import os.log

enum LogLevel {
    case info
    case debug
    case error

    var osLogType: OSLogType {
        switch self {
        case .info: return .info
        case .debug: return .debug
        case .error: return .error
        }
    }
}

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    private static let generalLog = OSLog(subsystem: subsystem, category: "General")
    private static let uiLog = OSLog(subsystem: subsystem, category: "UI")
    private static let accountLog = OSLog(subsystem: subsystem, category: "Account")
    private static let tunnelLog = OSLog(subsystem: subsystem, category: "Tunnel")

    static func log(path: String = #file, line: Int = #line, function: String = #function, _ level: LogLevel, _ format: String, args: String...) {
        _log(level: level, log: generalLog, message: String(format: "\(format)", arguments: args), path: path, line: line, function: function)
    }

    static func logUI(path: String = #file, line: Int = #line, function: String = #function, _ level: LogLevel, _ format: String, args: String...) {
        _log(level: level, log: uiLog, message: String(format: "\(format)", arguments: args), path: path, line: line, function: function)
    }

    static func logAccount(path: String = #file, line: Int = #line, function: String = #function, _ level: LogLevel, _ format: String, args: String...) {
        _log(level: level, log: accountLog, message: String(format: "\(format)", arguments: args), path: path, line: line, function: function)
    }

    static func logTunnel(path: String = #file, line: Int = #line, function: String = #function, _ level: LogLevel, _ format: String, args: String...) {
        _log(level: level, log: tunnelLog, message: String(format: "\(format)", arguments: args), path: path, line: line, function: function)
    }

    // swiftlint:disable:next function_parameter_count
    private static func _log(level: LogLevel, log: OSLog, message: String, path: String, line: Int, function: String) {
        #if DEBUG
        let file = URL(fileURLWithPath: path).lastPathComponent.split(separator: ".").first ?? ""
        let formatted = String(format: "[\(file):\(line)] <\(function)>: %@", message)
        os_log(level.osLogType, log: log, "%@", formatted)
        #endif
    }
}
