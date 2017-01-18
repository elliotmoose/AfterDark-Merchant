//
//  InitialViewController.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 18/1/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    
    static let singleton = InitialViewController(nibName: "InitialViewController", bundle: Bundle.main)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        Bundle.main.loadNibNamed(nibNameOrNil!, owner: self, options:nil)
        
        Account.singleton.Load()

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()



    }
    
    override func viewWillAppear(_ animated: Bool) {
        //step 1: check log in
        //login page
        var loggedIn = false //this is so that we can initialize before we load data in
        
        if Account.singleton.Merchant_username == "" || Account.singleton.Merchant_username == nil
        {
            loggedIn = false
        }
        else
        {
            loggedIn = true
        }
        
        
        
//        //dummy app
//        guard Settings.dummyAppOn == false else {
//            PresentMainRootViewCont()
//            return
//        }
        
        if loggedIn
        {
            //step 2: if logged in, start loading (else log in page)
            self.hasLoggedIn()
        }
        else
        {
            if Settings.bypassLoginPage == false
            {
                PresentLoginViewCont()
            }
        }

    }
    func PresentLoginViewCont()
    {
        DispatchQueue.main.async {
            let window = UIApplication.shared.delegate?.window!!
            window?.rootViewController = LoginViewController.singleton
        }
    }
    
    
    func hasLoggedIn() {
    
        self.PresentMainRootViewCont()
    }
    

    
    
    func PresentMainRootViewCont()
    {
        DispatchQueue.main.async {
            let window = UIApplication.shared.delegate?.window!!
            window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
        }
    }
    



}
