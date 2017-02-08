//
//  ViewController.swift
//  locationTrackTest
//
//  Created by Nika on 11/22/16.
//  Copyright © 2016 Nika. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
import CoreLocation
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITabBarDelegate {
   var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var theLabel: UILabel!
    @IBOutlet weak var startEndButtnHit: UIButton!
  
    @IBOutlet weak var tabStart: UITabBarItem!
   
    @IBOutlet weak var sportsView: UIView!
    @IBOutlet weak var walkButton: UIButton!
    @IBOutlet weak var runBurron: UIButton!
    @IBOutlet weak var hikeButton: UIButton!
    @IBOutlet weak var bikeButton: UIButton!

    @IBOutlet weak var mainTabBar: UITabBar!
    @IBOutlet weak var tracksTabBarItem: UITabBarItem!
    @IBOutlet weak var profileTabBarItem: UITabBarItem!
    
    var manager: CLLocationManager!
    
    let healthManager:HealthKitManager = HealthKitManager()
    var height: HKQuantitySample?
    
    let activityPicker = ActivityPicker()
    let mapView = MyMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
           }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //SAMPLE
        theLabel.text = "Location Info Here"
        
        setUpLocationManager()
        
        mapView.setUpMapView(view: theMap, delegate: self)
        mapView.zoomMap(val: 0.075, superVisor: manager, view: theMap)
        
        activityPicker.getSavedSportsButton(button: startEndButtnHit,navigationBar: navigationBar, off: true)
        activityPicker.activityPickerView(view: sportsView, walk: walkButton, run: runBurron, hike: hikeButton, bike: bikeButton)
        
    }
    
    //MARK -Healt Kit
    func getPermission(){
        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                
                self.setHeight()
            } else {
                if error != nil {
                    print(error ?? "Error HealtKitMethods")
                }
                print("Permission denied.")
            }
        }
    }

    func setHeight() {
        let heightSample = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)
        self.healthManager.getHeight(sampleType: heightSample!, completion: { (userHeight, error) -> Void in
            if( error != nil ) {
                print("Error: \(error?.localizedDescription)")
                return
            }
            
            var heightString = ""
            self.height = userHeight as? HKQuantitySample
            
            // The height is formatted to the user's locale.
            if let meters = self.height?.quantity.doubleValue(for: HKUnit.meter()) {
                let formatHeight = LengthFormatter()
                formatHeight.isForPersonHeightUse = true
                heightString = formatHeight.string(fromMeters: meters)
            }
                DispatchQueue.main.async(execute: { () -> Void in
                heightString_Var = heightString
            })
        })
        
    }

    
    //MARK -TabBar controller
    var viewController0: UIViewController?
    var viewController1: UIViewController?
    var viewController2: UIViewController?

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        switch item.tag {
        case 0:
            if viewController0 == nil {
                
                viewController0 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as!  ViewController
                
            }
            present(viewController0!, animated: false, completion: nil)
            break
        case 1:
            if viewController1 == nil {
                
                viewController1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TracksVC") as! TracksVC
            }
             present(viewController1!, animated: false, completion: nil)
            break
          
        case 2:
            if viewController2 == nil {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                viewController2 = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            }
            present(viewController2!, animated: false, completion: nil)
            break
            
        default:
            break
            
        }
        
    }
   
        
