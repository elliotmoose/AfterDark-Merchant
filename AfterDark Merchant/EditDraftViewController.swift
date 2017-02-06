//
//  EditDraftViewController.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 2/2/17.
//  Copyright © 2017 Kohbroco. All rights reserved.
//

import UIKit


class EditDraftViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate {
    
    static let singleton = EditDraftViewController(nibName: "EditDraftViewController", bundle: Bundle.main)
    
    var onlyPercentageDeals = false
    
    var activeField : AnyObject?
    var displayedDiscountIndex = -1
    var updatingDiscount : Discount?
    var urlParameters = [String]()
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var discountTitleTextView: UITextView!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var updateButtonBottomConstraint: NSLayoutConstraint!
    
    @IBAction func updateButtonPressed(_ sender: Any) {
        
        //push this draft by adding
        guard let barID = Account.singleton.Merchant_Bar_ID else {return}
        guard let discountName = discountTitleTextView.text.AddPercentEncodingForURL(plusForSpace: true) else {return}
        guard let discountAmount = amountTextField.text?.AddPercentEncodingForURL(plusForSpace: true) else {return}
        guard let discountDescription = descriptionTextView.text.AddPercentEncodingForURL(plusForSpace: true) else {return}
        
        let postParam = "Bar_ID=\(barID)&Discount_Name=\(discountName)&Discount_Amount=\(discountAmount)&Discount_Description=\(discountDescription)"
        let url = Network.domain + "AddNewDiscount.php"
        
        Network.singleton.DataFromUrlWithPost(url, postParam: postParam) { (success, output) in
            if success
            {
                if let output = output
                {
                    do
                    {
                        if let dict = try JSONSerialization.jsonObject(with: output, options: .allowFragments) as? NSDictionary
                        {
                            if let succ = dict["success"] as? String
                            {
                                if succ == "true"
                                {
                                    if let detail = dict["detail"] as? [NSDictionary]
                                    {
                                        //reload discounts from results
                                        Account.singleton.Merchant_Bar?.discounts.removeAll()
                                        var newDiscountList = [Discount]()
                                        
                                        for discountDict in detail
                                        {
                                            let discount = Discount(dict: discountDict)
                                            newDiscountList.append(discount)
                                        }
                                        
                                        Account.singleton.Merchant_Bar?.discounts = newDiscountList
                                        
                                        //remove draft
                                        guard self.displayedDiscountIndex < DiscountManager.singleton.draftDiscounts.count else {
                                            NSLog("draft doesnt exist. might have already been added, and removed as a draft")
                                            PopupManager.singleton.Popup(title: "Error", body: "draft doesnt exist", presentationViewCont: self, handler: {
                                                //dissmiss
                                                self.Dismiss()
                                            })
                                            
                                            
                                            return
                                        }
                                        
                                        DiscountManager.singleton.draftDiscounts
                                        .remove(at: self.displayedDiscountIndex)
                                        
                                        //popup
                                        PopupManager.singleton.Popup(title: "Success", body: "New discount added successfully!", presentationViewCont: self, handler: {
                                            //dissmiss
                                            self.Dismiss()
                                        })
                                        

                                        
                                    }
                                    else
                                    {
                                        NSLog("output detail not array")
                                    }
                                    
                                }
                                else
                                {
                                    //if fail -> print error
                                    guard let detail = dict["detail"] as? String else {return}
                                    
                                    PopupManager.singleton.Popup(title: "Error", body: detail, presentationViewCont: self)
                                }
                            }
                            else
                            {
                                NSLog("Invalid server response")
                            }
                        }
                        else
                        {
                            NSLog("Invalid server response")
                        }
                    }
                    catch
                    {
                        
                    }
                }
                else
                {
                    NSLog("No server response")
                }
            }
            else
            {
                PopupManager.singleton.Popup(title: "Oops!", body: "Please check your internet connection", presentationViewCont: self)
            }
        }
        
        
        
    }
    
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        Bundle.main.loadNibNamed(nibNameOrNil!, owner: self, options: nil)
        
        //add keyboard accessory
        AddKeyboardToolBar()
        
        //scroll up keyboard preperation
        SetTextViewDelegates()
        
        //add shadows
        AddShadow(view: amountTextField)
        AddShadow(view: descriptionTextView)
        discountTitleTextView.layer.shadowOpacity = 0.5
        discountTitleTextView.layer.shadowOffset = CGSize(width: 1, height: 3)
        discountTitleTextView.clipsToBounds = false
        
        //init
        updatingDiscount = Discount(name: "", details: "", amount: "", discountID: "", bar_ID: "")
        
