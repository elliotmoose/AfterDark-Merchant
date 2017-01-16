//
//  ColorManager.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 2/1/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import Foundation
import UIKit
class ColorManager
{
    static let deselectedIconColor = UIColor.darkGray
    static let selectedIconColor = UIColor.init(hue: 217/360, saturation: 0.73, brightness: 0.96, alpha: 1)
    
    
    //Global Colors
    static let darkGray = UIColor.init(hue: 0, saturation: 0, brightness: 0.15, alpha: 1)
    static let gold = UIColor.init(hue: 41/360, saturation: 0.7, brightness: 0.63, alpha: 1)
    static let textGray = UIColor(hue: 30/360, saturation: 0, brightness: 0.49, alpha: 1)
    static let themeBright = ColorManager.gold
    static let themeGray = ColorManager.textGray
    static let themeDull = UIColor.init(hue: 44/360, saturation: 0.63, brightness: 0.38, alpha: 1)
}
