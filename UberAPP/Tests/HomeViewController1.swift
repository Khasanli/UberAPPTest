//
//  ViewController.swift
//  UberAPP
//
//  Created by Samir Hasanli on 14.06.21.
//

import UIKit
import MapKit
import CoreLocation

class HomeViewController1: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
//MARK:-OBJECTS
    var sourceAnnotation = MKPointAnnotation()
    var destinationAnnotation = MKPointAnnotation()
    var locationManager = CLLocationManager()
    let mapView : MKMapView = {
        let mapview = MKMapView()
        mapview.translatesAutoresizingMaskIntoConstraints = false
        return mapview
    }()
    
    let pickLocationTextField : UITextField = {
        let field = UITextField()
        field.placeholder = "Pick Location"
        field.backgroundColor = .white
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let getLocationButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(getLocationButtonTapped), for: .touchUpInside)
        button.setTitle("Get", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        button.layer.borderWidth = 2
        button.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return button
    }()

//MARK:-LIFECYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .none
        view.addSubview(mapView)
        view.addSubview(pickLocationTextField)
        view.addSubview(getLocationButton)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self

        mapView.addAnnotation(sourceAnnotation)
        mapView.addAnnotation(destinationAnnotation)
        setSubviews()
    }
    
 
//MARK:-SET SUBVIEWS
    private func setSubviews(){
        pickLocationTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pickLocationTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2/3).isActive = true
        pickLocationTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        pickLocationTextField.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        pickLocationTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: pickLocationTextField.frame.height))
        pickLocationTextField.font = UIFont(name: "Arial", size: view.frame.height/40)

        getLocationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        getLocationButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        getLocationButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        getLocationButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        getLocationButton.titleLabel?.font = UIFont(name: "Arial-BoldMT", size: view.frame.height/36)
        
        mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
//MARK:-FUNCTIONS
    @objc private func getLocationButtonTapped(){
        self.mapThis(destinationCard: CLLocationCoordinate2D(latitude: 51.537955, longitude: -0.168898))

    }
    private func getLocation(){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(pickLocationTextField.text!) { placemarks, error in
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                print("error happened on geocoder")
                return
            }
            print(location)
            //self.mapThis(destinationCard: location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    func mapThis(destinationCard : CLLocationCoordinate2D){
        
        
        let sourceCordinate = (locationManager.location?.coordinate)!
        self.sourceAnnotation.coordinate = sourceCordinate
        self.destinationAnnotation.coordinate = destinationCard
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCard)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destinationItem
        destinationRequest.transportType = .automobile
        destinationRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: destinationRequest)
        directions.calculate { response, error in
            guard let response = response else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        render.lineWidth = 2
        return render
    }
}



