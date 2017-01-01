import Foundation
class Account {
    
    
    static let singleton = Account()
    var Merchant_username: String?
    var Merchant_ID :String?
    var Merchant_Bar_ID : String?
    var Merchant_Email : String?
    var Merchant_Bar : Bar?
    
    init() {
        Merchant_username = ""
        
    }
    

    func Login(_ username:String,password:String,handler: @escaping (_ success:Bool,_ resultString : String)->Void)
    {
        let urlLogin = Network.domain + "Login.php"
        let postParam = String("username=\(username.AddPercentEncodingForURL(plusForSpace: true)!)&password=\(password.AddPercentEncodingForURL(plusForSpace: true)!)")
        
        Network.singleton.DataFromUrlWithPost(urlLogin,postParam: postParam!,handler: {(success,output) -> Void in
            if let output = output
            {
                
                do
                {
                    if let dict = try JSONSerialization.jsonObject(with: output, options: .allowFragments) as? NSDictionary
                    {
                        if let success = dict["success"] as? String
                        {
                            if success == "true"
                            {
                                
                                if let merchantDetails = dict["detail"] as? NSDictionary
                                {
                                    guard let username = merchantDetails["Username"] as? String else {return}
                                    guard let email = merchantDetails["Merchant_Email"] as? String else {return}
                                    
                                    if let ID = merchantDetails["Merchant_ID"] as? String
                                    {
                                        self.Merchant_ID = ID
                                    }
                                    else if let ID = merchantDetails["Merchant_ID"] as? Int
                                    {
                                        self.Merchant_ID = "\(ID)"
                                    }
                                    
                                    if let barID = merchantDetails["Bar_ID"] as? String
                                    {
                                        self.Merchant_Bar_ID = barID
                                    }
                                    else if let barID = merchantDetails["Bar_ID"] as? Int
                                    {
                                        self.Merchant_Bar_ID = "\(barID)"
                                    }
                                    
                                    self.Merchant_username = username
                                    self.Merchant_Email = email
                                }
                                
                                
                                
                                
                                
                                self.Save()
                                
                                DispatchQueue.main.async {
                                    handler(true,"Login Success")
                                }
                            }
                            else
                            {
                                if let detail = dict["detail"] as? String
                                {
                                    if detail == "Invalid Password"
                                    {
                                        DispatchQueue.main.async {
                                            handler(false,"Invalid Password")
                                        }
                                    }
                                    
                                    if detail == "Invalid ID"
                                    {
                                        DispatchQueue.main.async {
                                            handler(false,"Invalid Username")
                                        }
                                    }
                                    
                                    DispatchQueue.main.async {
                                        handler(false,detail)
                                    }
                                    
                                }
                                else
                                {
                                    DispatchQueue.main.async {
                                        handler(false,"Cant log in, server fault")
                                    }
                                }
                                
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                handler(false,"Cant log in, server fault")
                            }
                        }
                    }
                    else
                    {
                        
                    }
                }
                catch let error as NSError
                {
                    print(error)
                    DispatchQueue.main.async {
                        let errorString = String(data: output, encoding: .utf8)
                        handler(false,"Cant log in, server fault - \(errorString!)")
                    }
                    
                }
                
            }
            else
            {
                DispatchQueue.main.async {
                    handler(false,"Can't connect to server")
                }
            }
        })
    }
//
//    func CreateNewAccount(_ username: String, _ password: String, _ email: String, _ dateOfBirth : String, handler: @escaping (_ success : Bool, _ response: String, _ dictOut : NSDictionary)-> Void)
//    {
//
//        
//        
//        
//        let postParam = "username=\(username.AddPercentEncodingForURL(plusForSpace: true)!)&password=\(password.AddPercentEncodingForURL(plusForSpace: true)!)&email=\(email.AddPercentEncodingForURL(plusForSpace: true)!)&DOB=\(dateOfBirth.AddPercentEncodingForURL(plusForSpace: true)!)"
//        let urlCreateAccount = Network.domain + "AddNewAccount.php"
//        
//        Network.singleton.DataFromUrlWithPost(urlCreateAccount,postParam: postParam,handler: {(success,output) -> Void in
//        
//            if let output = output
//            {
//                let jsonData = (output as NSData).mutableCopy() as! NSMutableData
//                
////                let stringData = String(data: jsonData as Data, encoding: .utf8)
////                NSLog(stringData!)
//                
//                let dict = Network.JsonDataToDict(jsonData)
//                
//                if dict["success"] as! String == "false"
//                {
//                    let errorMessage = dict["detail"] as! String
//                    DispatchQueue.main.async {
//                        handler(false,errorMessage,dict)
//                    }
//                }
//                
//                if dict["success"] as! String == "true"
//                {
//                    DispatchQueue.main.async {
//                        handler(true,"Account created",dict)
//                    }
//                    
//                }
//            }
//            
//            DispatchQueue.main.async {
//                handler(false,"cant connect to server",dict)
//            }
//        
//        })
//    }
    
       

    
    func LogOut()
    {
        let UD = UserDefaults.standard
        
        Merchant_username = ""
        Merchant_ID = ""
        Merchant_Email = ""
        
        UD.setValue("",forKey: "user_name")
        UD.setValue("",forKey: "User_ID")
        UD.setValue("",forKey: "User_Email")
        UD.setValue("", forKey: "Bar_ID")

    }
    
	func Save()
	{
	    let UD = UserDefaults.standard
	    UD.setValue(Merchant_username,forKey: "user_name")
	    UD.setValue(Merchant_ID,forKey: "User_ID")
	    UD.setValue(Merchant_Email,forKey: "User_Email")
        UD.setValue(Merchant_Bar_ID, forKey: "Bar_ID")
	}

	func Load()
	{
        if Settings.ignoreUserDefaults == false
        {
            
            let UD = UserDefaults.standard
            
            self.Merchant_username = UD.value(forKey: "user_name") as? String
            
            self.Merchant_ID = UD.value(forKey: "User_ID") as? String
            self.Merchant_Email = UD.value(forKey: "User_Email") as? String
            self.Merchant_Bar_ID = UD.value(forKey: "Bar_ID") as? String
        }
	}
}
