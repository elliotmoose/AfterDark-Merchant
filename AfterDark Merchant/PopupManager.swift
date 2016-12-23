//
//  PopupManager.swift
//  AfterDark
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 3/11/16.
//  Copyright © 2016 kohbroco. All rights reserved.
//

import Foundation
import UIKit
class PopupManager{
    static let singleton = PopupManager()
    
    func Popup(title : String , body : String, presentationViewCont : UIViewController)
    {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }
        }))
        
        presentationViewCont.present(alert, animated: true, completion: nil)
    }
    
    func Popup(title : String , body : String, presentationViewCont : UIViewController, handler: @escaping ()->Void)
    {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            
            //call back when ok clicked
            handler();
            
        }))
        
        presentationViewCont.present(alert, animated: true, completion: nil)
    }
    
    func PopupWithCancel(title : String , body : String, presentationViewCont : UIViewController, handler: @escaping ()->Void)
    {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
            
            //call back when ok clicked
            handler();
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in

            
        }))
        
        
        presentationViewCont.present(alert, animated: true, completion: nil)
    }
}
