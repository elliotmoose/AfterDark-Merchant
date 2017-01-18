//
//  SettingsTableViewController.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 6/12/16.
//  Copyright © 2016 Kohbroco. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = ColorManager.themeBright
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.barStyle = .black;
        
        self.title = "Settings"
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Mohave", size: 20)!,NSForegroundColorAttributeName : ColorManager.themeBright]
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")

        // Configure the cell...
        if cell == nil
        {
            cell = UITableViewCell()
        }
        
        cell?.accessoryType = .disclosureIndicator
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            cell?.textLabel?.text = "Account"
//        case IndexPath(row: <#T##Int#>, section: <#T##Int#>):
//            <#code#>
    
        default:
            cell?.textLabel?.text = "oops"
        }
        
        return cell!
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            self.navigationController?.pushViewController(AccountViewController.singleton, animated: true)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

   
}
