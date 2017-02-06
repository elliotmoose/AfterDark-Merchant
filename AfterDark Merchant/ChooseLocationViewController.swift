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

//things to do:
//view appear -> select current
//choose location -> set currently selected
//done button -> set updating bar and call "text changed"

protocol LocationToProfileDelegate : class {
    func SetUpdatingBarLocation()
}

class ChooseLocationViewController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {

    static let singleton = ChooseLocationViewController(nibName: "ChooseLocationViewController", bundle: Bundle.main)
    
    var mapView : GMSMapView?
    let targetImage = #imageLiteral(resourceName: "target1x")
    var focusLocationButton : UIButton?
    var mapBehaviorMode = 0
    var locationManager : CLLocationManager?
    var searchResultsTableView = UITableView()
    let marker = GMSMarker()
    weak var delegate : LocationToProfileDelegate?
    //search bar
    @IBOutlet weak var searchField: UITextField!
    var searchResults = [GMSAutocompletePrediction]()
    
    let dropPin = MKPinAnnotationView()
    
    //currently selected location
    var currentLat : Double = 0
    var currentLong : Double = 0
    var currentAddress = ""
    
    
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
        

        
        
        let camera = GMSCameraPosition.camera(withLatitude: currentLat, longitude: currentLong, zoom: 17)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView?.isMyLocationEnabled = true
        mapView?.delegate = self
        mapView?.frame = view.frame
        
        marker.map = mapView
        
        self.view.addSubview(mapView!)
        self.view.sendSubview(toBack: mapView!)
        
        //focusLocationButton
        let targetWidth : CGFloat = 45
        focusLocationButton = UIButton(frame: CGRect(x: Sizing.ScreenWidth() - 20 - targetWidth, y: Sizing.ScreenHeight() - Sizing.navBarHeight - Sizing.statusBarHeight - Sizing.tabBarHeight - targetWidth - 20, width: targetWidth, height: targetWidth))
        
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

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(DoneButtonPressed))
        self.navigationItem.rightBarButtonItem = doneButton
    }

    
    override func viewDidAppear(_ animated: Bool) {
        //present(autoCompleteViewCont, animated: true, completion: nil)
        view.layoutSubviews()
        view.layoutIfNeeded()
        
        self.focusLocation(self.currentLat, self.currentLong)

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
    
    
    func DoneButtonPressed()
    {
        //call delegate function to set updating bar
        self.delegate?.SetUpdatingBarLocation()
        
        //dismiss
        self.navigationController?.popViewController(animated: true)
    }
    
    //================================================================================================
    //                                          MAP RELATED FUNCTIONS
    //================================================================================================
    
    func SetMarker(_ lat : CLLocationDegrees, _ long : CLLocationDegrees)
    {
   
        // Creates a marker in the center of the map.
        
        marker.position = CLLocationCoordinate2D(latitude: lat,longitude: long)
    }
    
    func focusLocation(_ lat : CLLocationDegrees, _ long : CLLocationDegrees)
    {
        DispatchQueue.main.async {
            
            //add marker
            self.SetMarker(lat,long)
            
            //move to location
            let location = CLLocationCoordinate2D(latitude: self.currentLat, longitude: self.currentLong)
            self.mapView?.animate(toLocation: location)
        }
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
    
    
    //================================================================================================
    //                                          RESULTS TABLEVIEW FUNCTIONS
    //================================================================================================
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
        
        let result = searchResults[indexPath.row]
        
        let resultString = result.attributedFullText.string
        
        cell?.textLabel?.text = "\(resultString)"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let placeClient = GMSPlacesClient.shared()
        let prediction = searchResults[indexPath.row]
        
        guard let placeID = prediction.placeID else {return}
        
        placeClient.lookUpPlaceID(placeID, callback: {
            (result,error) -> Void in
            
            guard let result = result else {return}
            self.currentLat = Double(result.coordinate.latitude)
            self.currentLong = Double(result.coordinate.longitude)
            self.currentAddress = result.formattedAddress!
            
            self.focusLocation(self.currentLat, self.currentLong)

            
        })
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.alpha = 0
    }



}
