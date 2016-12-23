//
//  LoginViewController.swift
//  AfterDark
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 3/11/16.
//  Copyright © 2016 kohbroco. All rights reserved.
//

import UIKit

protocol LoginDelegate : class {
    func Dismiss()
}

class LoginViewController: UIViewController,UITextFieldDelegate,LoginDelegate {

    static let singleton = LoginViewController(nibName: "LoginViewController", bundle: Bundle.main)
    
    @IBOutlet weak var grayViewOverlay: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var afterDarkIconHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var afterDarkIconVerticalConstraint: NSLayoutConstraint!
    
    var activeField : UITextField?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var loginIconImageView: UIImageView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        Bundle.main.loadNibNamed("LoginViewController", owner: self, options: nil)
        Initialize()

    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        //Bundle.main.loadNibNamed("LoginViewController", owner: self, options: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }

    override func awakeFromNib() {
        Initialize()
    }

    override func viewWillAppear(_ animated: Bool) {

        registerForKeyboardNotifications()
        ResetTextFields()


    }
    override func viewDidAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()

        if Account.singleton.user_name == "" || Account.singleton.user_name == nil
        {
            //animate in login form
            self.afterDarkIconVerticalConstraint.constant = -125

            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            },
            completion:
            {(finish) -> Void in
            
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {

                    self.usernameLabel.alpha = 1
                    self.usernameTextField.alpha = 1
                    self.passwordLabel.alpha = 1
                    self.passwordTextField.alpha = 1
                    self.signInButton.alpha = 1
                    self.createAccountButton.alpha = 1
                    self.forgotPasswordButton.alpha = 1
                    
                })
                
            })
        }
        else
        {
            //fade out
            self.dismiss(animated: true, completion: nil)
        }
        
        

        

    }
    
    func Initialize()
    {
        loginIconImageView.layer.cornerRadius = loginIconImageView.frame.size.width/2
        grayViewOverlay.layer.cornerRadius = grayViewOverlay.frame.size.width/2
        grayViewOverlay.alpha = 0
        
        usernameTextField.clearButtonMode = .whileEditing
        usernameLabel.alpha = 0
        usernameTextField.alpha = 0
        passwordLabel.alpha = 0
        passwordTextField.alpha = 0
        self.signInButton.alpha = 0
        self.createAccountButton.alpha = 0
        self.forgotPasswordButton.alpha = 0
        
        self.signInButton.addTarget(self, action: #selector(SignIn), for: .touchUpInside)
        self.createAccountButton.addTarget(self, action: #selector(CreateAccountButtonPressed), for: .touchUpInside)
        self.forgotPasswordButton.addTarget(self, action: #selector(ForgotPasswordButtonPressed), for: .touchUpInside)
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        afterDarkIconVerticalConstraint.constant = 0
        afterDarkIconHorizontalConstraint.constant = 0
        self.view.layoutIfNeeded()
        
        NewAccountFormViewController.singleton.delegate = self;
        
        addKeyboardToolBar()
    }
    
    func SignIn()
    {
        
        
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        if username != "" && password != ""
        {

            
            //grey out text fields
            DisableTextFields()
            
            //activity indicator
            SetIconToLoading()
            
            //dummy app
            if Settings.dummyAppOn
            {
                self.EnableTextFields()
                self.SetIconToDoneLoading()
                
                if username == "Admin" && password == "Admin"
                {
                    //log in success
                    self.dismiss(animated: true, completion: nil)
                    self.ResetTextFields()
                }
                else
                {
                    
                    
                    if username == "Admin"
                    {
                        //log in fail
                        PopupManager.singleton.Popup(title: "Oops!", body: "Wrong Password!", presentationViewCont: self)
                        
                        self.passwordTextField.text = ""
                    }
                    else
                    {
                        //log in fail
                        PopupManager.singleton.Popup(title: "Oops!", body: "Username not recognized!", presentationViewCont: self)
                        self.ResetTextFields()
                    }
                }
                
                return
            }
        
            
            
            //login
            Account.singleton.Login(username!, password: password!, handler: {
            (success,resultString) -> Void in
                //re enable text fields
                
                self.EnableTextFields()
                self.SetIconToDoneLoading()
                
                if success{
                    //log in success
                    self.dismiss(animated: true, completion: nil)
                    self.ResetTextFields()

                }
                else
                {
                    //log in fail
                    PopupManager.singleton.Popup(title: "Log in fail", body: resultString, presentationViewCont: self)
                    
                    if resultString == "Invalid Password"
                    {
                        self.passwordTextField.text = ""
                    }
                    else
                    {
                        self.ResetTextFields()
                    }
                }
                
                
                
            })
            
        }
        else
        {
            //promt to key in username or pass
            if username == "" && password == ""
            {
                PopupManager.singleton.Popup(title: "Empty Field", body: "Please key in your username and password", presentationViewCont: self)
            }
            else if usernameTextField.text == ""
            {
                PopupManager.singleton.Popup(title: "Empty Field", body: "Please key in your username", presentationViewCont: self)
            }
            else if passwordTextField.text == ""
            {
                PopupManager.singleton.Popup(title: "Empty Field", body: "Please key in your password", presentationViewCont: self)
            }

        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        SignIn()
        return false
    }
    
    func Dismiss()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func ForgotPasswordButtonPressed()
    {
        
    }
    
    func CreateAccountButtonPressed()
    {
        self.present(NewAccountFormViewController.singleton, animated: true,completion: nil)
    }
    
    func ResetTextFields()
    {
        usernameTextField.text = ""
        passwordTextField.text = ""
    }
    
    func EnableTextFields()
    {
        usernameTextField.isEnabled = true
        usernameTextField.textColor = UIColor.black
        passwordTextField.isEnabled = true
        passwordTextField.textColor = UIColor.black


    }
    
    func DisableTextFields()
    {
        usernameTextField.isEnabled = false
        usernameTextField.textColor = UIColor.gray
        passwordTextField.isEnabled = false
        passwordTextField.textColor = UIColor.gray

    }
    
    func SetIconToLoading()
    {
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
        grayViewOverlay.alpha = 1
    }
    
    func SetIconToDoneLoading()
    {
        activityIndicator.alpha = 0
        activityIndicator.stopAnimating()
        grayViewOverlay.alpha = 0

    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    
    func addKeyboardToolBar()
    {
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: Sizing.ScreenWidth(), height: 30))
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelNumberPad)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneWithNumberPad))]
        numberToolbar.sizeToFit()
        passwordTextField.inputAccessoryView = numberToolbar
        usernameTextField.inputAccessoryView = numberToolbar
    }
    
    func cancelNumberPad()
    {
        let txtfield = FirstResponder()
        txtfield.endEditing(true)
        
    }
    
    func doneWithNumberPad()
    {
        let txtfield = FirstResponder()

        if txtfield == usernameTextField
        {
            passwordTextField.becomeFirstResponder()
        }
        else
        {
            passwordTextField.resignFirstResponder()
        }

        
        
        
        
        txtfield.endEditing(true)
    }
    
    
    func FirstResponder() -> UITextField
    {
        
        if usernameTextField.isFirstResponder
        {
            return usernameTextField
        }
        else if passwordTextField.isFirstResponder
        {
            return passwordTextField
        }
        else
        {
            return usernameTextField
        }
    }
    
    //text field delegate functions
    //notifictioncenter
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
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.scrollView.isScrollEnabled = false
    }
}
