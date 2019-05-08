//
//  gradientLayer.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 04/05/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import UIKit


public class Gradient {
public func setGradient (view: UIView) -> CAGradientLayer {
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [
        UIColor(red: 0.35, green: 0.34, blue: 0.84, alpha: 1).cgColor,
        UIColor(red: 0.35, green: 0.34, blue: 0.84, alpha: 1).cgColor,
        UIColor(red: 0, green: 0.48, blue: 1, alpha: 1).cgColor,
        UIColor(red: 0.35, green: 0.78, blue: 0.98, alpha: 1).cgColor
    ]
    gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
    gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: -1, c: 2.17, d: 0, tx: -0.58, ty: 1))
    gradientLayer.frame = view.bounds.insetBy(dx: -0.5*view.bounds.size.width, dy: -0.5*view.bounds.size.height)
    gradientLayer.position = view.center
    gradientLayer.locations = [0, 0, 0.54, 1]
    return gradientLayer
}
}