//MARK: -Setup Location Manager
    func setUpLocationManager() {
    if (CLLocationManager.locationServicesEnabled()) {
    manager = CLLocationManager()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.activityType = .fitness
    manager.requestAlwaysAuthorization()
    manager.allowsBackgroundLocationUpdates = true
        
    } else {
    theLabel.text = "Location services are not enabled"
    }
        
 }
   
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        theLabel.text = "\(locations[0])"
        myLocations.append(locations[0] as CLLocation)
        
        let spanX = 0.007
        let spanY = 0.007
        
        //Testing
        var location = CLLocation()
        for L in myLocations {
           location = L
        }
        let newRegion = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        theMap.setRegion(newRegion, animated: true)
        
        if (myLocations.count > 1){
            let sourceIndex = myLocations.count - 1
            let destinationIndex = myLocations.count - 2
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            let polyline = MKPolyline(coordinates: &a, count: a.count)
            polyline.title = "polyline"
            theMap.add(polyline)
        }
        
        let loc = locations.first!
        
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemaks, error)->Void in
            if error != nil {
                print("Reverse geocoder filed with error: \(error!.localizedDescription)")
                return
            }
            if (placemaks?.count)! > 0 {
                let pm = placemaks![0]
                if pm.subLocality != nil {
                    activityNameTF_String = "\(pm.subLocality!) \(activity_String)"
                } else {
                    activityNameTF_String = "\(pm.administrativeArea!) \(activity_String)"
                }
                
            } else {
                print("Problem with the data recives drom geocoder")
            }
        })
        
        if startLocation == nil {
            startLocation = locations.first as CLLocation!
        } else {
            let lastDistance = lastLocation.distance(from: locations.last as CLLocation!)
            distanceTraveled += lastDistance * 0.000621371
            distanceLabel_String = String(format: "%.2f", distanceTraveled)
            //print(distanceLabel_String)
           
            
        }
        
        lastLocation = locations.last as CLLocation!

    }
    
    func removeOveraly()
    {
        // Overlays that must be removed from the map
        var overlaysToRemove = [MKOverlay]()
        
        // All overlays on the map
        let overlays = self.theMap.overlays
        
        for overlay in overlays
        {
            if overlay.title! == "polyline"
            {
                overlaysToRemove.append(overlay)
            }
        }
        
        self.theMap.removeOverlays(overlaysToRemove)
    }
    

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        for location in myLocations {
            if location.speed > 0 && location.speed <= 0.5 {
                polylineRenderer.strokeColor = polyLineColor_red()
            } else if location.speed > 0.5 && location.speed <= 1 {
                polylineRenderer.strokeColor = polyLineColor_red1()
            } else if location.speed > 1.5 && location.speed <= 2 {
                polylineRenderer.strokeColor = polyLineColor_orange()
            } else if location.speed > 2 && location.speed <= 2.5 {
                polylineRenderer.strokeColor = polyLineColor_orange1()
            } else if location.speed > 2.5 && location.speed <= 3 {
                polylineRenderer.strokeColor = polyLineColor_yellow()
            } else if location.speed > 3 && location.speed <= 3.5{
                polylineRenderer.strokeColor = polyLineColor_yellow1()
            } else if location.speed > 3.5 {
                polylineRenderer.strokeColor = polyLineColor_green()
            } else {
               polylineRenderer.strokeColor = polyLineColor_red()
            }
        }
        polylineRenderer.lineWidth = 8
        return polylineRenderer
       
    }
    
// need to come back
//    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        print(newHeading.magneticHeading)
//        //theMap.camera.heading = newHeading.magneticHeading
//    }

   //MARK -Updare Activity Time
    func updateTime() {
//can be wrong
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        var timePassed: TimeInterval = currentTime - zeroTime
        let hours = UInt8(timePassed / 3600.0)
        timePassed -= (TimeInterval(hours) * 3600)
        let minutes = UInt8(timePassed / 60.0)
        timePassed -= (TimeInterval(minutes) * 60)
        let seconds = UInt8(timePassed)
        timePassed -= TimeInterval(seconds)
        //let millisecsX10 = UInt8(timePassed * 100)
        
        let strHours = String(format: "%02d", hours)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        //let strMSX10 = String(format: "%02d", millisecsX10)
        
        timeLabel_String = "\(strHours):\(strMinutes):\(strSeconds)"
        print(timeLabel_String)
        
        if timeLabel_String == "60:00:00" {
            timer.invalidate()
            manager.stopUpdatingLocation()
        }
    }
    
    //MARK: -Start/End Updating Locations
    func startUpdatingLocation(){
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.updateTime), userInfo: nil, repeats: true)
        zeroTime = NSDate.timeIntervalSinceReferenceDate
        if (CLLocationManager.locationServicesEnabled()) {
            
            manager.startUpdatingLocation()
           // manager.startUpdatingHeading()
            
        } else {

            
            self.theLabel.text = "Location services are not enabled"
        }
        
    }
    
    func startUpdatingLocation_SetUp(){
        tabStart.title = "END"
        swipeUpSportsPick.isEnabled = false
        tapGesture.isEnabled = false
        activityPicker.getSavedSportsButton(button: self.startEndButtnHit,navigationBar: self.navigationBar, off: false)
    }
    
    func endUpdatingLocation(){
         timer.invalidate()
         manager.stopUpdatingLocation()
    }
    
    func endUpdatingLocation_SetUp(){
        tabStart.title = "START"
        swipeUpSportsPick.isEnabled = true
        tapGesture.isEnabled = true
        mapView.zoomMap(val: 0.015, superVisor: manager, view: theMap)
        theLabel.text = "Location Info Here"
        activityPicker.getSavedSportsButton(button: startEndButtnHit,navigationBar: navigationBar, off: true)
       
    }
    
