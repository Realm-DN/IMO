//
//  UIColor+Extensions.swift
//

import UIKit
import Foundation


extension UIColor {
    static let darkBlue7D95BA = UIColor(named: "DarkBlue")
    static let lightBlue9CB0D0 = UIColor(named: "LightBlue")
    static let lightSkyCBE9FF = UIColor(named: "LightSky")
    static let doubleLightBlueDBEBFF = UIColor(named: "DoubleLightBlue")
    static let mediumBlueC1D4FF = UIColor(named: "MediumBlue")
    static let doubleMediumBlueC1DDFF = UIColor(named: "DoubleMediumBlue")
    static let lightDarkBlueAACCF4 = UIColor(named: "LightDarkBlue")
    static let darkSkyA6E4FD = UIColor(named: "DarkSky")
    static let mediumOrangeFCF4EA = UIColor(named: "MediumOrange")
    static let orangeF2E5D3 = UIColor(named: "Orange")
    static let lightOrangeF2EBE1 = UIColor(named: "LightOrange")
    static let greyBlueA7A7C6 = UIColor(named: "GreyBlue")
    static let lightWhiteF8F8FF = UIColor(named: "LightWhite")
    static let whiteOrangeF8EBDA = UIColor(named: "WhiteOrange")
    static let darkGreyBlue7979A8 = UIColor(named: "DarkGreyBlue")
    static let lightGreyBlueC9C9CE = UIColor(named: "LightGreyBlue")
    static let soothsayerBlue7D95BA = UIColor(named: "soothsayerBlue")
    static let babyBlueE3F5FF = UIColor(named: "BabyBlue")
    
    convenience init(_ hex: String) {
           let hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
           let hexValue = hexFormatted.hasPrefix("#") ? String(hexFormatted.dropFirst()) : hexFormatted
           
           guard hexValue.count == 6, let rgbValue = UInt64(hexValue, radix: 16) else {
               self.init(white: 0.5, alpha: 1.0) // Return gray color for invalid hex input
               return
           }
           
           self.init(
               red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
               green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
               blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
               alpha: 1.0
           )
       }
    
}

struct AppColor{
    static let  kAppColor = UIColor(named: "AppColor")
    static let link = UIColor(hexString: "#410ADF")
}


extension UIColor {
    convenience init?(hexString: String) {
        var formattedString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        formattedString = formattedString.replacingOccurrences(of: "#", with: "")
        
        var hexValue: UInt64 = 0
        guard Scanner(string: formattedString).scanHexInt64(&hexValue) else {
            return nil
        }
        
        let red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hexValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}

// MARK: - UIColor Extension
extension UIColor {
    static func randomNonWhite() -> UIColor {
        var color: UIColor
        repeat {
            color = UIColor(
                hue: .random(in: 0...1),
                saturation: .random(in: 0.5...1),
                brightness: .random(in: 0...0.8),
                alpha: 1.0
            )
        } while color.isTooBright
        return color
    }
    
    private var isTooBright: Bool {
        var brightness: CGFloat = 0
        getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        return brightness > 0.9
    }
}
