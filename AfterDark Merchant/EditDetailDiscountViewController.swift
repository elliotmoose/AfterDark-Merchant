//
//  EditDetailDiscountViewController.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 23/12/16.
//  Copyright © 2016 Kohbroco. All rights reserved.
//

import UIKit

class EditDetailDiscountViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate {

    static let singleton = EditDetailDiscountViewController(nibName: "EditDetailDiscountViewController", bundle: Bundle.main)

    var activeField : AnyObject?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var discountTitleTextView: UITextView!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBAction func updateButtonPressed(_ sender: Any) {
        let paramString = urlParameters.joined(separator: "&")
        let url = Network.domain + "UpdateBarDiscounts.php?" + paramString
        
        let MerchID = Account.singleton.Merchant_ID
        let MerchBarID = Account.singleton.Merchant_Bar_ID
        let MerchUsername = Account.singleton.Merchant_username
        
        guard let _ = MerchID else {return}
        guard let _ = MerchBarID else {return}
        guard let _ = MerchUsername else {return}
        guard let discountID = Account.singleton.Merchant_Bar?.discounts[displayedDiscountIndex].discount_ID else {return}
        let postParamString = "Bar_Owner_ID=\(MerchID!)&Bar_Owner_Name=\(MerchUsername!)&Bar_ID=\(MerchBarID!)&Discount_ID=\(discountID)" // not done
        
        Network.singleton.DataFromUrlWithPost(url, postParam: postParamString, handler: {
            (success,output) -> Void in
            
            if success
            {
                do
                {
                    guard let _ = output else {return}
                    let dict = try JSONSerialization.jsonObject(with: output!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    
                    let success = dict["success"] as? String
                    
                    guard success != nil else {return}
                    
                    if success == "true"
                    {
                        let detailString = dict["detail"] as? String
                        
                        guard detailString != nil else {return}
                        PopupManager.singleton.Popup(title: "Update!", body: detailString!, presentationViewCont: self)
                        
                        //*********** change updated discount to new updated
                        let thisDiscount = Account.singleton.Merchant_Bar?.discounts[self.displayedDiscountIndex]
                        thisDiscount?.name = self.updatingDiscount?.name
                        thisDiscount?.amount = self.updatingDiscount?.amount
                        thisDiscount?.details = self.updatingDiscount?.details
                        self.textDidChange()
                        
                    }
                    else
                    {
                        let detailString = dict["detail"] as? String
                        
                        guard detailString != nil else {return}
                        PopupManager.singleton.Popup(title: "Error", body: detailString!, presentationViewCont: self)
                    }
                    
                    
                }
                catch let error as NSError
                {
                    print(error)
                }
                
            }
            else
            {
                print("failed to update")
            }
            
            
            
        })
        

    }
    
    var displayedDiscountIndex = -1
    var updatingDiscount : Discount?
    var urlParameters = [String]()


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
        let bar = Account.singleton.Merchant_Bar
        guard displayedDiscountIndex >= 0 else {print("no index selected");return}
        let discount = bar?.discounts[displayedDiscountIndex]
        
        discountTitleTextView.text = discount?.name!
        descriptionTextView.text = discount?.details!
        amountTextField.text = discount?.amount!
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
        
        var toUpdate = false
        //fields to check : title, amount, description
        urlParameters.removeAll()
        

        let updatedDiscount = Account.singleton.Merchant_Bar?.discounts[displayedDiscountIndex]
        
        if updatedDiscount?.name != updatingDiscount?.name {
            toUpdate = true
            
            let param = "Discount_Name=\((updatingDiscount?.name?.AddPercentEncodingForURL(plusForSpace: true))!)"
            urlParameters.append(param)
        }
     
        if updatedDiscount?.amount != updatingDiscount?.amount {
            toUpdate = true
            
            let param = "Discount_Amount=\((updatingDiscount?.amount?.AddPercentEncodingForURL(plusForSpace: true))!)"
            urlParameters.append(param)
        }
        
        if updatedDiscount?.details != updatingDiscount?.details {
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
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        //var info = notification.userInfo!
        //let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        self.scrollView.scrollIndicatorInsets = contentInsets
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


}
