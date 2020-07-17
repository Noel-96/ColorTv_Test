//
//  PinMapViewController.swift
//  LocationWeather
//
//  Created by Noel Obaseki on 17/07/2020.
//

import Foundation
import UIKit
import MapKit
import CoreData
import CoreLocation

class PinMapViewController: UIViewController , MKMapViewDelegate , UIGestureRecognizerDelegate, CLLocationManagerDelegate{
    
    let locationManager = CLLocationManager()
    
    var dataController : ControlData!
    @IBOutlet weak var mapView: MKMapView!
    var pins: [Pin] = []
    override func viewWillAppear(_ animated: Bool) {
        addpin()
        view.reloadInputViews()
        
        self.navigationController?.navigationBar.tintColor = UIColorFromRGB(colorCode: "4A9AA0", alpha: 1.0)
       
    }
     override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestWhenInUseAuthorization()

          if CLLocationManager.locationServicesEnabled() {
              locationManager.delegate = self
              locationManager.desiredAccuracy = kCLLocationAccuracyBest
              locationManager.startUpdatingLocation()
               locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.distanceFilter = 20.0
            
            
          }

          mapView.delegate = self
          mapView.mapType = .standard
          mapView.isZoomEnabled = true
          mapView.isScrollEnabled = true

          if let coor = mapView.userLocation.location?.coordinate{
              mapView.setCenter(coor, animated: true)
          }
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(tappedToAddPin))
        gesture.delegate = self
        mapView.addGestureRecognizer(gesture)
        
        let fetshRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetshRequest){
            pins = result
            mapView.removeAnnotations(mapView.annotations)
            addpin()
        }
        
    }
    
    
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate

        mapView.mapType = MKMapType.standard

        let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)

       let annotation = MKPointAnnotation()
        annotation.coordinate = locValue
        mapView.addAnnotation(annotation)

        //centerMap(locValue)
    }
    
   
    
    @objc func tappedToAddPin(gestureReconizer : UIGestureRecognizer){
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom : mapView)
            
            let pin = Pin(context: dataController.viewContext)
            pin.lat = coordinate.latitude.magnitude
            pin.lon = coordinate.longitude.magnitude
            do{
                try dataController.viewContext.save()
                
            }catch{
                print(error.localizedDescription)
            }
            pins.append(pin)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
        
    }
    
    
    func addpin() {
        mapView.removeAnnotations(mapView.annotations)
        var annotations = [MKPointAnnotation]()
        for pin in pins {
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.lat), longitude:  CLLocationDegrees(pin.lon))
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    func UIColorFromRGB(colorCode: String, alpha: Float = 1.0) -> UIColor{
        let scanner = Scanner(string:colorCode)
        var color:UInt32 = 0;
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
        let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
        let b = CGFloat(Float(Int(color) & mask)/255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }
}
