//
//  EditProfileViewController.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 13/12/16.
//  Copyright © 2016 Kohbroco. All rights reserved.
//

/*
 
    things to update if changing bar object:
 
    NeedsUpdating()
    UpdateUpdatingBar()
    LoadUpdatingBarFromACCounts and ToAccounts
    Barmanager newBarFromDict
 
 
    Merchant_Bar.name
    Merchant_Bar.ID
    Merchant_Bar.description
    Merchant_Bar.bookingAvailable
    Merchant_Bar.contact
    Merchant_Bar.website
    Merchant_Bar.openClosingHours
    Merchant_Bar.loc_lat
    Merchant_Bar.loc_long
    Merchant_Bar.address
 
 */

import UIKit

class EditProfileViewController: UIViewController,UITextViewDelegate,UITextFieldDelegate,OpeningHoursPickerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,LocationToProfileDelegate {

    static let singleton = EditProfileViewController(nibName: "EditProfileViewController", bundle: Bundle.main)
    
    var activeField : AnyObject?
    var isReloadingBar = false
    
    var UpdatingBar = Bar()
    var urlParameters = [String]()
    let days = ["MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY","SUNDAY"]

    var refreshButton : UIBarButtonItem?
    var activityIndicator : UIActivityIndicatorView?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contactIcon: UIImageView!
    
    @IBOutlet weak var websiteIcon: UIImageView!
    
    @IBOutlet weak var openingHoursIcon: UIImageView!
    
    @IBOutlet weak var locationIcon: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var barNameTextView: UITextView!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var contactTextField: UITextField!
    
    @IBOutlet weak var websiteTextField: UITextField!
    
    @IBOutlet weak var mondayTextField: UITextField!
    
    @IBOutlet weak var tuesdayTextField: UITextField!
    
    @IBOutlet weak var wednesdayTextField: UITextField!
    
    @IBOutlet weak var thursdayTextField: UITextField!
    
    @IBOutlet weak var fridayTextField: UITextField!
    
    @IBOutlet weak var saturdayTextField: UITextField!
    
    @IBOutlet weak var sundayTextField: UITextField!
    
    @IBOutlet var openingHoursTextFields: [UITextField]!
    
    @IBOutlet weak var openingHoursUIView: UIView!
    
    @IBOutlet weak var chooseLocationLabel: UILabel!
    
    @IBOutlet weak var updateButtonBottomConstraint: NSLayoutConstraint!
    
    var selectedImages = [UIImage]()
    let timePicker = OpeningHoursPickerView()

    let imagePicker = UIImagePickerController()
    var currentImageIndex : Int?
    
