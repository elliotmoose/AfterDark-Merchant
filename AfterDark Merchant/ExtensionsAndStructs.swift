//
//  ExtensionsAndStructs.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 16/12/16.
//  Copyright © 2016 Kohbroco. All rights reserved.
//

import Foundation

extension String{
    public func AddPercentEncodingForURL(plusForSpace : Bool = false) -> String?
    {
        let unreserved = "*-._"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        
        if plusForSpace
        {
            allowed.addCharacters(in: " ")
        }
        
        var encoded = addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
        
        if plusForSpace
        {
            encoded = encoded?.replacingOccurrences(of: " ", with: "+")
        }
        
        
        
        return encoded
        
    }
}
