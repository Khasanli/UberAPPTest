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

class DriverHomeViewController: UIViewController {
//MARK:-OBJECTS
    let manager = SocketManager(socketURL: URL(string: "http://localhost:3100")!, config: [.log(true), .connectParams(["token": "abc123"]), .compress, .reconnects(true)])
    var socket : SocketIOClient!
    var resetAck: SocketAckEmitter?
    var orderTaken = false
    
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
    let rejectOrderButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(rejectOrderButtonTapped), for: .touchUpInside)
        button.setTitle("Reject Order", for: .normal)
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
        view.addSubview(startStopNavigation)
        view.addSubview(costLabel)
        view.addSubview(orderView)
        view.addSubview(takeOrderButton)
        view.addSubview(rejectOrderButton)
        self.orderView.isHidden = true
        locationManager.startUpdatingLocation()
    
        socket = manager.defaultSocket
        socket.on("connection") { data, ack in
            print("connecteddd")
        }
        socket.on("recieved-order") { data, ack in
            self.socket.off("recieved-order")
            self.orderView.isHidden = false
            self.orderSocketControl(dataArray: data as NSArray)
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

        startStopNavigation.topAnchor.constraint(equalTo: directionLabel.bottomAnchor).isActive = true
        startStopNavigation.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        startStopNavigation.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        startStopNavigation.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        startStopNavigation.titleLabel?.font = UIFont(name: "AlNile-Bold", size: view.frame.size.width/25)
            
        mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.size.height/16).isActive = true
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        costLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.size.height/16).isActive = true
        costLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        costLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        costLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        costLabel.font = UIFont(name: "AlNile-Bold", size: view.frame.size.width/12)
        
        takeOrderButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.size.height/16).isActive = true
        takeOrderButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        takeOrderButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        takeOrderButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        takeOrderButton.titleLabel?.font = UIFont(name: "AlNile-Bold", size: view.frame.size.width/25)
        
        rejectOrderButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.frame.size.height/16).isActive = true
        rejectOrderButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        rejectOrderButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        rejectOrderButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rejectOrderButton.titleLabel?.font = UIFont(name: "AlNile-Bold", size: view.frame.size.width/25)

        startStopNavigation.setTitle(navigationStarted ? "Stop Navigation" : "Start Navigation", for: .normal)
        
        orderView.bottomAnchor.constraint(equalTo: costLabel.topAnchor, constant: -view.frame.size.height/32).isActive = true
        orderView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -view.frame.size.width/16).isActive = true
        orderView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 12/16).isActive = true
        orderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
//MARK:-FUNCTIONS
    @objc private func takeOrderButtonTapped(){
        if currentOrder != nil {
            orderView.isHidden = true
            mapRoute(destinationCoordinate: CLLocationCoordinate2D(latitude: currentOrder?.userLocation.latitude ?? 0.0 , longitude: currentOrder?.userLocation.longitude ?? 0.0))
        }
    }
    
    @objc private func rejectOrderButtonTapped(){
        if currentOrder != nil{
            currentOrder = nil
            self.orderView.isHidden = true
            socket.on("recieved-order") { data, ack in
                self.socket.off("recieved-order")
                let dataArray = data as NSArray
                self.orderSocketControl(dataArray: dataArray)
            }
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
        let allOverlays = self.mapView.overlays
        self.mapView.removeOverlays(allOverlays)
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
                self.userToDestination()
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
    private func orderSocketControl(dataArray: NSArray){
        let allAnnotations = self.orderView.mapView.annotations
        let allOverlays = self.orderView.mapView.overlays
        self.orderView.mapView.removeAnnotations(allAnnotations)
        self.orderView.mapView.removeOverlays(allOverlays)
        
        let dataString = dataArray[0] as! String
        let json = dataString.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        do {
            let order: Order = try! JSONDecoder().decode(Order.self, from: json)
            currentOrder = order
            
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
    
    private func userToDestination(){
        guard currentOrder != nil else {return}
            DispatchQueue.main.async {
                self.costLabel.text = currentOrder?.cost ?? "0"
                
                let SourceAnnotation = MKPointAnnotation()
                let DestinationAnnotation = MKPointAnnotation()
                SourceAnnotation.title = "Client Location"
                DestinationAnnotation.title = "Destination Location"
                SourceAnnotation.coordinate =  CLLocationCoordinate2D(latitude: currentOrder?.userLocation.latitude ?? 0.0, longitude: currentOrder?.userLocation.longitude ?? 0.0)
                DestinationAnnotation.coordinate = CLLocationCoordinate2D(latitude: currentOrder?.destinationLocation.latitude ?? 0.0, longitude: currentOrder?.destinationLocation.longitude ?? 0.0)
                self.mapView.addAnnotation(SourceAnnotation)
                self.mapView.addAnnotation(DestinationAnnotation)
            }
    }
    
//MARK:-Animation
    private func animateOrderView(){
        let animation = CABasicAnimation()
        animation.keyPath = "tranform.scale"
        animation.fromValue = 1
        animation.toValue = 2
        animation.duration = 0.4
    }
}
extension DriverHomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let driverLocation = Location(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
        let userLocation = Location(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
        
        if driverLocation.latitude == userLocation.latitude  {
            mapRoute(destinationCoordinate: CLLocationCoordinate2D(latitude: currentOrder?.destinationLocation.latitude ?? 0.0 , longitude: currentOrder?.destinationLocation.longitude ?? 0.0))
        }
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(driverLocation)
        let data = String(data: jsonData, encoding: String.Encoding.utf8)

        if orderTaken == true {
            socket.emit("\(currentOrder?.OrderID)", data!)
        }
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
extension DriverHomeViewController: MKMapViewDelegate {
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

