import Foundation
import UIKit

class Network {
    
    var session : URLSession
    static let singleton = Network()

    
    //Urls
    //static let domain = "http://mooselliot.net23.net/"
    static let domain = "http://localhost/AfterDarkServer/Merchant/"
    static let clientDomain = "http://localhost/AfterDarkServer/"
//    static let domain = "http://mooselliot.com/AfterDarkServer/Merchant/"
//    static let clientDomain = "http://mooselliot.com/AfterDarkServer/"

    
    init()
    {
        session = URLSession.shared
        session.configuration.timeoutIntervalForRequest = 10
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
            else
            {
                DispatchQueue.main.async {
                    handler(false,nil)
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
            else
            {
                DispatchQueue.main.async {
                    handler(false,nil)
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
            else
            {
                DispatchQueue.main.async {
                    handler(false,nil)
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
            else
            {
                DispatchQueue.main.async {
                    handler(false,nil)
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
            else
            {
                DispatchQueue.main.async {
                    handler(false,[])
                }
            }
            
        }
        
        task.resume()
        
    }
    
    func UploadImages(_ url : String, _ images : [UIImage], _ handler : @escaping (Bool,Data?)->Void)
    {
        guard images.count != 0 else {return}
        
        //init request
        guard let url = URL(string: url) else {return}
        let request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)
        request.httpMethod = "POST"
        
        //boundary
        let boundary = GenerateBoundaryString()
        let boundaryImplementString = "--\(boundary)"
        
        //content type
        let contentTypeValue = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentTypeValue, forHTTPHeaderField: "Content-Type")
        
        //body
        let body = NSMutableData()
        
        //authentication body
        guard let Merch_ID = Account.singleton.Merchant_ID else {return}
        guard let authenData = TextIntoFormFragmentData(textName: "Merchant_ID", textValue: Merch_ID, boundary: "--\(boundary)") else
        {
            NSLog("Unable to process internal authentication")
            return
        }
        
        body.append(authenData)
        
        //image body
        for i in 0...images.count-1
        {
            let image = images[i]
            if let imageFormData = ImageIntoFormFragmentData(image: image, imageName: "\(i)", boundary: "--\(boundary)")
            {
                body.append(imageFormData)
            }
            else
            {
                NSLog("Error creating formData from UIImage")
            }
        }
        
        guard let lineBreak = "\r\n".data(using: .utf8) else {return}
        body.append(lineBreak)
        guard let boundaryData = "--\(boundary)--".data(using: .utf8) else {return}
        body.append(boundaryData)
        
        request.httpBody = body as Data

        if let bodyString = String(data: body as Data, encoding: .utf8)
        {
            print(bodyString)
        }
        
        
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
            else
            {
                DispatchQueue.main.async {
                    handler(false,nil)
                }
            }
            
        }
        
        task.resume()
        
        
        
    }
    
    private func GenerateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func ImageIntoFormFragmentData(image : UIImage,imageName : String, boundary : String)->Data?
    {
        let output = NSMutableData()
        
        guard let boundaryData = boundary.data(using: .utf8) else {return nil}
        guard let lineBreak = "\r\n".data(using: .utf8) else {return nil}
        
        guard let jpgImage = UIImageJPEGRepresentation(image, 1) else {return nil}
        
        let fileName = "\(imageName).jpg"
        
        //line break
        output.append(lineBreak)
        
        //boundary
        output.append(boundaryData)
        
        //line break
        output.append(lineBreak)
        
        //content disposition
        guard let contentDisp = "Content-Disposition: form-data; name=\"\(imageName)\"; filename=\"\(fileName)\"".data(using: .utf8) else {return nil}
        output.append(contentDisp)
        
        //line break
        output.append(lineBreak)
        
        //content type
        guard let contentType = "Content-Type: image/jpeg".data(using: .utf8) else {return nil}
        output.append(contentType)
        
        //line break
        output.append(lineBreak)
        output.append(lineBreak)

        if let outputString = String(data: output as Data, encoding: .utf8)
        {
            print(outputString)
        }
        
        
        //content data
        output.append(jpgImage)
        
        //line break
        output.append(lineBreak)
        
        return output as Data
    }
    
    //MerchantID
    func TextIntoFormFragmentData(textName : String, textValue : String,  boundary : String) -> Data?
    {
        let output = NSMutableData()
        
        guard let boundaryData = boundary.data(using: .utf8) else {return nil}
        guard let lineBreak = "\r\n".data(using: .utf8) else {return nil}
        
        //boundary
        output.append(boundaryData)
        
        //line break
        output.append(lineBreak)
        
        //content disposition
        guard let contentDisp = "Content-Disposition: form-data; name=\"\(textName)\"".data(using: .utf8) else {return nil}
        output.append(contentDisp)
        
        //line break
        output.append(lineBreak)
        
        //content type
        guard let contentType = "Content-Type: text/plain".data(using: .utf8) else {return nil}
        output.append(contentType)
        
        //line break
        output.append(lineBreak)
        
        //content data
        guard let paramData = textValue.data(using: .utf8) else {return nil}
        
        
        //line break
        output.append(lineBreak)
        
        output.append(paramData)
        
        
        //line break
        output.append(lineBreak)
        
        return output as Data
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


