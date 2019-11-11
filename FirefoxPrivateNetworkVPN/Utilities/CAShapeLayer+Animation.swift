//
//  CAShapeLayer+Animation
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

extension CAShapeLayer {
    func addPulse(delay: CFTimeInterval) {
    let circlePath = UIBezierPath(arcCenter: .zero,
                                   radius: 60,
                                   startAngle: 0,
                                   endAngle: 2 * CGFloat.pi,
                                   clockwise: true)

        fillColor = UIColor.clear.cgColor
        strokeColor = UIColor.white.cgColor
        lineWidth = 5
        opacity = 0.0
        path = circlePath.cgPath

        let expandAnimation = CABasicAnimation(keyPath: "transform.scale")
        expandAnimation.duration = 6
        expandAnimation.toValue = 2.07
        expandAnimation.beginTime = CACurrentMediaTime() + delay
        expandAnimation.repeatCount = .infinity

        let lineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        lineWidthAnimation.duration = 6
        lineWidthAnimation.toValue = 1
        lineWidthAnimation.beginTime = CACurrentMediaTime() + delay
        lineWidthAnimation.repeatCount = .infinity

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = 6
        opacityAnimation.fromValue = 0.12
        opacityAnimation.toValue = 0.0
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        opacityAnimation.beginTime = CACurrentMediaTime() + delay
        opacityAnimation.repeatCount = .infinity

        add(expandAnimation, forKey: "expand")
        add(opacityAnimation, forKey: "opacity")
        add(lineWidthAnimation, forKey: "linewidth")
    }
}
