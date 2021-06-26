//
//  MapViewController.swift
//  UberAPP
//
//  Created by Samir Hasanli on 15.06.21.
//

import UIKit
import MapKit

class MapViewController: UIViewController , MKMapViewDelegate {
    var mapView : MKMapView = {
        var mapview = MKMapView()
        mapview.translatesAutoresizingMaskIntoConstraints = false
        return mapview
    }()
    
    var selectedAnnotation: MKPointAnnotation?
    var keyLat:String = "49.2768"
    var keyLon:String = "-123.1120"
    var location = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        view.backgroundColor = .none
        setSubviews()
        mapView.delegate = self
        
        let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(keyLat.toFloat()),longitude: CLLocationDegrees(keyLon.toFloat()))
        self.location = location
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        longPressRecogniser.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecogniser)
        
        mapView.mapType = MKMapType.standard
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "BC Place Stadium"
        annotation.subtitle = "Vancouver Canada"
        mapView.addAnnotation(annotation)
    }
    private func setSubviews(){
        mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    @objc func handleTap(_ gestureReconizer: UILongPressGestureRecognizer){
        mapView.removeOverlays(mapView.overlays)
        if self.mapView.annotations.count > 0 {
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
        }
        
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let loc: CLLocation = CLLocation(latitude: self.location.latitude, longitude: self.location.longitude)
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
                            
                            if pm != nil {
                                addressString = addressString + pm.subLocality! + ", "
                            }
                            if pm.thoroughfare != nil {
                                addressString = addressString + pm.thoroughfare! + ", "
                            }
                            if pm.administrativeArea != nil {
                                addressString = addressString + pm.administrativeArea! + ", "
                            }
                            
                            annotation.title = addressString
                      }
                })
        
        
        self.mapThis(sourceLocation: self.location, destinationCard: coordinate)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let latValStr : String = String(format: "%.02f",Float((view.annotation?.coordinate.latitude)!))
        let lonvalStr : String = String(format: "%.02f",Float((view.annotation?.coordinate.longitude)!))
    }
    
    func mapThis(sourceLocation: CLLocationCoordinate2D, destinationCard : CLLocationCoordinate2D){
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation)
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
            if response.routes.isEmpty != true {
                self.mapView.removeOverlay(response.routes[0].polyline)
                let route = response.routes[0]
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        render.lineWidth = 2
        return render
    }
}
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    func toFloat() -> Float {
        return (self as NSString).floatValue
    }
}
