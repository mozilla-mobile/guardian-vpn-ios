//
//  UIImage+Color
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

#if os(iOS)

import UIKit

// https://gist.github.com/isoiphone/031da3656d69c0d85805
extension UIImage {
    class func image(with color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}

#elseif os(macOS)

import AppKit

extension NSImage {
    class func image(with color: NSColor, size: CGSize = CGSize(width: 1, height: 1)) -> NSImage {
        let image = NSImage(size: size)
        let context = NSGraphicsContext.current?.cgContext
        let rect = CGRect(origin: CGPoint.zero, size: size)
        image.lockFocus()
        context?.clear(rect)
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        image.unlockFocus()

        return image
    }
}

#endif
