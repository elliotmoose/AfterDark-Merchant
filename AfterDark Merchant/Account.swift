import Foundation
class Account {
    
    
    static let singleton = Account()
    var user_name: String?
    var user_ID :String?
    var user_Email : String?
    
    init() {

        
    }
    

    func Login(_ username:String,password:String,handler: @escaping (_ success:Bool,_ resultString : String)->Void)
    {
        let urlLogin = Network.domain + "Login.php"
        let postParam = String("username=\(username)&password=\(password)")
        
        Network.singleton.DataFromUrlWithPost(urlLogin,postParam: postParam!,handler: {(success,output) -> Void in
            if let output = output
            {
                
                let mutableOut = (output as NSData).mutableCopy() as! NSMutableData

                //output here is a dict array
                let array = Network.JsonDataToDictArray(mutableOut)
                
                guard array.count > 0 else
                {
                    NSLog("Cant log in,check connection")
                    return
                }
                let dict = array[0] 
                
                
                let outputString = dict["result"] as! String
                if outputString == "Login Success"
                {
                    self.user_name = dict["User_Name"] as? String
                    self.user_Email = dict["User_Email"] as? String
                    self.user_ID = dict["User_ID"] as? String

                    self.Save()
                    
                    DispatchQueue.main.async {
                        handler(true,"Login Success")
                    }
                }
                else if outputString == "Invalid Password"
                {
                    DispatchQueue.main.async {
                        handler(false,"Invalid Password")
                    }
                }
                else if outputString == "Invalid ID"
                {
                    DispatchQueue.main.async {
                        handler(false,"Invalid Username")
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

    func CreateNewAccount(_ username: String, _ password: String, _ email: String, _ dateOfBirth : String, handler: @escaping (_ success : Bool, _ response: String, _ dictOut : NSDictionary)-> Void)
    {

        
        
        
        let postParam = "username=\(username)&password=\(password)&email=\(email)&DOB=\(dateOfBirth)"
        let urlCreateAccount = Network.domain + "AddNewAccount.php"
        
        Network.singleton.DataFromUrlWithPost(urlCreateAccount,postParam: postParam,handler: {(success,output) -> Void in
        
            if let output = output
            {
                let jsonData = (output as NSData).mutableCopy() as! NSMutableData
                
//                let stringData = String(data: jsonData as Data, encoding: .utf8)
//                NSLog(stringData!)
                
                let dict = Network.JsonDataToDict(jsonData)
                
                if dict["success"] as! String == "false"
                {
                    let errorMessage = dict["detail"] as! String
                    DispatchQueue.main.async {
                        handler(false,errorMessage,dict)
                    }
                }
                
                if dict["success"] as! String == "true"
                {
                    DispatchQueue.main.async {
                        handler(true,"Account created",dict)
                    }
                    
                }
            }
        
        })
    }
    
    func LogOut()
    {
        let UD = UserDefaults.standard
        
        user_name = ""
        user_ID = ""
        user_Email = ""
        
        UD.setValue("",forKey: "user_name")
        UD.setValue("",forKey: "User_ID")
        UD.setValue("",forKey: "User_Email")
    }
    
	func Save()
	{
	    let UD = UserDefaults.standard
	    UD.setValue(user_name,forKey: "user_name")
	    UD.setValue(user_ID,forKey: "User_ID")
	    UD.setValue(user_Email,forKey: "User_Email")
	}

	func Load()
	{
        if Settings.ignoreUserDefaults == false
        {
            
            let UD = UserDefaults.standard
            
            self.user_name = UD.value(forKey: "user_name") as? String
            
            self.user_ID = UD.value(forKey: "User_ID") as? String
            self.user_Email = UD.value(forKey: "User_Email") as? String
        }
	}
}
