import Foundation
import UIKit

class Sizing
{
    
    static let singleton = Sizing()
    
    
    //bar blown up dimensions

    static let minGalleryHeight = Sizing.ScreenHeight()/3
    static let maxGalleryHeight = Sizing.ScreenHeight()/2
    
    static let mainViewHeight = Sizing.ScreenHeight() - Sizing.minGalleryHeight - Sizing.tabBarHeight - Sizing.statusBarHeight - Sizing.navBarHeight
    static let tabHeight = Sizing.HundredRelativeHeightPts()/3

    
    
    //system dimensions
    static let tabBarHeight : CGFloat = 49
    static let statusBarHeight : CGFloat = 20
    static let navBarHeight : CGFloat = 44
    
    
    static let discountCellHeight : CGFloat = 60
    
    //collection view
    static let itemInsetFromEdge : CGFloat = 6
    static let itemWidth = Sizing.ScreenWidth() - itemInsetFromEdge*2
    static let itemHeight = Sizing.ScreenHeight()/2.5
    static let itemCornerRadius: CGFloat = 7
    static let sectionHeaderHeight : CGFloat = 40
    
    
    
    
    //static functions
    class func HundredRelativeWidthPts()->CGFloat
    {
    	return 375/UIScreen.main.bounds.size.width*100
    } 

    class func HundredRelativeHeightPts()->CGFloat
    {
    	return 667/UIScreen.main.bounds.size.height*100
    }

    class func ScreenWidth()->CGFloat
    {
        return UIScreen.main.bounds.size.width
    }

    class func ScreenHeight()->CGFloat
    {
        return UIScreen.main.bounds.size.height
    }

    
}
