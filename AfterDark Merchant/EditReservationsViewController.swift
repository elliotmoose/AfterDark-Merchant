//
//  EditReservationsViewController.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 22/12/16.
//  Copyright © 2016 Kohbroco. All rights reserved.
//

import UIKit

class EditReservationsViewController: UIViewController {

    static let singleton = EditReservationsViewController(nibName: "EditReservationsViewController", bundle: Bundle.main)
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        Bundle.main.loadNibNamed(nibNameOrNil!, owner: self, options: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
