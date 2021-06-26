//
//  DriverViewController.swift
//  UberAPP
//
//  Created by Samir Hasanli on 16.06.21.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation
import SocketIO

class DriverViewController: UIViewController {
//MARK:-OBJECTS
    let manager = SocketManager(socketURL: URL(string: "http://localhost:3100")!, config: [.log(true), .connectParams(["token": "abc123"]), .compress, .reconnects(true)])
    var socket : SocketIOClient!
    var resetAck: SocketAckEmitter?
    
    
    var steps: [MKRoute.Step] = []
    var stepCounter = 0
    var route: MKRoute?
    var showMapRoute = false
    var navigationStarted = false
    let locationDistance : Double = 300
    var speechsynthesizer = AVSpeechSynthesizer()
    var location = CLLocationCoordinate2D()
    
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
    var orderView : OrderUIView = {
        var uiview = OrderUIView()
        uiview.backgroundColor = .white
        uiview.layer.borderWidth = 4
        uiview.layer.borderColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        uiview.translatesAutoresizingMaskIntoConstraints = false
        return uiview
    }()
    let directionLabel : UILabel = {
        let label = UILabel()
        label.text = "Where do you want to go?"
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
    
    let takeOrderButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(takeOrderButtonTapped), for: .touchUpInside)
        button.setTitle("Take Order", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        return button
    }()
    
    let startStopNavigation : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startStopNavigationTapped), for: .touchUpInside)
        button.setTitleColor(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), for: .normal)
        button.backgroundColor = .white
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
        view.addSubview(startStopNavigation)
        view.addSubview(costLabel)
        view.addSubview(orderView)
        self.orderView.isHidden = true
        view.addSubview(takeOrderButton)
        locationManager.startUpdatingLocation()
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        longPressRecogniser.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecogniser)
        socket = manager.defaultSocket
        socket.on("connection") { data, ack in
            print("connecteddd")
        }
        socket.on("recieved-order") { data, ack in
            self.orderView.isHidden = false

            let allAnnotations = self.orderView.mapView.annotations
            let allOverlays = self.orderView.mapView.overlays

            self.orderView.mapView.removeAnnotations(allAnnotations)
            self.orderView.mapView.removeOverlays(allOverlays)
            
            let dataArray = data as NSArray
            let dataString = dataArray[0] as! String
            let json = dataString.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            do {
                let order: Order = try! JSONDecoder().decode(Order.self, from: json)
                DispatchQueue.main.async {
                    let sourcePlacemark = MKPlacemark(coordinate:  CLLocationCoordinate2D(latitude: order.userLocation.latitude, longitude: order.userLocation.longitude))
                    let destinationPlacemark = MKPlacemark(coordinate:  CLLocationCoordinate2D(latitude: order.destinationLocation.latitude, longitude: order.destinationLocation.longitude))
                    
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
                            let route = response.routes[0]
                            self.orderView.mapView.addOverlay(route.polyline)
                            self.orderView.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        }
                    }
                    self.costLabel.text = order.cost
                    self.orderView.orderID.text = order.OrderID
                    self.orderView.clientName.text = order.Username
                    
                    let SourceAnnotation = MKPointAnnotation()
                    let DestinationAnnotation = MKPointAnnotation()
                    let DriverAnnotation = MKPointAnnotation()
                    SourceAnnotation.title = "Client Location"
                    DestinationAnnotation.title = "Destination Location"
                    DriverAnnotation.title = "Driver  45673399225678965678987656789"
                    SourceAnnotation.coordinate =  CLLocationCoordinate2D(latitude: order.userLocation.latitude, longitude: order.userLocation.longitude)
                    DestinationAnnotation.coordinate = CLLocationCoordinate2D(latitude: order.destinationLocation.latitude, longitude: order.destinationLocation.longitude)
                    DriverAnnotation.coordinate = CLLocationCoordinate2D(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!)
                    
                    self.orderView.mapView.addAnnotation(SourceAnnotation)
                    self.orderView.mapView.addAnnotation(DestinationAnnotation)
                    
                }

            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        socket.connect()
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

        startStopNavigation.topAnchor.constraint(equalTo: getDirectionButton.bottomAnchor).isActive = true
        startStopNavigation.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        startStopNavigation.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        startStopNavigation.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        startStopNavigation.titleLabel?.font = UIFont(name: "AlNile-Bold", size: view.frame.size.width/25)
            
        mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.size.height/16).isActive = true
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        costLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.size.height/16).isActive = true
        costLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2/3).isActive = true
        costLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        costLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        costLabel.font = UIFont(name: "AlNile-Bold", size: view.frame.size.width/12)
        
        takeOrderButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.size.height/16).isActive = true
        takeOrderButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        takeOrderButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        takeOrderButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        takeOrderButton.titleLabel?.font = UIFont(name: "AlNile-Bold", size: view.frame.size.width/25)

        startStopNavigation.setTitle(navigationStarted ? "Stop Navigation" : "Start Navigation", for: .normal)
        
        orderView.bottomAnchor.constraint(equalTo: costLabel.topAnchor, constant: -view.frame.size.height/32).isActive = true
        orderView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -view.frame.size.width/16).isActive = true
        orderView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 12/16).isActive = true
        orderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        orderView.orderID.text = "1234567890"
        orderView.clientName.text = "khayala"
    }
