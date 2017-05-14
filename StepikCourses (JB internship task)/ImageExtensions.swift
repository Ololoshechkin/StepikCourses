//
//  extensions.swift
//  StepikCourses (JB internship task)
//
//  Created by Vadim on 12.05.17.
//  Copyright © 2017 Vadim. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {
    
    func getRGBInCGFloat() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
    
    func getRGB() -> (red: Float, green: Float, blue: Float, alpha: Float) {
        let (red, green, blue, alpha) = getRGBInCGFloat()
        return (Float(red), Float(green), Float(blue), Float(alpha))
    }
    
    func isDark() -> Bool {
        let (red, green, blue, _) = getRGB()
        let koeff = 0.3 * red + 0.6 * green + 0.1 * blue
        return koeff < 0.5
    }
    
    func inverted() -> UIColor {
        let (red, green, blue, alpha) = getRGBInCGFloat()
        return UIColor(
            red: CGFloat(1.0) - red,
            green: CGFloat(1.0) - green,
            blue: CGFloat(1.0) - blue,
            alpha: alpha
        )
    }

}

extension UIImage {
    
    private func getAverageColor(fromX x0: Int, toX x1: Int, fromY y0: Int, toY y1: Int)
        -> UIColor {
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        var R = CGFloat(0.0)
        var G = CGFloat(0.0)
        var B = CGFloat(0.0)
        var A = CGFloat(0.0)
        let pixelsCnt = CGFloat((x1 - x0) * (y1 - y0))
        for x in x0..<x1 {
            for y in y0..<y1 {
                let pixelInfo: Int = ((Int(self.size.width) * y) + x) * 4
                R += CGFloat(data[pixelInfo]) / CGFloat(255.0)
                G += CGFloat(data[pixelInfo + 1]) / CGFloat(255.0)
                B += CGFloat(data[pixelInfo + 2]) / CGFloat(255.0)
                A += CGFloat(data[pixelInfo + 3]) / CGFloat(255.0)
            }
        }
        R /= pixelsCnt
        G /= pixelsCnt
        B /= pixelsCnt
        A /= pixelsCnt
        return UIColor(red: R, green: G, blue: B, alpha: A)
    }
    
    func getAverageColor() -> UIColor  {
        return getAverageColor(
            fromX: 0,
            toX: Int(size.width),
            fromY: 0,
            toY: Int(size.height)
        )
    }
    
    func getPixelColor(x: CGFloat, y: CGFloat) -> UIColor {
        return getAverageColor(
            fromX: Int(x),
            toX: Int(x),
            fromY: Int(y),
            toY: Int(y)
        )
    }
    
    func getRightSideColor() -> UIColor {
        return getAverageColor(
            fromX: Int(size.width) - 2,
            toX: Int(size.width) - 1,
            fromY: 0,
            toY: Int(size.height)
        )
    }
    
}
