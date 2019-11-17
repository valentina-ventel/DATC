//
//  ViewController.swift
//  DATC
//
//  Created by Valentina Vențel on 12/11/2019.
//  Copyright © 2019 Valentina Vențel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let locationManager = CLLocationManager()
    
    @IBAction func searchButton(_ sender: Any) {
        let searcController = UISearchController(searchResultsController: nil)
        searcController.searchBar.delegate = self
        present(searcController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        if CLLocationManager.locationServicesEnabled() == true {
            
            if CLLocationManager.authorizationStatus() == .restricted ||
               CLLocationManager.authorizationStatus() == .denied ||
               CLLocationManager.authorizationStatus() == .notDetermined {
                
                locationManager.requestWhenInUseAuthorization()
                
            }
            
            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        } else {
            print("Please turn location services or GPS")
        }
    }
   
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D (latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        self.mapView.setRegion(region, animated: true)
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        // print("Long: \(locations[0].coordinate.latitude) and Lat: \(locations[0].coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print( "Unable to access location")
    }
}

// MARK: - MapViewDelegate
extension UIViewController: MKMapViewDelegate {
    
    public func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("Map did load")
        
        
    }
}
