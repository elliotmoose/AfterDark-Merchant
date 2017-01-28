//
//  customCollectionViewLayout.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 19/1/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import UIKit

class customCollectionViewLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()
        self.scrollDirection = UICollectionViewScrollDirection.horizontal
        //self.minimumLineSpacing = 100000
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.scrollDirection = UICollectionViewScrollDirection.horizontal
        //self.minimumLineSpacing = 100000
    }

}
