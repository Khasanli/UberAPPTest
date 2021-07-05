//
//  UserViewController.swift
//  UberAPP
//
//  Created by Samir Hasanli on 16.06.21.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation
import SocketIO
import KeychainAccess

var sourceLocation: CLLocationCoordinate2D?
var destinationLocation: CLLocationCoordinate2D?
var driverLocation: CLLocationCoordinate2D?

class ClientHomeViewController: UIViewController {
//MARK:-OBJECTS
    let manager = SocketManager(socketURL: URL(string: "http://localhost:3100")!, config: [.log(true), .connectParams(["token": "abc123"]), .compress, .reconnects(true)])
    var socket : SocketIOClient!
    var resetAck: SocketAckEmitter?
    
    var route: MKRoute?
    var showMapRoute = false
    let locationDistance : Double = 300
    var location = CLLocationCoordinate2D()
    
    var activeOrder = false
    
    lazy var locationManager : CLLocationManager = {
        let locationManager = CLLocationManager()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            handleAuthorizationStatus(locationManager: locationManager, status: CLLocationManager.authorizationStatus())
        } else {
            print("Location services are not enabled")
        }
        
        return locationManager
    }()
    lazy var mapView : MKMapView = {
        let mapview = MKMapView()
        mapview.delegate = self
        mapview.showsUserLocation = true
        mapview.translatesAutoresizingMaskIntoConstraints = false
        return mapview
    }()
    let directionLabel : UILabel = {
        let label = UILabel()
        label.text = "\(user?.name ?? ""), where do you want to go?"
        label.textAlignment = .center
        label.backgroundColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let pickLocationTextField : UITextField = {
        let field = UITextField()
        field.placeholder = "Pick Location"
        field.backgroundColor = .white
        field.layer.borderWidth = 2
        field.layer.borderColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let getDirectionButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(getDirectionButtonTapped), for: .touchUpInside)
        button.setTitle("Get", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        return button
    }()
    
    var costLabel : UILabel = {
        var label = UILabel()
        label.text = "$0.0"
        label.textAlignment = .center
        label.backgroundColor = .white
        label.layer.borderWidth = 2
        label.layer.borderColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let orderButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(orderButtonTapped), for: .touchUpInside)
        button.setTitle("Order", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        return button
    }()
//MARK:-LIFECYCLES
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .none
        view.addSubview(mapView)
        view.addSubview(directionLabel)
        view.addSubview(pickLocationTextField)
        view.addSubview(getDirectionButton)
        view.addSubview(costLabel)
        view.addSubview(orderButton)
        locationManager.startUpdatingLocation()
        socket = manager.defaultSocket

        socket.on("connection") { data, ack in
            print("connecteddd")
        }
        
        socket.connect()

        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        longPressRecogniser.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecogniser)
        
        setSubviews()
    }
        
//MARK:-SET SUBVIEWS
    private func setSubviews(){
        directionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        directionLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        directionLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        directionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        directionLabel.font = UIFont(name: "AlNile-Bold", size: view.frame.size.width/25)
        
        pickLocationTextField.topAnchor.constraint(equalTo: directionLabel.bottomAnchor).isActive = true
        pickLocationTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2/3).isActive = true
        pickLocationTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        pickLocationTextField.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        pickLocationTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: pickLocationTextField.frame.height))

        getDirectionButton.topAnchor.constraint(equalTo: directionLabel.bottomAnchor).isActive = true
        getDirectionButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        getDirectionButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        getDirectionButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.size.height/16).isActive = true
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        costLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.size.height/16).isActive = true
        costLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2/3).isActive = true
        costLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        costLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        costLabel.font = UIFont(name: "AlNile-Bold", size: view.frame.size.width/12)
        
        orderButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.size.height/16).isActive = true
        orderButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        orderButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        orderButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        orderButton.titleLabel?.font = UIFont(name: "AlNile-Bold", size: view.frame.size.width/25)
        
        
    }
