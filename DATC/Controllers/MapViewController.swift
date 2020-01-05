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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let locationManager = CLLocationManager()
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil
    let reportModel = ReportModel()
    var animalTextField: UITextField?
    var latitudeTextField: UITextField?
    var longitudeTextField: UITextField?
    var dateTextField: UITextField?
    var coordinateTap: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide navigationItem button
        self.navigationItem.setHidesBackButton(true, animated: false)
            
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
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "locationTable") as! LocationSearchTable
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        
        resultSearchController!.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    //MARK: - Directions
    @objc func getDirections() {
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
   //MARK: - add report by tap on map
    @IBAction func longPressGestureRecognize(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let locationInView = sender.location(in: mapView)
            let tappedCoordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            coordinateTap = tappedCoordinate
          
            let alertController = UIAlertController(title: "Description", message: nil, preferredStyle: .alert)
            alertController.addTextField(configurationHandler: animalTextField)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: self.okHandler)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true)
        }
    }
   
    func animalTextField(textField: UITextField!) {
        animalTextField = textField
        animalTextField?.placeholder = "Bear/Fox/Wolf/etc"
    }
    
    func okHandler(alert: UIAlertAction!) {
        let annotation = MKPointAnnotation()
        annotation.title = animalTextField?.text
        annotation.coordinate = coordinateTap!
        print("-----------TextField = \(animalTextField?.text)")
        mapView.addAnnotation(annotation)
        
        var httpInsert = HTTPReport()
        httpInsert.insertReport(report: Report(descriptionReport: animalTextField!.text!, latitude: Float(coordinateTap!.latitude), longitude: Float(coordinateTap!.longitude)))
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate, ReportModelProtocol  {
    
    //MARK: - The function wich added the animals reported on map
    func createAnnotatin(reports: [Report]) {
        
        for report in reports {
            let annotation = MKPointAnnotation()
            annotation.title = report.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(report.latitude) as CLLocationDegrees, longitude:
                Double(report.longitude) as CLLocationDegrees)
            print("________________________")
            print("Double annotation: \(Double(report.latitude)) and \(Double(report.longitude))")
            print("________________________")
            mapView.addAnnotation(annotation)
        }
    }

    func itemsDownloaded(items: [Report]) {
        for report in items {
            print(report.name)
        }
        createAnnotatin(reports: items)
    }
    
    //MARK: - Create the user pin with user locatin
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0] as CLLocation
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D (latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        self.mapView.setRegion(region, animated: true)
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        print("Long: \(region.span.latitudeDelta) and Lat: \(region.span.longitudeDelta)")
        
        //MARK: - Calulating the coordinates user of the region
        // and prepare for selection of animals from database
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