//MARK:-FUNCTIONS
    @objc private func takeOrderButtonTapped(){
        
    }
    @objc private func getDirectionButtonTapped(){
        guard pickLocationTextField.text?.count ?? 0 > 1 else {return}
        mapView.removeOverlays(mapView.overlays)
        if self.mapView.annotations.count > 0 {
            let allAnnotations = self.mapView.annotations
            mapView.removeAnnotations(allAnnotations)
            speechsynthesizer.stopSpeaking(at: .immediate)
            navigationStarted = false
            startStopNavigation.setTitle(navigationStarted ? "Stop Navigation" : "Start Navigation", for: .normal)
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
    
    @objc private func startStopNavigationTapped(){
        if !navigationStarted {
            showMapRoute = true
            if let location = locationManager.location {
                let center  = location.coordinate
                centerViewToUserLocation(center: center)
                let speechUtterance = AVSpeechUtterance(string: directionLabel.text ?? "")
                speechsynthesizer.speak(speechUtterance)
            }
        } else {
            if let route = route {
                navigationStarted = false
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                self.steps.removeAll()
                speechsynthesizer.stopSpeaking(at: .immediate)
                self.stepCounter = 0
            }
        }
        navigationStarted.toggle()
        startStopNavigation.setTitle(navigationStarted ? "Stop Navigation" : "Start Navigation", for: .normal)
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
                self.steps.removeAll()
                self.stepCounter = 0
                self.getRouteSteps(route: route)
            }
        }
    }
    fileprivate func getRouteSteps(route: MKRoute) {
        for monitoredRegion in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: monitoredRegion)
        }
        let steps = route.steps
        self.steps = steps
        
        for i in 0..<steps.count {
            let step = steps[i]
            let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
            locationManager.startMonitoring(for: region)
        }
        stepCounter += 1
        let initialMassage = "In \(Int(steps[stepCounter].distance)) meters \(steps[stepCounter].instructions), then in \(Int(steps[stepCounter + 1].distance)) meters, \(steps[stepCounter + 1].instructions)"
        directionLabel.text = initialMassage
    }
    
    @objc func handleTap(_ gestureReconizer: UILongPressGestureRecognizer){
        mapView.removeOverlays(mapView.overlays)
        if self.mapView.annotations.count > 0 {
            let allAnnotations = self.mapView.annotations
            mapView.removeAnnotations(allAnnotations)
            navigationStarted = false
            speechsynthesizer.stopSpeaking(at: .immediate)
            startStopNavigation.setTitle(navigationStarted ? "Stop Navigation" : "Start Navigation", for: .normal)
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
                        }
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
                })
        mapRoute(destinationCoordinate: coordinate)
    }
}

extension DriverViewController: CLLocationManagerDelegate {
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
        stepCounter += 1
        
        if stepCounter < steps.count {
            let message = "In \(Int(steps[stepCounter].distance)) meters \(steps[stepCounter].instructions)"
            directionLabel.text = message
        } else {
            let message = "You have arrived at your destination"
            directionLabel.text = message
            stepCounter = 0
            navigationStarted = false
            for monitoredRegion in locationManager.monitoredRegions {
                locationManager.stopMonitoring(for: monitoredRegion)
            }
        }
    }
}
extension DriverViewController: MKMapViewDelegate {
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

