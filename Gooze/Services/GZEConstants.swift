//
//  GZEConstants.swift
//  Gooze
//
//  Created by Yussel on 11/20/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

class GZEConstants {

    static var horizontalSize: UIUserInterfaceSizeClass = .unspecified {
        didSet {
            log.debug("horizontalSize set: \(GZEConstants.horizontalSize)")
        }
    }
    static var verticalSize: UIUserInterfaceSizeClass = .unspecified {
        didSet {
            log.debug("verticalSize set: \(GZEConstants.verticalSize)")
        }
    }

    class Color {
        static let mainBackground = UIColor(red: 55/255, green: 56/255, blue: 61/255, alpha: 1.0)
        static let timeSliderBackground = UIColor(red: 55/255, green: 56/255, blue: 61/255, alpha: 0.59)

        // Next button, button border
        static let mainGreen = UIColor(red: 46/255, green: 206/255, blue: 175/255, alpha: 1.0)

        static let buttonBackground = UIColor(white: 77/255, alpha: 1.0) // also photo placeholders background
        static let buttonToggledBackground = UIColor(white: 57/255, alpha: 1.0)

        static let distanceSliderBackground = UIColor(white: 1.0, alpha: 0.51)

        static let textInputPlacehoderOnEdit = UIColor(white: 115/255, alpha: 1.0) // text input placehoder when editing text

        static let mainTextColor = UIColor.white

        static let validationErrorViewBg = UIColor(white: 0.6, alpha: 0.95)
        
        //Chat
        static let chatBubbleTextColor = UIColor.black

        static let pinColor = UIColor(red: 46/255, green: 185/255, blue: 154/255, alpha: 1.0)

        // Text field Validation
        static let errorMessage = UIColor(red: 255/255, green: 102/255, blue: 102/255, alpha: 1.0)
    }

    // Fonts
    // Slider km Helvetica Neue Regular 21.44 pt
    // Buttons Helvetica Neue UltraLight 33.16 pt
    class Font {
        static var main: UIFont {
            if GZEConstants.horizontalSize == .compact {
                log.debug("using compact font")
                return UIFont(name: "HelveticaNeue", size: 13)!
            } else {
                log.debug("using regular font")
                return UIFont(name: "HelveticaNeue", size: 17)!
            }
        }

        static var mainBig: UIFont {
            if GZEConstants.horizontalSize == .compact {
                log.debug("using compact font")
                return UIFont(name: "HelveticaNeue", size: 18)!
            } else {
                log.debug("using regular font")
                return UIFont(name: "HelveticaNeue", size: 22)!
            }
        }

        static var mainSuperBig: UIFont {
            if GZEConstants.horizontalSize == .compact {
                log.debug("using compact font")
                return UIFont(name: "HelveticaNeue", size: 30)!
            } else {
                log.debug("using regular font")
                return UIFont(name: "HelveticaNeue", size: 36)!
            }
        }

        static var mainAwesome: UIFont {
            if GZEConstants.horizontalSize == .compact {
                log.debug("using compact font")
                return UIFont(name: "FontAwesome", size: 13)!
            } else {
                log.debug("using regular font")
                return UIFont(name: "FontAwesome", size: 17)!
            }
        }
    }
}
