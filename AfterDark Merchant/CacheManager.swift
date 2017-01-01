//
//  CacheManager.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 1/1/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import Foundation
class CacheManager
{
    static let singleton = CacheManager()
    let UD = UserDefaults.standard
    init()
    {
        
    }
    
    func SaveUsername(username : String)
    {
        UD.set(username, forKey: "rememberMeUsername")
    }

    func RememberMeUsername() -> String?
    {
        return UD.value(forKey: "rememberMeUsername") as? String
    }

}
