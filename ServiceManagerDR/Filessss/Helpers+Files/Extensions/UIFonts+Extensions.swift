//
//  UIFonts+Extensions.swift
//

import UIKit


extension UIFont{
    enum FontType: String {
        case regular = "Regular"
        case bold = "Bold"
        case medium = "Medium"
        case semiBold = "SemiBold"
        case extraBold = "ExtraBold"
        case light = "Light"
        case extraLight = "ExtraLight"
        case italic = "Italic"
        case thin = "Thin"
        case ultraLight = "UltraLight"
        case heavy = "Heavy"
        case black = "Black"
        case condensed = "Condensed"
        case expanded = "Expanded"
        case oblique = "Oblique"
        case book = "Book"
        case demiBold = "DemiBold"
        case ultra = "Ultra"
        case normal = "Normal"
        case demi = "Demi"
        case semiCondensed = "SemiCondensed"
        case semiExpanded = "SemiExpanded"
        case extraCondensed = "ExtraCondensed"
        case extraExpanded = "ExtraExpanded"
        case compressed = "Compressed"
        case wide = "Wide"
        case upright = "Upright"
        case hairline = "Hairline"
        case heavyItalic = "HeavyItalic"
        case semiBoldItalic = "SemiBoldItalic"
        case extraBoldItalic = "ExtraBoldItalic"
        case lightItalic = "LightItalic"
        case extraLightItalic = "ExtraLightItalic"
        case ultraLightItalic = "UltraLightItalic"
        case heavyOblique = "HeavyOblique"
        case semiBoldOblique = "SemiBoldOblique"
        case extraBoldOblique = "ExtraBoldOblique"
        case lightOblique = "LightOblique"
        case extraLightOblique = "ExtraLightOblique"
        case ultraLightOblique = "UltraLightOblique"
        case boldItalic = "BoldItalic"
        case mediumItalic = "MediumItalic"
        case condensedItalic = "CondensedItalic"
        case expandedItalic = "ExpandedItalic"
        // Add more types as needed
    }
    
    enum FontName: String {
        case avenirNext = "AvenirNext"
        case ibmPlexSans = "IBMPlexSans"
        case helvetica = "Helvetica"
        case helveticaNeue = "Helvetica-Neue"
    }
    
    enum FontSize {
//        case small
        case medium
//        case tfPlacehplder
        case large
        case extraLarge
        case huge
        case size14_22
//        case size20_30
//        case size40_60
//        case size30_40
        case size16_25
        case size18_28
//        case size24_34

        func rawValue() -> CGFloat {
            switch self {
//            case .small:
//                return iPad ? 19.0 : 9.0
            case .medium:
                return iPad ? 30.0 : 15.0
            case .large:
                return iPad ? 28.0 : 18.0
            case .extraLarge:
                return iPad ? 32.0 : 22.0
            case .huge:
                return iPad ? 40.0 : 30.0
            case .size14_22:
                return iPad ? 24.0 : 14.0
//            case .size20_30:
//                return iPad ? 30.0 : 20.0
//            case .size30_40:
//                return iPad ? 40.0 : 30.0
//            case .tfPlacehplder:
//                return iPad ? 22.0 : 15.0
//            case .size40_60:
//                return iPad ? 60.0 : 40.0
            case .size16_25:
                return iPad ? 26.0 : 16.0
            case .size18_28:
                return iPad ? 28.0 : 18.0
//            case .size24_34:
//                return iPad ? 34.0 : 24.0
            }
        }
    }

    
    static func font1(forName name: FontName = .helvetica, type: FontType = .regular, size: FontSize = .medium,customSize: CGFloat = 0) -> UIFont {
        let fontName = "\(name.rawValue)-\(type.rawValue)"
        if customSize == 0{
            let font = UIFont(name: fontName, size: size.rawValue())
            return font ?? systemFont(ofSize: size.rawValue(), weight: .regular)
        }
        else{
            let font = UIFont(name: fontName, size: customSize)
            return font ?? systemFont(ofSize: customSize, weight: .regular)
        }
    }
    static func font(forName name: FontName = .ibmPlexSans, type: FontType = .regular, size: FontSize = .medium,customSize: CGFloat = 0) -> UIFont {
        let fontName = "\(name.rawValue)-\(type.rawValue)"
        if customSize == 0{
            let font = UIFont(name: fontName, size: size.rawValue())
            return font ?? systemFont(ofSize: size.rawValue(), weight: .regular)
        }
        else{
            let font = UIFont(name: fontName, size: customSize)
            return font ?? systemFont(ofSize: customSize, weight: .regular)
        }
    }
    

    static func font_size(forName name: FontName = .helvetica, type: FontType = .bold, size: CGFloat) -> UIFont{
        let fontName = "\(name.rawValue)-\(type.rawValue)"
            let font = UIFont(name: fontName, size: size.adaptedFontSize)
            return font ?? systemFont(ofSize: size.adaptedFontSize, weight: .regular)
    }
}