        updateButton.setTitleColor(UIColor.darkGray, for: .disabled)
        updateButton.setTitleColor(ColorManager.themeBright, for: .normal)
    }
    
    func AddShadow(view : UIView)
    {
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowRadius = 2
        view.clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {

        //load info
        let discount = DiscountManager.singleton.draftDiscounts[displayedDiscountIndex]
        
        discountTitleTextView.text = discount.name!
        descriptionTextView.text = discount.details!
        amountTextField.text = discount.amount!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
        
        displayedDiscountIndex = -1
    }
    
    
    //==============================================================================================================
    //                                     TEXT FIELD RELATED DELEGATE FUNCTIONS
    //==============================================================================================================
    
    
    func NeedsUpdating() -> Bool
    {
        guard updatingDiscount != nil else {NSLog("no discount in update?");return false}
        guard Account.singleton.Merchant_Bar != nil else {NSLog("No bar loaded yet?");return false}
        guard displayedDiscountIndex < DiscountManager.singleton.draftDiscounts.count else {
            
            NSLog("draft doesnt exist. might have already been added, and removed as a draft")
            PopupManager.singleton.Popup(title: "Error", body: "draft doesnt exist", presentationViewCont: self, handler: {
                //dissmiss
                self.Dismiss()
            })
            
            return false
        }
        
        var toUpdate = false
        //fields to check : title, amount, description
        urlParameters.removeAll()
        
        
        let updatedDiscount = DiscountManager.singleton.draftDiscounts[displayedDiscountIndex]
        
        if updatedDiscount.name != updatingDiscount?.name {
            toUpdate = true
            
            let param = "Discount_Name=\((updatingDiscount?.name?.AddPercentEncodingForURL(plusForSpace: true))!)"
            urlParameters.append(param)
        }
        
        if updatedDiscount.amount != updatingDiscount?.amount {
            toUpdate = true
            
            let param = "Discount_Amount=\((updatingDiscount?.amount?.AddPercentEncodingForURL(plusForSpace: true))!)"
            urlParameters.append(param)
        }
        
        if updatedDiscount.details != updatingDiscount?.details {
            toUpdate = true
            
            let param = "Discount_Description=\((updatingDiscount?.details?.AddPercentEncodingForURL(plusForSpace: true))!)"
            urlParameters.append(param)
        }
        
        if toUpdate
        {
            return true
        }
        else
        {
            return false
        }
        
        
    }
    
    func textDidChange()
    {
        UpdateUpdatingDiscount()
        TextUpdated()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        UpdateUpdatingDiscount()
        TextUpdated()
        
    }
    
    func TextUpdated()
    {
        //check if needs updating
        if NeedsUpdating()
        {
            updateButton.isEnabled = true
        }
        else //grey out update button
        {
            updateButton.isEnabled = false
        }
    }
    
    func UpdateUpdatingDiscount()
    {
        updatingDiscount?.name = discountTitleTextView.text
        updatingDiscount?.amount = amountTextField.text
        updatingDiscount?.details = descriptionTextView.text
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if onlyPercentageDeals
        {
            if textField == amountTextField
            {
                let oldText = textField.text?.replacingOccurrences(of: "%", with: "")
                let _ = oldText?.replacingOccurrences(of: ".", with: "")
                let newString = "\(oldText!)%" as NSString
                
                var newRange = NSRange()
                
                if range.location != 0
                {
                    newRange.location = range.location - 1
                    newRange.length = range.length
                }
                else
                {
                    return false
                }
                
                
                
                textField.text = newString.replacingCharacters(in: newRange, with: string)
                
                textDidChange()
                return false
            }
            
            return false
        }
        else
        {
            return true
        }
        
        
    }
    //==============================================================================================================
    //                                     PUSH UP SCROLL VIEW WHEN EDITING TEXT
    //==============================================================================================================
    //push up scroll
    func SetTextViewDelegates()
    {
        discountTitleTextView.delegate = self
        amountTextField.delegate = self
        descriptionTextView.delegate = self
        
        
        amountTextField.addTarget(self, action: #selector(textDidChange), for: UIControlEvents.editingChanged)
    }
    
    
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //textfield delegate functions
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeField = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeField = nil
    }
    
    
    func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        
        
        
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
        
        let keyboardHeight = keyboardSize?.height
        updateButtonBottomConstraint.constant = keyboardHeight! - Sizing.tabBarHeight
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        //var info = notification.userInfo!
        //let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        
        updateButtonBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    //==============================================================================================================
    //                                    TOOL BAR ON KEYBOARD
    //==============================================================================================================
    
    func AddKeyboardToolBar()
    {
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: Sizing.ScreenWidth(), height: 30))
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelNumberPad)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneWithNumberPad))]
        numberToolbar.sizeToFit()
        discountTitleTextView.inputAccessoryView = numberToolbar
        descriptionTextView.inputAccessoryView = numberToolbar
        amountTextField.inputAccessoryView = numberToolbar
        
    }
    
    func cancelNumberPad()
    {
        let txtfield = FirstResponder()
        let _ = txtfield.endEditing(true)
        
    }
    
    func doneWithNumberPad()
    {
        let txtfield = FirstResponder()
        
        if txtfield as! NSObject == discountTitleTextView
        {
            amountTextField.becomeFirstResponder()
        }
        if txtfield as! NSObject == amountTextField
        {
            descriptionTextView.becomeFirstResponder()
        }
        
        let _ = txtfield.endEditing(true)
    }
    
    
    func FirstResponder() -> AnyObject
    {
        if discountTitleTextView.isFirstResponder
        {
            return discountTitleTextView
        }
        else if descriptionTextView.isFirstResponder
        {
            return descriptionTextView
        }
        else
        {
            return amountTextField
        }
        
        
        
    }
    
    func Dismiss()
    {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

