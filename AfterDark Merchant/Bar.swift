import UIKit
class Bar{
    var name : String
    var ID : String
    var rating = Rating()
    var reviews = [Review]()
    
    var discounts = [Discount]()
    
    //images
    var icon: UIImage?
    var Images: [UIImage] = []
    var maxImageCount = -1
    
    var description : String = ""
    var tags : String = ""
    //contact
    var contact : String = ""
    var website : String = ""
    
    //location
    var loc_long : Double = 0
    var loc_lat : Double = 0
    var address : String = ""
    
    //opening hours
    var openClosingHours = [String]()
    
    
    var bookingAvailable: String
    
    
    
    //rating
    
    init()
    {
        name = "Untitled"
        contact = ""
        website = ""
        ID = ""
        bookingAvailable = "0"

        for _ in 0...6
        {
            openClosingHours.append("nil")
        }
        
        
    }
    
    func populate(name : String, ID:String,rating:Rating,reviews:[Review],discounts : [Discount],icon : UIImage,images : [UIImage], maximagecount : Int, description : String, contact : String, website : String, loc_long : Double, loc_lat : Double, address : String)
    {
        self.name = name
        self.ID = ID
        self.rating = rating
        self.reviews = reviews
        self.discounts = discounts
        self.icon = icon
        self.Images = images
        self.maxImageCount = maximagecount
        self.description = description
        self.contact = contact
        self.website = website
        self.loc_long = loc_long
        self.loc_lat = loc_lat
        self.address = address
    }
    
    
}
