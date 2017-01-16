//
//  ChooseLocationViewController.swift
//  AfterDark Merchant
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 22/12/16.
//  Copyright © 2016 Kohbroco. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MapKit

class ChooseLocationViewController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {

    static let singleton = ChooseLocationViewController(nibName: "ChooseLocationViewController", bundle: Bundle.main)
    
    var mapView : GMSMapView?
    let targetImage = #imageLiteral(resourceName: "target1x")
    var focusLocationButton : UIButton?
    var mapBehaviorMode = 0
    var locationManager : CLLocationManager?
    var searchResultsTableView = UITableView()
    
    
    //search bar
    @IBOutlet weak var searchField: UITextField!
    var searchResults = [GMSAutocompletePrediction]()
    
    let dropPin = MKPinAnnotationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        Bundle.main.loadNibNamed(nibNameOrNil!, owner: self, options: nil)
        
        //map init
        GMSServices.provideAPIKey(Settings.googleMapsKey)
        GMSPlacesClient.provideAPIKey(Settings.googleMapsKey)
        
        let loc_lat : Double = 0
        let loc_long : Double = 0
        let camera = GMSCameraPosition.camera(withLatitude: loc_lat, longitude: loc_long, zoom: 17)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView?.isMyLocationEnabled = true
        mapView?.delegate = self
        mapView?.frame = view.frame
        
        self.view.addSubview(mapView!)
        self.view.sendSubview(toBack: mapView!)
        
        //focusLocationButton
        let targetWidth : CGFloat = 45
        focusLocationButton = UIButton(frame: CGRect(x: Sizing.ScreenWidth() - 20 - targetWidth, y: 20, width: targetWidth, height: targetWidth))
        
        //set up button image
        focusLocationButton?.imageView?.contentMode = .scaleAspectFit
        focusLocationButton?.setImage(targetImage.withRenderingMode(.alwaysTemplate), for: .normal)
        focusLocationButton?.tintColor = ColorManager.deselectedIconColor
        focusLocationButton?.backgroundColor = UIColor.white
        focusLocationButton?.layer.cornerRadius = targetWidth/2
        focusLocationButton?.addTarget(self, action: #selector(ToggleMapBehaviour), for: .touchDown)
        view.addSubview(focusLocationButton!)
        //shadow
        focusLocationButton?.clipsToBounds = false
        focusLocationButton?.layer.shadowOpacity = 0.3
        focusLocationButton?.layer.shadowOffset = CGSize(width: 0, height: 0)
        focusLocationButton?.layer.shadowRadius = 10
        
        //location manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.distanceFilter = 10
        locationManager?.headingFilter = 5
        
        //init search bar
        searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchField.delegate = self
            //init table view
        searchResultsTableView.frame = CGRect(x: 32, y: 50, width: searchField.bounds.size.width, height: Sizing.ScreenHeight())
        searchResultsTableView.backgroundColor = UIColor.clear
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        searchResultsTableView.alpha = 0
        
        self.view.addSubview(searchResultsTableView)
        self.view.bringSubview(toFront: searchField)

        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        //present(autoCompleteViewCont, animated: true, completion: nil)
        view.layoutSubviews()
        view.layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //================================================================================================
    //                                          SEARCH BAR
    //================================================================================================

    
    //search field delegate functions
    func textFieldDidChange(_ sender: Any) {
        //query googlemaps
        let placeClient = GMSPlacesClient.shared()
        
        let filter = GMSAutocompleteFilter()
        filter.country = "SG"
        
        placeClient.autocompleteQuery(searchField.text!, bounds: nil, filter: filter, callback: {
            (results,error) -> Void in
            
            self.searchResults.removeAll()
            
            guard results != nil else {print("ERROR:" + error.debugDescription);return}
            
            for result in results!
            {
                self.searchResults.append(result)
            }
            
            //update search result dropdown list
            self.searchResultsTableView.alpha = 1
            self.searchResultsTableView.reloadData()
            
            
        })
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string.characters.count == 0
        {
            searchResults.removeAll()
            searchResultsTableView.reloadData()
            searchResultsTableView.alpha = 0
        }
        
        return true
    }


    
    //================================================================================================
    //                                          BUTTON SELECTORS
    //================================================================================================
    func ToggleMapBehaviour()
    {
        //when button is tapped
        switch mapBehaviorMode {
        case 0:
            StartFollowLocation()
        case 1:
            StopFollow()

        default:
            return
        }
        
    }
    
    func StartFollowLocation()
    {
        mapBehaviorMode = 1
        locationManager?.startUpdatingLocation()
        
        //ui
        focusLocationButton?.tintColor = ColorManager.selectedIconColor
        focusLocationButton?.setImage(targetImage.withRenderingMode(.alwaysTemplate), for: .normal)
        
        //change view angle
        mapView?.animate(toViewingAngle: 0)
        mapView?.animate(toZoom: 17)
        
    }
    
    func StopFollow()
    {
        mapBehaviorMode = 0
        locationManager?.stopUpdatingLocation()
        locationManager?.stopUpdatingHeading()
        
        //ui
        focusLocationButton?.tintColor = ColorManager.deselectedIconColor
        focusLocationButton?.setImage(targetImage.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        if gesture
        {
            StopFollow()
        }
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if mapBehaviorMode != 0
        {
            
            let location = locations.last
            if let location = location
            {
                mapView?.animate(toLocation: location.coordinate)
            }
            
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "resultCell")
        
        if cell == nil
        {
            cell = UITableViewCell()
        }
        
        let result = searchResults[indexPath.row].attributedFullText
        print(result)
        cell?.textLabel?.text = "\(result)"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let placeClient = GMSPlacesClient.shared()
        let prediction = searchResults[indexPath.row]
        
        guard let placeID = prediction.placeID else {return}
        
        placeClient.lookUpPlaceID(placeID, callback: {
            (result,error) -> Void in
            
            
            guard let result = result else {return}
            Account.singleton.Merchant_Bar?.loc_lat = Float(result.coordinate.latitude)
            Account.singleton.Merchant_Bar?.loc_long = Float(result.coordinate.longitude)
            Account.singleton.Merchant_Bar?.address = result.formattedAddress!
            
        })
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.alpha = 0
    }
    
    
    

}
