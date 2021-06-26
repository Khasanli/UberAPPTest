//
//  OrderUIView.swift
//  UberAPP
//
//  Created by Samir Hasanli on 24.06.21.
//

import UIKit
import MapKit

class OrderUIView: UIView {
    var sourceCordinate : CLLocationCoordinate2D?
    var destinationCordinate : CLLocationCoordinate2D?
    var driverCordinate : CLLocationCoordinate2D?

    
    var orderID: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let clientName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var mapView : MKMapView = {
        let mapview = MKMapView()
        mapview.translatesAutoresizingMaskIntoConstraints = false
        return mapview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        self.addSubview(orderID)
        self.addSubview(clientName)
        self.addSubview(mapView)
        self.mapView.delegate = self

        let SourceAnnotation = MKPointAnnotation()
        let DestinationAnnotation = MKPointAnnotation()
        let DriverAnnotation = MKPointAnnotation()

        SourceAnnotation.coordinate = sourceCordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        DestinationAnnotation.coordinate = destinationCordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        DriverAnnotation.coordinate = driverCordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)

        
        mapView.addAnnotation(SourceAnnotation)
        mapView.addAnnotation(DestinationAnnotation)
        mapView.addAnnotation(DriverAnnotation)
        
        setSubviews()
    }
    
    func setSubviews(){
        self.translatesAutoresizingMaskIntoConstraints = false
        orderID.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        orderID.centerXAnchor.constraint(equalTo: self.centerXAnchor ).isActive = true
        orderID.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 3/4).isActive = true
        orderID.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/8).isActive = true
        
        clientName.topAnchor.constraint(equalTo: orderID.bottomAnchor, constant: 10).isActive = true
        clientName.centerXAnchor.constraint(equalTo: self.centerXAnchor ).isActive = true
        clientName.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 3/4).isActive = true
        clientName.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1/8).isActive = true
        
        mapView.topAnchor.constraint(equalTo: clientName.bottomAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        mapView.centerXAnchor.constraint(equalTo: self.centerXAnchor ).isActive = true
        mapView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 6/8).isActive = true
    }
}

extension OrderUIView: MKMapViewDelegate {
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
    
        var sourceAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "user")
        if sourceAnnotationView == nil {
            sourceAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "user")
            sourceAnnotationView?.canShowCallout = true
        }else {
            sourceAnnotationView?.annotation = annotation
        }
        sourceAnnotationView?.image = UIImage(named: "tracking")
        sourceAnnotationView?.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        return sourceAnnotationView
    }

}
