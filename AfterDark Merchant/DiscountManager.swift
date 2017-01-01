//
//  DiscountManager.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 22/12/16.
//  Copyright © 2016 Kohbroco. All rights reserved.
//

import Foundation

class DiscountManager
{
    static let singleton = DiscountManager()
    
    init() {
        
    }
    
    func LoadDiscountsForBar()
    {
        //step 1: check if is logged in 
        
        guard Account.singleton.Merchant_username != nil && Account.singleton.Merchant_username != "" && Account.singleton.Merchant_Bar != nil && Account.singleton.Merchant_Bar_ID != nil && Account.singleton.Merchant_Bar_ID != "" else {print("not logged in or no bar loaded yet, cant load discounts");return}
        
        
        //step 2: load from url
        let url = Network.domain + "GetDiscountsForBar.php?Bar_ID=\(Account.singleton.Merchant_Bar_ID!)"
        Network.singleton.DataFromUrl(url, handler: {
            (success,output) -> Void in
            
            if success
            {
                //data should be dict (success,detail)  where detail = [Dictionary] (discounts)
                do
                {
                    if let dict = try JSONSerialization.jsonObject(with: output!, options: .allowFragments) as? NSDictionary
                    {
                        
                        if let success = dict["success"] as? String
                        {
                            if success == "true"
                            {
                                if let discountDictArray = dict["detail"] as? [NSDictionary]
                                {
                                    //reset discounts
                                    Account.singleton.Merchant_Bar?.discounts.removeAll()
                                    
                                    for discountDict in discountDictArray
                                    {
                                        //create new discount from dict
                                        let newDiscount = Discount(dict: discountDict)
                                        //add discount
                                        Account.singleton.Merchant_Bar?.discounts.append(newDiscount)
                                    }
                                    
                                    //update UI
                                    EditDiscountsViewController.singleton.UpdateDiscountList()
                                }
                            }
                            else
                            {
                                if let detail = dict["detail"] as? String
                                {
                                    print(detail)
                                }
                            }
                            
                            
                        }

                    }
                    
                    
                }
                catch let error as NSError
                {
                    print("Error during discount load: \(error)")
                }
                
            }
            else
            {
                print("failed to load discounts")
            }
            
        })
    }
}
