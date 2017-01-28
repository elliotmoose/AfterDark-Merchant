//
//  QRCodeScannerViewController.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 6/12/16.
//  Copyright © 2016 Kohbroco. All rights reserved.
//

import UIKit

class QRCodeScannerViewController: UIViewController ,QrCodeViewDelegate{

    var qrCodeView = QrCodeCaptureView()

    var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    let scanAgainLabel = UILabel(frame: CGRect(x: 0, y: Sizing.ScreenHeight()/2, width: Sizing.ScreenWidth(), height: 30))
    
    var dimOverlay = UIView(frame: CGRect(x: 0, y: 0, width: Sizing.ScreenWidth(), height: Sizing.ScreenHeight()))
   
    override func viewDidLoad() {
        super.viewDidLoad()

        //qr code view frame
        qrCodeView = QrCodeCaptureView.init(frame: self.view.frame)
        
        //color
        qrCodeView.backgroundColor = UIColor.black
        
        //subviews
        self.view.addSubview(qrCodeView)
        
        //delegates
        qrCodeView.delegate = self
        
        
        
        //activity indicator
        activityIndicator.color = UIColor.white
        activityIndicator.tintColor = UIColor.white
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        //activity indicator state
        activityIndicator.alpha = 0
        
        //dim overlay
        dimOverlay.alpha = 0
        dimOverlay.backgroundColor = UIColor.black
        self.view.addSubview(dimOverlay)

        
        self.navigationController?.navigationBar.tintColor = ColorManager.themeBright
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.barStyle = .black;
        
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Mohave", size: 20)!,NSForegroundColorAttributeName : ColorManager.themeBright]
        
        //scan again label init
        scanAgainLabel.text = "Please Scan Again"
        scanAgainLabel.alpha = 0
        self.view.addSubview(scanAgainLabel)
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        qrCodeView.BeginScan()
    }

    override func viewWillDisappear(_ animated: Bool) {
        qrCodeView.StopScan()
    }
    func QrCodeCaptured(output: String) {

        //check if output is legit
        //let qrDict = NSMutableDictionary(dictionary: ["uID":userID,                                                      "uName":username,"bID":bar_ID,"dID":discountID,"amt":amount])
        
        guard let outputData = output.data(using: .utf8) else {
            self.RevealScanAgain()
            return
        }
        
        do{

            if let outDict = try JSONSerialization.jsonObject(with: outputData, options: .allowFragments) as? NSDictionary
            {
                
                //freeze display
                qrCodeView.StopScan()
                //show activity
                self.ShowActivityIndicator()

                //data from qr code
                guard let userID = outDict["uID"] as? String else {return}
                guard let barID = outDict["bID"] as? String else {return}
                guard let discountID = outDict["dID"] as? String else {return}
                guard let username = outDict["uName"] as? String else {return}
                guard let amount = outDict["amt"] as? String else {return}
                guard let qrGeneratedDate = outDict["t"] as? TimeInterval else {return}
                
                //data from merchant
                guard let merchantBarID = Account.singleton.Merchant_Bar_ID else {return}
                guard let merchantID = Account.singleton.Merchant_ID else {return}
                
                if barID != merchantBarID
                {
                    PopupManager.singleton.Popup(title: "Oops!", body: "This discount is not valid for this bar!", presentationViewCont: self)
                    
                    qrCodeView.BeginScan()
                    self.HideActivityIndicator()
                    
                    return
                }
                
                
                //assemble parameters
                let postParam = "User_ID=\(userID)&Bar_ID=\(barID)&Discount_ID=\(discountID)&User_Name=\(username)&Amount=\(amount)&Merchant_ID=\(merchantID)&Date=\(qrGeneratedDate)"
                
                //upload discount request -> when finish -> stop activity indicator
                Network.singleton.DataFromUrlWithPost(Network.clientDomain + "AddDiscountRequest.php", postParam: postParam, handler: {
                    (success,output) -> Void in
                    
                    self.HideActivityIndicator()

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
                                            PopupManager.singleton.Popup(title: "Success!", body: "Discount Authenticated!", presentationViewCont: self, handler: {
                                                
                                                self.qrCodeView.BeginScan()
                                            })
                                           
                                        }
                                        else if succ == "false"
                                        {
                                            guard let detail = dict["detail"] as? String else {return}
                                            PopupManager.singleton.Popup(title: "Oops!", body: detail, presentationViewCont: self, handler: {
                                                
                                                self.qrCodeView.BeginScan()
                                            })
                                        }
                                    }
                                    else
                                    {
                                        PopupManager.singleton.Popup(title: "Oops!", body: "Invalid server response format", presentationViewCont: self, handler: {
                                            self.qrCodeView.BeginScan()
                                        })
                                    }
                                    
                                }
                                else
                                {
                                    PopupManager.singleton.Popup(title: "Oops!", body: "Invalid server response format", presentationViewCont: self, handler: {
                                        self.qrCodeView.BeginScan()
                                    })
                                }
                            }
                            catch
                            {
                                PopupManager.singleton.Popup(title: "Oops!", body: "Invalid server response format", presentationViewCont: self, handler: {
                                    self.qrCodeView.BeginScan()
                                })
                            }
                        }
                        else
                        {
                            PopupManager.singleton.Popup(title: "Oops!", body: "No response from server", presentationViewCont: self, handler: {
                                self.qrCodeView.BeginScan()
                            })
                        }
                    }
                    else
                    {
                        PopupManager.singleton.Popup(title: "Oops!", body: "Please check your internet connection", presentationViewCont: self, handler: {
                            self.qrCodeView.BeginScan()
                        })
                    }
                })
                
                

            }
            else
            {
                self.RevealScanAgain()
            }
        }
        catch
        {
        }
        

        

        
    }

    func RevealScanAgain()
    {
        //scan again
        UIView.animate(withDuration: 1.5, animations: {
            self.scanAgainLabel.alpha=1
        }, completion: { (success) in
            UIView.animate(withDuration: 1.5, animations: {
                self.scanAgainLabel.alpha=0
            })
        })
    }
    
    func ShowActivityIndicator()
    {
        //dim 
        dimOverlay.alpha = 1
        
        //activity indicator
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
    }
    
    func HideActivityIndicator()
    {
        dimOverlay.alpha = 0
        
        //activity indicator
        activityIndicator.alpha = 0
        activityIndicator.stopAnimating()
    }

}