//MARK:-FUNCTIONS
    @objc private func orderButtonTapped(){
        activeOrder = true
        let newOrder = Order(OrderID: user?._id ?? "", Username: user?.name ?? "", cost: costLabel.text ?? "", userLocation: Location(latitude: sourceLocation!.latitude, longitude: sourceLocation!.longitude), destinationLocation: Location(latitude: destinationLocation!.latitude, longitude: destinationLocation!.longitude))
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(newOrder)
        let data = String(data: jsonData, encoding: String.Encoding.utf8)
        print(data)
        socket.emit("onOrder",  data!)
    }
    @objc private func getDirectionButtonTapped(){
        guard pickLocationTextField.text?.count ?? 0 > 1 else {return}
        mapView.removeOverlays(mapView.overlays)
        if self.mapView.annotations.count > 0 {
            let allAnnotations = self.mapView.annotations
            mapView.removeAnnotations(allAnnotations)
        }
        showMapRoute = true
        pickLocationTextField.endEditing(true)
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(pickLocationTextField.text!) { placemarks, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            guard let placemarks = placemarks, let placemark = placemarks.first, let location = placemark.location else {return}
            let destinationCoordinate = location.coordinate
            self.mapRoute(destinationCoordinate: destinationCoordinate)
            let annotation = MKPointAnnotation()
            annotation.coordinate = destinationCoordinate
            self.mapView.addAnnotation(annotation)
        }
    }
    fileprivate func centerViewToUserLocation(center: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: center, latitudinalMeters: locationDistance, longitudinalMeters: locationDistance)
        mapView.setRegion(region, animated: true)
    }
    fileprivate func handleAuthorizationStatus(locationManager: CLLocationManager, status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            if let center = locationManager.location?.coordinate {
                centerViewToUserLocation(center: center)
            }
            break
        @unknown default:
            break
        }
    }
    
    fileprivate func mapRoute(destinationCoordinate: CLLocationCoordinate2D) {
        guard let sourceCoordinate = locationManager.location?.coordinate else {return}
        sourceLocation = sourceCoordinate
        destinationLocation = destinationCoordinate
        
        let location1 = CLLocation(latitude: sourceCoordinate.latitude, longitude: sourceCoordinate.longitude)
        let location2 = CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
        let distanceCost = Int(location1.distance(from: location2))
        self.costLabel.text = "$\(Float(distanceCost)*1/100)"
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let routeRequest = MKDirections.Request()
        routeRequest.source = sourceItem
        routeRequest.destination = destinationItem
        routeRequest.transportType = .automobile

        
        let directions = MKDirections(request: routeRequest)
        directions.calculate { response, err in
            guard let response = response else {
                if let err = err {
                    print(err.localizedDescription)
                }
                return
            }
            if response.routes.isEmpty != true {
                self.mapView.removeOverlay(response.routes[0].polyline)
                let route = response.routes[0]
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    @objc func handleTap(_ gestureReconizer: UILongPressGestureRecognizer){
        guard activeOrder != true else {return}
        mapView.removeOverlays(mapView.overlays)
        if self.mapView.annotations.count > 0 {
            let allAnnotations = self.mapView.annotations
            mapView.removeAnnotations(allAnnotations)
        }
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let loc: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geo: CLGeocoder = CLGeocoder()
        geo.reverseGeocodeLocation(loc, completionHandler:
                    {(placemarks, error) in
                        if (error != nil)
                        {
                            print("reverse geodcode fail: \(error!.localizedDescription)")
                        } else {
                        let pm = placemarks! as [CLPlacemark]

                        if pm.count > 0 {
                            let pm = placemarks![0]
                            var addressString : String = ""
                            if pm.subLocality != nil {
                                addressString = addressString + pm.subLocality! + ", "
                            }
                            if pm.administrativeArea != nil {
                                addressString = addressString + pm.administrativeArea! + ", "
                            }
                            if pm.subAdministrativeArea != nil {
                                addressString = addressString + pm.subAdministrativeArea! + ", "
                            }
                            annotation.title = addressString
                            self.pickLocationTextField.placeholder = "\(addressString)"
                      }
                    }
                })
        mapRoute(destinationCoordinate: coordinate)
    }
}

extension ClientHomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !showMapRoute {
            if let location = locations.last {
                let center = location.coordinate
                centerViewToUserLocation(center: center)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthorizationStatus(locationManager: locationManager, status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("entered region")
    }
}
extension ClientHomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .purple
        renderer.lineWidth = 2
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "customPin")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customPin")
            annotationView?.canShowCallout = true
        }else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "location_small_pin")
        annotationView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return annotationView
    }
}
