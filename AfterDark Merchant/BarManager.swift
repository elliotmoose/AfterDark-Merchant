//
//  BarManager.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 16/12/16.
//  Copyright © 2016 Kohbroco. All rights reserved.
//

import Foundation
import UIKit
class BarManager
{
    static let singleton = BarManager()
    
    //========================================================================================================
    //                                          load bar functions
    //========================================================================================================
    
    func ReloadBar(handler: @escaping (_ success : Bool)->Void)
    {
        BarManager.singleton.LoadMerchantBar(ID: Account.singleton.Merchant_Bar_ID!, handler: {
            (success,error,merchantBar) -> Void in
            if success
            {
                Account.singleton.Merchant_Bar = merchantBar
                
                //in case its in edit, update display
                EditProfileViewController.singleton.LoadUpdatingBarFromAccounts()
                EditProfileViewController.singleton.DisplayUpdatingBar()
                
                handler(true)
            }
            else
            {
                print(error)
                handler(false)
            }
        })
    }
    
    
    func LoadMerchantBar(ID : String, handler: @escaping (_ success : Bool,_ error :String, _ bar : Bar) -> Void)
    {
        let url = Network.clientDomain + "ReloadBarData.php?Bar_ID=\(ID)"
        //generic data -> reviews discounts -> gallery
        
        Network.singleton.DataFromUrl(url, handler: {
            (success,output) -> Void in
            if success
            {
                if let output = output
                {
                    do
                    {
                        let dict = try JSONSerialization.jsonObject(with: output, options: .allowFragments) as! NSDictionary
                        
                        
                        let success = dict["success"] as? String
                        
                        guard success != nil else {return}
                        
                        if success == "true"
                        {
                            //then detail is another dict
                            if let detailDict = dict["detail"] as? NSDictionary
                            {
                                handler(true,"",BarManager.singleton.NewBarFromDict(detailDict))
                            }
                            else
                            {
                                handler(false,"",Bar())
                            }
                            
                        }
                        else
                        {
                            let detailString = dict["detail"] as? String
                            
                            guard detailString != nil else {return}
                            handler(false,detailString!,Bar())
                            
                        }
                    }
                    catch let error as NSError
                    {
                        NSLog(error.description)
                    }
                }
            }
            
        })
        
     
        //load max image count 
        let maxImageCountUrl = Network.domain + "GetNumberOfImages.php"
        
        //load max count
        Network.singleton.DataFromUrl(maxImageCountUrl) { (success, output) in
            if success
            {
                if let output = output
                {
                    //incomplete
                }
                else
                {
                    
                }
            }
            else
            {
                
            }
        }
        
        let loadImageUrl = Network.domain + "AfterDarkServer/GetBarGalleryImage.php?Bar_ID=0&Image_Index="
    }

    
    func NewBarFromDict(_ dict: NSDictionary) ->Bar
    {
        
        var errors = [String]();
        
        let newBar = Bar()
        
        let ratingAvg = dict.value(forKey: "Bar_Rating_Avg") as? Float
        let ratingPrice = dict.value(forKey: "Bar_Rating_Price") as? Float
        let ratingAmbience = dict.value(forKey: "Bar_Rating_Ambience") as? Float
        let ratingFood = dict.value(forKey: "Bar_Rating_Food") as? Float
        let ratingService = dict.value(forKey: "Bar_Rating_Service") as? Float
        
        
        
        if let name = dict["Bar_Name"] as? String
        {
            newBar.name = name
        }
        else
        {
            errors.append("Bar has no Name")
        }
        
        
        if let ID = dict["Bar_ID"] as? Int
        {
            newBar.ID = String(describing: ID)
        }
        
        if let iconString = dict["Bar_Icon"] as? String
        {
            let dataDecoded:Data = Data(base64Encoded: iconString, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
            let icon = UIImage(data: dataDecoded)
            newBar.icon = icon
        }
        else
        {
            errors.append("no icon in dict")
        }
        
        if let description = dict["Bar_Description"] as? String
        {
            newBar.description = description
        }
        
        if let contact = dict["Bar_Contact"] as? String
        {
            newBar.contact = contact
        }
        
        if let tags = dict["Bar_Tags"] as? String
        {
            newBar.tags = tags
        }
        
        //get opening hours
        if let monday = dict["OH_Monday"] as? String
        {
            newBar.openClosingHours[0] = monday
        }
        
        if let tuesday = dict["OH_Tuesday"] as? String
        {
            newBar.openClosingHours[1] = tuesday
        }
        
        if let wednesday = dict["OH_Wednesday"] as? String
        {
            newBar.openClosingHours[2] = wednesday
        }
        
        if let thursday = dict["OH_Thursday"] as? String
        {
            newBar.openClosingHours[3] = thursday
        }
        
        if let friday = dict["OH_Friday"] as? String
        {
            newBar.openClosingHours[4] = friday
        }
        
        if let saturday = dict["OH_Saturday"] as? String
        {
            newBar.openClosingHours[5] = saturday
        }
        
        if let sunday = dict["OH_Sunday"] as? String
        {
            newBar.openClosingHours[6] = sunday
        }
        
        if let loc_lat = dict["Bar_Location_Latitude"] as? String
        {
            newBar.loc_lat = Double(loc_lat)!
        }
        else if let loc_lat = dict["Bar_Location_Latitude"] as? Double
        {
            newBar.loc_lat = loc_lat

        }
        
        if let loc_long = dict["Bar_Location_Longitude"] as? String
        {
            newBar.loc_long = Double(loc_long)!
        }
        else if let loc_long = dict["Bar_Location_Longitude"] as? Double
        {
            newBar.loc_long = loc_long
            
        }
        
        if let address = dict["Bar_Address"] as? String
        {
            newBar.address = address
        }
        
        if let bookingAvailable = dict.value(forKey: "Booking_Available") as? Int
        {
            newBar.bookingAvailable = String(describing: bookingAvailable)
        }
        
        if let website = dict["Bar_Website"] as? String
        {
            newBar.website = website
        }
        
        if ratingAvg != nil && ratingPrice != nil && ratingAmbience != nil && ratingFood != nil && ratingService != nil
        {
            newBar.rating.InjectValues(ratingAvg!, pricex: ratingPrice!, ambiencex:ratingAmbience!,foodx: ratingFood!, servicex: ratingService!)
        }
        else
        {
            errors.append("no rating in this dict")
        }
        
        if errors.count != 0
        {
            NSLog(errors.joined(separator: "\n"))
        }
        
        
        return newBar
    }

}
