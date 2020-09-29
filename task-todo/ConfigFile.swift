
import Foundation
import UIKit

// Configuration

// To Enable or Disable Admob
let admobEnable = false
// Admob App ID
let admobAppId = ""
// Admob banner Ad Unit
let admobAdUnit = ""
// interstitial ads
let interAds = ""

// Base Color (Example : UIColor(netHex: 0x4D73EC) )
let baseColor = UIColor(netHex: 0x7D0633)

// Done & TODO Status Color
let todoColor = UIColor(netHex: 0xE43f5A)
let doneColor = UIColor(netHex: 0x00909E)

// Navigation Bar Color
let navigationBarTintColor = UIColor.white

// TabBar Tint Color
let tabBarTintColor = baseColor

// Category TODO
let categoryList = ["Shopping","Home","Work","School","Date","Others"]

// font medium
let font18base = UIFont(name: "SFUIText-Medium", size: 18)
let font34base = UIFont(name: "SFUIText-Medium", size: 34)

// font regular
let font16regular = UIFont(name: "SFUIText-Regular", size: 16)
let font18regular = UIFont(name: "SFUIText-Regular", size: 18)
let font34regular = UIFont(name: "SFUIText-Regular", size: 34)





extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
