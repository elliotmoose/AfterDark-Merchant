//
//  Discount.swift
//  AfterDark
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 1/11/16.
//  Copyright © 2016 kohbroco. All rights reserved.
//

import Foundation

class Discount
{
    var name : String?
    var details : String?
    var amount : String?
    var discount_ID : String?
    var bar_ID : String?

    init(dict : NSDictionary)
    {
        name = dict["discount_name"] as? String
        details = dict["discount_description"] as? String
        discount_ID = String(describing: dict["discount_ID"] as! Int)
        bar_ID = String(describing: (dict["Bar_ID"] as? Int)!)
        amount = dict["discount_amount"] as? String
    }
    
    init(name : String, details:String , amount : String, discountID : String, bar_ID: String)
    {
        self.name = name
        self.details = details
        self.amount = amount
        self.discount_ID = discountID
        self.bar_ID = bar_ID
    }
}