//MARK: -PopUpViews
    func popUpCountDown() {
        //Pop Up View
        let popUp = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CountDown") as! CountDownVC
        self.addChildViewController(popUp)
        popUp.view.frame = self.view.frame
        self.view.addSubview(popUp.view)
        popUp.didMove(toParentViewController: self)
        //wait
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
            //Remove popUp
            popUp.view.removeFromSuperview()
            //Do Map
            self.startUpdatingLocation()
            self.startUpdatingLocation_SetUp()
        })
    }
    
    func popUpActivityManager() {
        // PopUp to Save
        let popUp = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUpActivityDone") as! PopUpActivityDon
        self.addChildViewController(popUp)
        popUp.view.frame = self.view.frame
        self.view.addSubview(popUp.view)
        popUp.didMove(toParentViewController: self)
        
    }
    
       var launchBool: Bool = false {
        didSet {
            if launchBool == true {
                popUpCountDown()
             
              
            } else {
                
                
                //distanceLabel_String = "0.00"
                //timeLabel_String = "0:0"
                //paceLabel_String = "0.00"
                //altitudeLabel_String = "0.00"
                
               
                let alertController = UIAlertController(title: "Are You Done?", message: "If not press cancel to continue", preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
                    (action: UIAlertAction) in
                    
                    self.launchBool = true
                    print("You've pressed Cancel Button")
                }
                let oKAction = UIAlertAction(title: "OK", style: .default)
                {
                    (action: UIAlertAction) in
                    self.popUpActivityManager()
                    self.endUpdatingLocation_SetUp()
                    self.endUpdatingLocation()
                    self.removeOveraly()

                    
                    self.endUpdatingLocation()
                    
                    }

                alertController.addAction(oKAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    
  //MARK: -Guestures for sports picker view
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet var swipeDownsportsPick: UISwipeGestureRecognizer!
    @IBOutlet var swipeUpSportsPick: UISwipeGestureRecognizer!
    
    @IBAction func tapToUp(_ sender: UITapGestureRecognizer) {
        activityPicker.moveSportsViewDown(view: sportsView, button: startEndButtnHit, tapGesture: tapGesture, swipeDownGesture: swipeDownsportsPick, swipeUpGesture: swipeUpSportsPick, moveUp: true)
        theMap.isUserInteractionEnabled = false
        mapView.zoomMap(val: 0.15, superVisor: manager, view: theMap)
        tabStart.title = ""
        tabStart.isEnabled = false
    }
    @IBAction func sportsViewSwipeUp(_ sender: UISwipeGestureRecognizer) {
        activityPicker.moveSportsViewDown(view: sportsView, button: startEndButtnHit, tapGesture: tapGesture, swipeDownGesture: swipeDownsportsPick, swipeUpGesture: swipeUpSportsPick, moveUp: true)
        mapView.zoomMap(val: 0.15, superVisor: manager, view: theMap)
        theMap.isUserInteractionEnabled = false
        tabStart.title = ""
        tabStart.isEnabled = false
    }
    @IBAction func sportsViewSwipeDown(_ sender: UISwipeGestureRecognizer) {
        activityPicker.moveSportsViewDown(view: sportsView, button: startEndButtnHit, tapGesture: tapGesture, swipeDownGesture: swipeDownsportsPick, swipeUpGesture: swipeUpSportsPick, moveUp: false)
        mapView.zoomMap(val: 0.075, superVisor: manager, view: theMap)
        theMap.isUserInteractionEnabled = true
        tabStart.title = "START"
        tabStart.isEnabled = true
    }
    //Pick Activate Hit
    @IBAction func activateHit(_ key: UIButton){
        sportsButtonDefoults.set(key.tag, forKey: sportsButtonDefoultsKey)
        sportsButtonDefoults.set(key.tag, forKey: sportsButtonDefoultsKey_End)
        activityPicker.getSavedSportsButton(button: startEndButtnHit,navigationBar: navigationBar, off: true)
        activityPicker.moveSportsViewDown(view: sportsView, button: startEndButtnHit, tapGesture: tapGesture, swipeDownGesture: swipeDownsportsPick, swipeUpGesture: swipeUpSportsPick, moveUp: false)
        mapView.zoomMap(val: 0.075, superVisor: manager, view: theMap)
        theMap.isUserInteractionEnabled = true
        tabStart.title = "START"
        tabStart.isEnabled = true
    }

    @IBAction func startHit(_ sender: UIButton) {
         launchBool = !launchBool
        
    }
}