    @IBAction func UpdateProfile(_ sender: Any) {

        let paramString = urlParameters.joined(separator: "&")
        let url = Network.domain + "UpdateBarDescription.php?" + paramString
        
        guard let MerchID = Account.singleton.Merchant_ID else {return}
        guard let MerchBarID = Account.singleton.Merchant_Bar_ID else {return}
        guard let MerchUsername = Account.singleton.Merchant_username else {return}

        guard MerchBarID == UpdatingBar.ID else {NSLog("Updating Bar Not Initialized!!!");return}

        let postParamString = "Bar_Owner_ID=\(MerchID)&Bar_Owner_Name=\(MerchUsername)&Bar_ID=\(MerchBarID)" // not done
        
        print(url)
        Network.singleton.DataFromUrlWithPost(url, postParam: postParamString, handler: {
            (success,output) -> Void in
            
            if success
            {
                
                guard let _ = output else {return}
                
                do
                {
                    let dict = try JSONSerialization.jsonObject(with: output!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    
                    let success = dict["success"] as? String
                    
                    guard success != nil else {return}
                    
                    if success == "true"
                    {
                        let detailString = dict["detail"] as? String
                        
                        guard detailString != nil else {return}
                        PopupManager.singleton.Popup(title: "Update!", body: detailString!, presentationViewCont: self)

                        
                        //*********** change updated bar to new updated
                        self.LoadUpdatingBarToAccounts()

                        
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
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var chooseLocationButton: UIButton!
    
    @IBAction func ChooseLocationButtonPressed(_ sender: Any) {
        
        ChooseLocationViewController.singleton.currentLat = UpdatingBar.loc_lat
        ChooseLocationViewController.singleton.currentLong = UpdatingBar.loc_long
        ChooseLocationViewController.singleton.currentAddress = UpdatingBar.address
        
        self.navigationController?.pushViewController(ChooseLocationViewController.singleton, animated: true)
    }
    
    //==============================================================================================================
    //                                                      INIT
    //==============================================================================================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil!, bundle: nibBundleOrNil!)
        Bundle.main.loadNibNamed(nibNameOrNil!, owner: self, options: nil)

        //UI RELATED ====================================================================================

        //delegates
        barNameTextView.delegate = self
        descriptionTextView.delegate = self
        websiteTextField.delegate = self
        contactTextField.delegate = self
        websiteTextField.addTarget(self, action: #selector(textDidChange), for: UIControlEvents.editingChanged)
        contactTextField.addTarget(self, action: #selector(textDidChange), for: UIControlEvents.editingChanged)
        
        ChooseLocationViewController.singleton.delegate = self
        //refresh button
        //init refresh button
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 20,height: 20))
        self.activityIndicator?.color = UIColor.black
        self.activityIndicator?.tintColor = UIColor.black
        self.activityIndicator?.startAnimating()
        self.refreshButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(self.Refresh))
        
        //shadows
        barNameTextView.layer.shadowOpacity = 0.5
        barNameTextView.layer.shadowOffset = CGSize(width: 0, height: 2)
        barNameTextView.clipsToBounds = false
        AddShadow(view: descriptionTextView)
        AddShadow(view: websiteTextField)
        AddShadow(view: contactTextField)
        AddShadow(view: websiteTextField)
        AddShadow(view: openingHoursUIView)
        AddShadow(view: chooseLocationButton)
        updateButton.layer.shadowOpacity = 0.6
        updateButton.layer.shadowOffset = CGSize(width: 0, height: -2.5)
        updateButton.layer.shadowRadius = 3
        
        //colors
        contactIcon.image = contactIcon.image?.withRenderingMode(.alwaysTemplate)
        websiteIcon.image = websiteIcon.image?.withRenderingMode(.alwaysTemplate)
        openingHoursIcon.image = openingHoursIcon.image?.withRenderingMode(.alwaysTemplate)
        locationIcon.image = locationIcon.image?.withRenderingMode(.alwaysTemplate)

        let iconsColor = ColorManager.themeBright
        contactIcon.tintColor = iconsColor
        websiteIcon.tintColor = iconsColor
        openingHoursIcon.tintColor = iconsColor
        locationIcon.tintColor = iconsColor

        updateButton.setTitleColor(UIColor.darkGray, for: .disabled)
        updateButton.setTitleColor(ColorManager.themeBright, for: .normal)

        
        AddKeyboardToolBar()
        
        ChangeKeyboardsToDatePicker()
        
        for field in openingHoursTextFields
        {
            //delegates
            field.delegate = self
        }
        
        //colletion view
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "SelectImageCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SelectImageCollectionViewCell")
        
        collectionView.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        //image picker
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesutre(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
    
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }

    //==============================================================================================================
    //                                              SHADOW
    //==============================================================================================================
    func AddShadow(view : UIView)
    {
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        view.clipsToBounds = false
    }


    override func viewWillAppear(_ animated: Bool) {
        registerForKeyboardNotifications()
        
        //set refresh button
        if isReloadingBar
        {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator!)
        }
        else
        {
            self.navigationItem.rightBarButtonItem = self.refreshButton
        }
        
        collectionView.reloadData()
        
    }
    
    func ViewWillAppearFromMenu()
    {
        //load and display information
        if Account.singleton.Merchant_Bar != nil
        {
            LoadUpdatingBarFromAccounts()
            DisplayUpdatingBar()
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    

    
    
    //========================================================================================================
    //                                          refresh button
    //========================================================================================================
    func Refresh()
    {
        //refresh button -> spinner
        DispatchQueue.main.async(execute: {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator!)
            self.isReloadingBar = true
        })
        
        BarManager.singleton.ReloadBar(handler: {
            (success) -> Void in
            
            DispatchQueue.main.async(execute: {
                self.navigationItem.rightBarButtonItem = self.refreshButton
                self.isReloadingBar = false
            })
        
        })
        
    }
    
    //==============================================================================================================
    //                                     UPDATING (TO ALLOW UPDATING OR NOT)
    //==============================================================================================================

    func NeedsUpdating() -> Bool
    {
        guard UpdatingBar.name != "" else {NSLog("No Updating Bar Loaded");return false}
        guard Account.singleton.Merchant_Bar != nil else {NSLog("No bar loaded yet?");return false}
        
        var toUpdate = false
        //fields to check : Name, description, contact, website, location
        //settles url parameters
        urlParameters.removeAll()
        
//        var set = CharacterSet.urlQueryAllowed
//        set.insert(charactersIn: "+&")
        if Account.singleton.Merchant_Bar?.name != UpdatingBar.name {
            toUpdate = true
            
            let param = "Bar_Name=\(UpdatingBar.name.AddPercentEncodingForURL(plusForSpace: true)!)"
            urlParameters.append(param)
        }
        if Account.singleton.Merchant_Bar?.description != UpdatingBar.description {
            toUpdate = true
            let param = "Bar_Description=\(UpdatingBar.description.AddPercentEncodingForURL(plusForSpace: true)!)"
            urlParameters.append(param)
        }
        if Account.singleton.Merchant_Bar?.contact != UpdatingBar.contact {
            toUpdate = true
            let param = "Bar_Contact=\(UpdatingBar.contact.AddPercentEncodingForURL(plusForSpace: true)!)"
            urlParameters.append(param)
        }
        if Account.singleton.Merchant_Bar?.website != UpdatingBar.website {
            toUpdate = true
            let param = "Bar_Wesbite=\(UpdatingBar.website.AddPercentEncodingForURL(plusForSpace: true)!)"
            urlParameters.append(param)
        }
        if Account.singleton.Merchant_Bar?.loc_lat != UpdatingBar.loc_lat {
            toUpdate = true
            let param = "Bar_Location_Latitude=\(UpdatingBar.loc_lat)"
            urlParameters.append(param)
        }
        if Account.singleton.Merchant_Bar?.loc_long != UpdatingBar.loc_long {
            toUpdate = true
            let param = "Bar_Location_Longitude=\(UpdatingBar.loc_long)"
            urlParameters.append(param)
        }

        if Account.singleton.Merchant_Bar?.address != UpdatingBar.address {
            toUpdate = true
            let param = "Bar_Address=\(UpdatingBar.address.AddPercentEncodingForURL(plusForSpace: true)!)"
            urlParameters.append(param)
        }
        
        if Account.singleton.Merchant_Bar?.openClosingHours[0] != UpdatingBar.openClosingHours[0]
        {
            toUpdate = true
            let param = "OH_Monday=\(UpdatingBar.openClosingHours[0].AddPercentEncodingForURL(plusForSpace: true)!)"
            urlParameters.append(param)
        }
        if Account.singleton.Merchant_Bar?.openClosingHours[1] != UpdatingBar.openClosingHours[1]
        {
            toUpdate = true
            let param = "OH_Tuesday=\(UpdatingBar.openClosingHours[1].AddPercentEncodingForURL(plusForSpace: true)!)"
            urlParameters.append(param)
        }
        if Account.singleton.Merchant_Bar?.openClosingHours[2] != UpdatingBar.openClosingHours[2]
        {
            toUpdate = true
            let param = "OH_Wednesday=\(UpdatingBar.openClosingHours[2].AddPercentEncodingForURL(plusForSpace: true)!)"
            urlParameters.append(param)
        }
        if Account.singleton.Merchant_Bar?.openClosingHours[3] != UpdatingBar.openClosingHours[3]
        {
            toUpdate = true
            let param = "OH_Thursday=\(UpdatingBar.openClosingHours[3].AddPercentEncodingForURL(plusForSpace: true)!)"
            urlParameters.append(param)
        }
        if Account.singleton.Merchant_Bar?.openClosingHours[4] != UpdatingBar.openClosingHours[4]
        {
            toUpdate = true
            let param = "OH_Friday=\(UpdatingBar.openClosingHours[4].AddPercentEncodingForURL(plusForSpace: true)!)"
            urlParameters.append(param)
        }
        if Account.singleton.Merchant_Bar?.openClosingHours[5] != UpdatingBar.openClosingHours[5]
        {
            toUpdate = true
            let param = "OH_Saturday=\(UpdatingBar.openClosingHours[5].AddPercentEncodingForURL(plusForSpace: true)!)"
            urlParameters.append(param)
        }
        if Account.singleton.Merchant_Bar?.openClosingHours[6] != UpdatingBar.openClosingHours[6]
        {
            toUpdate = true
            let param = "OH_Sunday=\(UpdatingBar.openClosingHours[6].AddPercentEncodingForURL(plusForSpace: true)!)"
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
        UpdateUpdatingBar()
        TextUpdated()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        UpdateUpdatingBar()
        TextUpdated()
    }
    
    func DisplayUpdatingBar()
    {
        let bar = UpdatingBar
        barNameTextView.text = bar.name
        descriptionTextView.text = bar.description
        contactTextField.text = bar.contact
        websiteTextField.text = bar.website
        mondayTextField.text = "MONDAY:" + bar.openClosingHours[0]
        tuesdayTextField.text = "TUESDAY:" + bar.openClosingHours[1]
        wednesdayTextField.text = "WEDNESDAY:" + bar.openClosingHours[2]
        thursdayTextField.text = "THURSDAY:" + bar.openClosingHours[3]
        fridayTextField.text = "FRIDAY:" + bar.openClosingHours[4]
        saturdayTextField.text = "SATURDAY:" + bar.openClosingHours[5]
        sundayTextField.text = "SUNDAY:" + bar.openClosingHours[6]
        chooseLocationLabel.text = "Location: " + bar.address
    }
    
    func UpdateUpdatingBar()
    {
        UpdatingBar.name = barNameTextView.text!
        UpdatingBar.description = descriptionTextView.text!
        UpdatingBar.contact = contactTextField.text!
        UpdatingBar.website = websiteTextField.text!

        //updating bar opening hours
        UpdatingBar.openClosingHours[0] = (mondayTextField.text?.components(separatedBy: ":")[1])!
        UpdatingBar.openClosingHours[1] = (tuesdayTextField.text?.components(separatedBy: ":")[1])!
        UpdatingBar.openClosingHours[2] = (wednesdayTextField.text?.components(separatedBy: ":")[1])!
        UpdatingBar.openClosingHours[3] = (thursdayTextField.text?.components(separatedBy: ":")[1])!
        UpdatingBar.openClosingHours[4] = (fridayTextField.text?.components(separatedBy: ":")[1])!
        UpdatingBar.openClosingHours[5] = (saturdayTextField.text?.components(separatedBy: ":")[1])!
        UpdatingBar.openClosingHours[6] = (sundayTextField.text?.components(separatedBy: ":")[1])!
        
        UpdatingBar.loc_lat = ChooseLocationViewController.singleton.currentLat
        UpdatingBar.loc_long = ChooseLocationViewController.singleton.currentLong
        UpdatingBar.address = ChooseLocationViewController.singleton.currentAddress
    }

    func LoadUpdatingBarFromAccounts()
    {
        guard let Merchant_Bar = Account.singleton.Merchant_Bar else {return}
        
        
        
        UpdatingBar.name = Merchant_Bar.name
        UpdatingBar.ID = Merchant_Bar.ID
        UpdatingBar.description = Merchant_Bar.description
        UpdatingBar.bookingAvailable = Merchant_Bar.bookingAvailable
        UpdatingBar.contact = Merchant_Bar.contact
        UpdatingBar.website = Merchant_Bar.website
        UpdatingBar.openClosingHours = Merchant_Bar.openClosingHours
        UpdatingBar.loc_lat = Merchant_Bar.loc_lat
        UpdatingBar.loc_long = Merchant_Bar.loc_long
        UpdatingBar.address = Merchant_Bar.address

    }
    
    func LoadUpdatingBarToAccounts()
    {
        if let bar = Account.singleton.Merchant_Bar
        {
            bar.name = self.UpdatingBar.name
            bar.ID = self.UpdatingBar.ID
            bar.description = self.UpdatingBar.description
            bar.bookingAvailable = self.UpdatingBar.bookingAvailable
            bar.contact = self.UpdatingBar.contact
            bar.website = self.UpdatingBar.website
            bar.openClosingHours = self.UpdatingBar.openClosingHours
            bar.loc_lat = self.UpdatingBar.loc_lat
            bar.loc_long = self.UpdatingBar.loc_long
            bar.address = self.UpdatingBar.address
        }
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

    func SetUpdatingBarLocation()
    {
        UpdatingBar.loc_lat = ChooseLocationViewController.singleton.currentLat
        UpdatingBar.loc_long = ChooseLocationViewController.singleton.currentLong
        UpdatingBar.address = ChooseLocationViewController.singleton.currentAddress
        
        
        //values did change (check if needs updating)
        textDidChange()
        
        //update display
        self.DisplayUpdatingBar()
    }
    //==============================================================================================================
    //                                     PUSH UP SCROLL VIEW WHEN EDITING TEXT
    //==============================================================================================================
    //push up scroll
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
        
        
        for field in openingHoursTextFields
        {
            if textField == field
            {
                let timeStringArr = textField.text!.components(separatedBy: ":")
                
                if timeStringArr.count > 1
                {
                    timePicker.LoadFromString(input: timeStringArr[1])
                }
                else
                {
                    NSLog("ERROR: textfield doesnt contain \":\"")
                }
                
                
            }
        }
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
        
        
        let keyboardHeight = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size.height
        let toolBarHeight : CGFloat = 30
        updateButtonBottomConstraint.constant = keyboardHeight! - Sizing.tabBarHeight
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
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
        barNameTextView.inputAccessoryView = numberToolbar
        descriptionTextView.inputAccessoryView = numberToolbar
        contactTextField.inputAccessoryView = numberToolbar
        websiteTextField.inputAccessoryView = numberToolbar
        
        for field in openingHoursTextFields
        {
            field.inputAccessoryView = numberToolbar
        }

    }
    //==============================================================================================================
    //                                    TIMEPICKER KEYBOARD
    //==============================================================================================================

    
    func ChangeKeyboardsToDatePicker()
    {
        timePicker.openingHoursDelegate = self

        
        for field in openingHoursTextFields
        {
            field.inputView = timePicker
        }
        
        
    }
    
    func DatePickerValueChanged(output : String) //this function is only called when editing text fields
    {
        //activeField is textfield in edit
        if Mirror(reflecting: activeField!).subjectType == UITextField.self
        {
            let field = activeField as! UITextField
            
            let dayString = days[field.tag]
            
            
            field.text = "\(dayString):\(output)"
        }
        if Mirror(reflecting: activeField!).subjectType == UITextView.self
        {
            return //opening hours ediitng only uses text fields
        }
        
        
        //updating bar opening hours
        UpdatingBar.openClosingHours[0] = (mondayTextField.text?.components(separatedBy: ":")[1])!
        UpdatingBar.openClosingHours[1] = (tuesdayTextField.text?.components(separatedBy: ":")[1])!
        UpdatingBar.openClosingHours[2] = (wednesdayTextField.text?.components(separatedBy: ":")[1])!
        UpdatingBar.openClosingHours[3] = (thursdayTextField.text?.components(separatedBy: ":")[1])!
        UpdatingBar.openClosingHours[4] = (fridayTextField.text?.components(separatedBy: ":")[1])!
        UpdatingBar.openClosingHours[5] = (saturdayTextField.text?.components(separatedBy: ":")[1])!
        UpdatingBar.openClosingHours[6] = (sundayTextField.text?.components(separatedBy: ":")[1])!

        
        TextUpdated()
    }
    
    
    func cancelNumberPad()
    {
        let txtfield = FirstResponder()
        let _ = txtfield.endEditing(true)
        
    }
    
    func doneWithNumberPad()
    {
        let txtfield = FirstResponder()
        
        if txtfield as! NSObject  == barNameTextView
        {
            descriptionTextView.becomeFirstResponder()
        }
        else if txtfield as! NSObject  == descriptionTextView
        {
            contactTextField.becomeFirstResponder()
        }
        else if txtfield as! NSObject  == contactTextField
        {
            websiteTextField.becomeFirstResponder()
        }
        else if txtfield as! NSObject  == websiteTextField
        {
            mondayTextField.becomeFirstResponder()
        }
        else if txtfield as! NSObject  == mondayTextField
        {
            tuesdayTextField.becomeFirstResponder()
        }
        else if txtfield as! NSObject  == tuesdayTextField
        {
            wednesdayTextField.becomeFirstResponder()
        }
        else if txtfield as! NSObject  == wednesdayTextField
        {
            thursdayTextField.becomeFirstResponder()
        }else if txtfield as! NSObject  == thursdayTextField
        {
            fridayTextField.becomeFirstResponder()
        }else if txtfield as! NSObject  == fridayTextField
        {
            saturdayTextField.becomeFirstResponder()
        }else if txtfield as! NSObject  == saturdayTextField
        {
            sundayTextField.becomeFirstResponder()
        }else if txtfield as! NSObject  == sundayTextField
        {
            
        }

        
        
        
        
        
        
        
        let _ = txtfield.endEditing(true)
    }
    
    
    func FirstResponder() -> AnyObject
    {
        
        if barNameTextView.isFirstResponder
        {
            return barNameTextView
        }
        else if descriptionTextView.isFirstResponder
        {
            return descriptionTextView
        }
        if contactTextField.isFirstResponder
        {
            return contactTextField
        }
        else if websiteTextField.isFirstResponder
        {
            return websiteTextField
        }
        
        for field in openingHoursTextFields
        {
            if field.isFirstResponder
            {
                return field
            }
        }
    
        return barNameTextView
    }

    //==============================================================================================================
    //                                          COLLECTION VIEW DELEGATE METHODS
    //==============================================================================================================
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectImageCollectionViewCell else {return}
        
        if let _ = cell.imageView.image //if has image already
        {
            //delete or choose new image
            currentImageIndex = indexPath.row
            PresentEditImageActionSheet(indexPath: indexPath)
        }
        else // else choose image
        {
            currentImageIndex = indexPath.row
            PresentChooseImageActionSheet(indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        
        return CGSize(width: 70, height: 150)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectImageCollectionViewCell",for: indexPath) as? SelectImageCollectionViewCell

        guard indexPath.row < selectedImages.count else {
            
            cell?.imageView.image = nil
            return cell!
        }
        
        let image = selectedImages[indexPath.row]
        
        cell?.imageView.image = image
        
        return cell!
    }
 
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row < selectedImages.count
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let originIndex = sourceIndexPath.row
        let destinationIndex = destinationIndexPath.row
        
        guard originIndex < selectedImages.count else {return}
        if destinationIndex < selectedImages.count
        {
            let image = selectedImages[originIndex]
            selectedImages.remove(at: originIndex)
            selectedImages.insert(image, at: destinationIndex)
            
            UpdateCollectionViewUI()
        }
        else
        {
            let image = selectedImages[originIndex]
            selectedImages.remove(at: originIndex)
            selectedImages.append(image)
            
            UpdateCollectionViewUI()

        }


    }
    
    func handleLongGesutre(gesture : UILongPressGestureRecognizer)
    {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {break}
            if #available(iOS 9.0, *) {
                collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            } else {
                // Fallback on earlier versions
            }
        case .changed:
            if #available(iOS 9.0, *) {
                self.collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            } else {
                // Fallback on earlier versions
            }
        case .ended:
            if #available(iOS 9.0, *) {
                self.collectionView.endInteractiveMovement()
                
                self.UpdateCollectionViewUI()
            } else {
                // Fallback on earlier versions
            }
        default:
            if #available(iOS 9.0, *) {
                self.collectionView.cancelInteractiveMovement()
                
                self.UpdateCollectionViewUI()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    //==============================================================================================================
    //                                          IMAGE PICKER DELEGATE METHODS
    //==============================================================================================================
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let index = currentImageIndex
        {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            {
                if index < selectedImages.count
                {
                    selectedImages[index] = image   
                }
                else
                {
                    selectedImages.append(image)
                }

                self.UpdateCollectionViewUI()
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    //==============================================================================================================
    //                                          ACTION SHEET METHODS
    //==============================================================================================================
    func PresentChooseImageActionSheet(indexPath : IndexPath)
    {
        let actionCont = UIAlertController(title: nil, message: "New Image", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.currentImageIndex = nil
        }
        
        let chooseImageAction = UIAlertAction(title: "Choose Image From Library", style: .default) { (action) in
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        actionCont.addAction(cancelAction)
        actionCont.addAction(chooseImageAction)

        DispatchQueue.main.async {
            self.present(actionCont, animated: true, completion: nil)
        }
    }
    
    func PresentEditImageActionSheet(indexPath : IndexPath)
    {
        let actionCont = UIAlertController(title: nil, message: "Edit image", preferredStyle: .actionSheet)
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.currentImageIndex = nil
        }
        
        let chooseImageAction = UIAlertAction(title: "Choose Image From Library", style: .default) { (action) in
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let deleteImageAction = UIAlertAction(title: "Remove Image", style: .destructive) { (action) in
            
            
            if let index = self.currentImageIndex
            {
                if index < self.selectedImages.count
                {
                    self.selectedImages.remove(at: index)
                    
                    self.UpdateCollectionViewUI()
                }
            }

        }
        
        actionCont.addAction(cancelAction)
        actionCont.addAction(chooseImageAction)
        actionCont.addAction(deleteImageAction)
        
        DispatchQueue.main.async {
            self.present(actionCont, animated: true, completion: nil)
        }
    }
    
    func UpdateCollectionViewUI()
    {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
}


