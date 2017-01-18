//
//  AccountTableViewController.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 6/12/16.
//  Copyright © 2016 Kohbroco. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    static let singleton = AccountViewController()
    
    var tableView : UITableView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: self.view.frame,style: .grouped)

        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.view.addSubview(tableView!)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = ColorManager.themeBright
    }
    
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil
        {
            cell = UITableViewCell()
        }
        
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            cell?.textLabel?.text = "Log Out"
        default:
            break
        }
        
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            
            PopupManager.singleton.PopupWithCancel(title: "Log Out", body: "Are you sure you want to log out?", presentationViewCont: self, handler: {
            
                //log out back end
                Account.singleton.LogOut()
                
                //push login page
                LoginViewController.singleton.Present()
                
            })
            

        default:
            break
        }
    
    
            tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
