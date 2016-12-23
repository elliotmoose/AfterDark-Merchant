import Foundation


class Network {
    
    var session : URLSession
    static let singleton = Network()

    
    //Urls
    //static let domain = "http://mooselliot.net23.net/"
    static let domain = "http://localhost/AfterDarkServer/"
    
    
    init()
    {
        session = URLSession.shared
    }
    
    //Load Method
    func DataFromUrl(_ inputUrl: String, handler: @escaping (_ success:Bool,_ output : Data?) -> Void) {
        
        let url = URL(string: inputUrl)!
        
        let task = session.dataTask(with: url)
        { data, response, error in
            
            if let error = error
            {
                print(error)
                
                DispatchQueue.main.async {
                    handler(false,nil)
                }
            }
            else if let data = data
            {
                DispatchQueue.main.async {
                    handler(true,data)
                }
            }
            
        }
        
        task.resume()
        
    }
    
    func StringFromUrl(_ inputUrl: String, handler: @escaping (_ success:Bool,_ output : String?) -> Void) {
        
        let url = URL(string: inputUrl)!
        
        let task = session.dataTask(with: url)
        {
            data, response, error in
            
            if let error = error
            {
                print(error)
                DispatchQueue.main.async {
                    handler(false,nil)
                }
            }
            else if let data = data
            {
                let outString = String(data: data, encoding: String.Encoding.utf8)
                DispatchQueue.main.async {
                    handler(true,outString)
                }
            }
            
        }
        
        task.resume()
        
    }
    
    //post functions
    func StringFromUrlWithPost(_ inputUrl: String, postParam: String,handler: @escaping (_ success:Bool,_ output : String?) -> Void) {
        
        let url = URL(string: inputUrl)!
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postParam.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        { data, response, error in
            
            
            if let error = error
            {
                print(error)
                
                DispatchQueue.main.async {
                    handler(false,nil)
                }
                
                
            }
            else if let data = data
            {
                let outString = String(data: data, encoding: String.Encoding.utf8)
                DispatchQueue.main.async {
                    handler(true,outString)
                }
            }
            
        }
        
        task.resume()
        
    }
    
    func DataFromUrlWithPost(_ inputUrl: String, postParam: String,handler: @escaping (_ success:Bool,_ output : Data?) -> Void) {
        
        let url = URL(string: inputUrl)!
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postParam.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        { data, response, error in
            
            
            if let error = error
            {
                print(error)
                
                DispatchQueue.main.async {
                    handler(false,nil)
                }
                
                
            }
            else if let data = data
            {
                DispatchQueue.main.async {
                    handler(true,data)
                }
            }
            
        }
        
        task.resume()
        
    }
    
    
    func DictArrayFromUrl(_ inputUrl: String, handler: @escaping (_ success:Bool,_ output : [NSDictionary]) -> Void) {
        
        let url = URL(string: inputUrl)!
        
        let task = session.dataTask(with: url)
        {
            data, response, error in
            
            if let error = error
            {
                print(error)
                handler(false,[])
                
            }
            else if let data = data
            {
                let out = (data as NSData).mutableCopy() as! NSMutableData
                
                DispatchQueue.main.async {
                    handler(true,Network.JsonDataToDictArray(out))
                    
                }
            }
            
        }
        
        task.resume()
        
    }
    
    //json data management
    static func JsonDataToDictArray(_ data: NSMutableData) -> [NSDictionary]
    {
        var output = [NSDictionary]()
        var tempArr: NSMutableArray = NSMutableArray()
        
        do{
            
            
            
            let arr = try JSONSerialization.jsonObject(with: data as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! Array<Any>
            if arr.count == 0
            {
                print("invalid array, cant parse to JSON")
                return []
            }
            tempArr = NSMutableArray(array: arr)
            for index in 0...(tempArr.count - 1)
            {
                let intermediate = tempArr[index]
                if intermediate is NSDictionary
                {
                    let dict = intermediate as! NSDictionary
                    output.append(dict)
                }
            }
            
        } catch let error as NSError {
            print(error)
            
        }
        
        return output
    }
    
    static func JsonDataToDict(_ data : NSMutableData) -> NSDictionary
    {
        var output = NSDictionary()
        
        do{
            
            output = try JSONSerialization.jsonObject(with: data as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            
            
        } catch let error as NSError {
            print(error)
            
        }
        
        return output
    }
}


