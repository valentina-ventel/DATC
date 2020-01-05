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


protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}


class MapViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet fileprivate weak var mapView: MKMapView!
    @IBOutlet fileprivate weak var searchBar: UISearchBar!
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate var resultSearchController: UISearchController? = nil
    fileprivate var selectedPin: MKPlacemark? = nil
    fileprivate let reportModel = ReportModel()
    fileprivate var animalTextField: UITextField?
    fileprivate var latitudeTextField: UITextField?
    fileprivate var longitudeTextField: UITextField?
    fileprivate var dateTextField: UITextField?
    fileprivate var coordinateTap: CLLocationCoordinate2D?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: false)
        definesPresentationContext = true
            
        configureLocationManager()
        configureSearch()
    }
    
    // MARK: Private
    fileprivate func configureLocationManager() {
        if CLLocationManager.locationServicesEnabled() == true {
            
            if CLLocationManager.authorizationStatus() == .restricted ||
                CLLocationManager.authorizationStatus() == .denied ||
                CLLocationManager.authorizationStatus() == .notDetermined
            {
                locationManager.requestWhenInUseAuthorization()
            }
            
            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        } else {
            print("Please turn ON location services or GPS")
        }
    }
    
    fileprivate func configureSearch() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let locationSearchTVC = storyboard.instantiateViewController(identifier: "locationTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTVC)
        
        resultSearchController!.searchResultsUpdater = locationSearchTVC
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        
        locationSearchTVC.mapView = mapView
        locationSearchTVC.handleMapSearchDelegate = self
    }
    
    //MARK: - Directions
    @objc func getDirections() {
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
   //MARK: - Gestures
    @IBAction fileprivate func longPressGestureRecognize(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let locationInView = sender.location(in: mapView)
            let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            coordinateTap = tappedCoordinate
          
            let alertController = UIAlertController(title: "Name", message: nil, preferredStyle: .alert)
            alertController.addTextField(configurationHandler: {textField in
                textField.placeholder = "Bear/Fox/Wolf etc"
            })
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: self.okHandler)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true)
        }
    }
    
    fileprivate func okHandler(alert: UIAlertAction!) {
        guard let animalTextField = animalTextField,
            let animalName = animalTextField.text else {
                print("Invalid animal name")
                return
        }
        
        guard let coordinate = coordinateTap else {
            print("Invalid tap coordinate")
            return
        }
            
        let annotation = MKPointAnnotation()
        annotation.title = animalName
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let animalReport = AnimalReport(name: animalName,
                                        latitude: coordinate.latitude,
                                        longitude: coordinate.longitude)
        API.addAnimalReport(report: animalReport)
    }
}

// MARK: - ReportModelProtocol

extension MapViewController: ReportModelProtocol  {
    func itemsDownloaded(items: [AnimalReport]) {
        for report in items {
            print(report.name)
        }
        createAnnotation(reports: items)
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    // Function which adds the animal reported on map
    func createAnnotation(reports: [AnimalReport]) {
        
        for report in reports {
            let annotation = MKPointAnnotation()
            annotation.title = report.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: report.latitude,
                                                           longitude: report.longitude)
            print("________________________")
            print("Double annotation: \(Double(report.latitude)) and \(Double(report.longitude))")
            print("________________________")
            mapView.addAnnotation(annotation)
        }
    }
    
    // Create the user pin with user location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0] as CLLocation
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D (latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        self.mapView.setRegion(region, animated: true)
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        print("Long: \(region.span.latitudeDelta) and Lat: \(region.span.longitudeDelta)")
        
        // user region coordinates
        let regionReports = Region(nw: region.nw(),
                                   se: region.se())
        reportModel.delegate = self
        reportModel.downloadItems(from: regionReports)
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
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.black
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: .zero,
                                            size: smallSquare))
        let image = UIImage(named: "car")
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self,
                         action:Selector(("getDirections")),
                         for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button

        return pinView
    }
}

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        
        selectedPin = placemark
        
        mapView.removeAnnotations(mapView.annotations)
        let annotation  = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.locality
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            print("City: \(city) and State: \(state)")
            annotation.subtitle = "\(city), \(state)"
        }
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

