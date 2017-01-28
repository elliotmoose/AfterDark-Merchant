//
//  EditDiscountsViewController.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 22/12/16.
//  Copyright © 2016 Kohbroco. All rights reserved.
//

import UIKit

class EditDiscountsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    static let singleton = EditDiscountsViewController(nibName: "EditDiscountsViewController", bundle: Bundle.main)

    var tableView : UITableView?
    
    //==========================================================================================
    //                                      INIT
    //==========================================================================================
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        Bundle.main.loadNibNamed(nibNameOrNil!, owner: self, options: nil)
        
        //add subviews
        tableView = UITableView(frame: self.view.frame, style: .grouped)
        tableView!.delegate = self
        tableView!.dataSource = self
        self.view.addSubview(tableView!)
        
        
        //add new discount button
        let addDiscountButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(AddDiscount))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        UpdateDiscountList()
    }
    
    func UpdateDiscountList()
    {
        self.tableView?.reloadData()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard Account.singleton.Merchant_Bar != nil else {return 0}
        
        return (Account.singleton.Merchant_Bar?.discounts.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "discountCell")
        
        if cell == nil
        {
            cell = UITableViewCell()
        }
        
        guard Account.singleton.Merchant_Bar != nil else {return cell!}
        
        cell?.textLabel?.text = Account.singleton.Merchant_Bar?.discounts[indexPath.row].name!
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //push edit discount controller
        EditDetailDiscountViewController.singleton.displayedDiscountIndex = indexPath.row
        
        self.navigationController?.pushViewController(EditDetailDiscountViewController.singleton, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func AddDiscount()
    {
        //present add discount view
    }
    

}
