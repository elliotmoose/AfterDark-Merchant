//
//  MenuViewController.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 7/12/16.
//  Copyright © 2016 Kohbroco. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var tableView : UITableView?

    //========================================================================================================
    //                                          View did something
    //========================================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()

        //table view init
        self.tableView = UITableView(frame: self.view.frame, style: .plain)
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.view.addSubview(tableView!)
        
        //nav and tab bar init
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        self.navigationController?.navigationBar.tintColor = ColorManager.themeBright
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.barStyle = .black;
        self.tabBarController?.tabBar.tintColor = ColorManager.themeBright
        self.tabBarController?.tabBar.barTintColor = UIColor.black
        
        self.title = "Menu"

        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Mohave", size: 20)!,NSForegroundColorAttributeName : ColorManager.themeBright]
    }

    override func viewDidAppear(_ animated: Bool) {
        
        //if bar is not loaded
        if Account.singleton.Merchant_Bar == nil
        {
            //if logged in, load bar details
            if Account.singleton.Merchant_Bar_ID != nil && Account.singleton.Merchant_username != nil && Account.singleton.Merchant_Bar_ID != "" && Account.singleton.Merchant_username != ""
            {
                self.BeginLoadBar()
            }
            else
            {
                //PopupManager.singleton.Popup(title: "HMM", body: "not logged in", presentationViewCont: self)
                print("ERROR: log in not complete, logging out")
                
                Account.singleton.LogOut()
                
                LoginViewController.singleton.Present()
            }
        }
        
        
        
        
    }
    //========================================================================================================
    //                                          own functions
    //========================================================================================================
    func BeginLoadBar()
    {
        BarManager.singleton.ReloadBar(handler: {
            (success) -> Void in
            
            //load discounts
            if success
            {
                DiscountManager.singleton.LoadDiscountsForBar()
            }
            
        })
      
    }
    

    
    
    //========================================================================================================
    //                                      table view functions
    //========================================================================================================
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
     {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")

        if cell == nil
        {
            cell = UITableViewCell()
        }
        
        cell?.accessoryType = .disclosureIndicator
        
        
        switch indexPath
        {
        case IndexPath(row: 0, section: 0):
            cell?.textLabel?.text = "Manage Bar Profile"
        case IndexPath(row: 2, section: 0):
            cell?.textLabel?.text = "Manage Bar Reservations"
        case IndexPath(row: 1, section: 0):
            cell?.textLabel?.text = "Manage Bar Discounts"
        default:
            break
        }
        

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        switch indexPath
        {
        case IndexPath(row: 0, section: 0):            
            self.navigationController?.pushViewController(EditProfileViewController.singleton, animated: true)
            EditProfileViewController.singleton.ViewWillAppearFromMenu()
        case IndexPath(row: 2, section: 0):
            self.navigationController?.pushViewController(EditReservationsViewController.singleton, animated: true)
        case IndexPath(row: 1, section: 0):
            self.navigationController?.pushViewController(EditDiscountsViewController.singleton, animated: true)
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    
}
