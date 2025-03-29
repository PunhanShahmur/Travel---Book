//
//  ViewController.swift
//  TravelBook
//
//  Created by Punhan Shahmurov on 27.03.25.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameLocation: UITextField!
    @IBOutlet weak var contentLocation: UITextField!
    
    var locationManager = CLLocationManager()
    
    var choosenId: UUID?
    var choosenTitle: String?
    var choosenLatitude: Double?
    var choosenLongitude: Double?
    
    var annotationTitle: String = ""
    var annotationSubtitle: String = ""
    var annotationLatitude: Double = Double()
    var annotationLongitude: Double = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if choosenId != nil {
            
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Places")
            fetchRequest.predicate = NSPredicate(format: "id == %@", choosenId!.uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                
                let result = try context.fetch(fetchRequest)
                
                if result.count > 0 {
                    for data in result {
                        
                        if let title = data.value(forKey: "title") as? String {
                            annotationTitle = title
                            
                            if let subTitle = data.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subTitle
                                
                                if let latitude = data.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                    
                                    if let longitude = data.value(forKey: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        mapView.addAnnotation(annotation)
                                        nameLocation.text = annotationTitle
                                        contentLocation.text = annotationSubtitle
                                        
                                        locationManager.stopUpdatingLocation()
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                        
                                    }
                                }
                            }
                        }
                        
                    }
                }
                
                
            } catch {
                print("error")
            }
            
            
        }else{
            
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if choosenTitle == "" {
            
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            
        }
    }
    
    
    //Yeni bir annotaion yaratmaq
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .green
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
        
    }
    
    //Detail buttonunu custom yapmak
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
       
        if choosenTitle != "" {
            
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
                
                //closure
                
                if let placemark = placemarks {
                    
                    if placemark.count > 0 {
                       
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        
                        let item = MKMapItem(placemark: newPlacemark)
                        
                        item.name = self.choosenTitle
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        
                        item.openInMaps(launchOptions: launchOptions)
                        
                    }
                }
                
                
                
            }
        }
        
        
    }
    
    
    @IBAction func save(_ sender: UIButton) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newLocation.setValue(nameLocation.text, forKey: "title")
        newLocation.setValue(contentLocation.text, forKey: "subtitle")
        newLocation.setValue(choosenLatitude, forKey: "latitude")
        newLocation.setValue(choosenLongitude, forKey: "longitude")
        newLocation.setValue(UUID(), forKey: "id")
        
        
        do{
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true)
        
        
        
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            choosenLatitude = newCoordinate.latitude
            choosenLongitude = newCoordinate.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinate
            annotation.title = nameLocation.text
            annotation.subtitle = contentLocation.text
            mapView.addAnnotation(annotation)
        }
        
    }


}

