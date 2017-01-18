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
        
        
        self.navigationController?.navigationBar.tintColor = ColorManager.themeBright
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.barStyle = .black;
        
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Mohave", size: 20)!,NSForegroundColorAttributeName : ColorManager.themeBright]
    }

    override func viewWillAppear(_ animated: Bool) {
        qrCodeView.BeginScan()
    }

    override func viewWillDisappear(_ animated: Bool) {
        qrCodeView.StopScan()
    }
    func QrCodeCaptured(output: String) {

        //freeze display
        qrCodeView.StopScan()
        
        //activity indicator
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
        
        //upload discount request -> when finish -> stop activity indicator
        Network.singleton.DataFromUrlWithPost(Network.domain + "AddDiscountRequest.php?", postParam: output, handler: {
            (success,output) -> Void in
            
            self.activityIndicator.alpha = 0
            self.activityIndicator.stopAnimating()
            
            
        
        })
        
    }


}
