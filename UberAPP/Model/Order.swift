//
//  Order.swift
//  UberAPP
//
//  Created by Samir Hasanli on 24.06.21.
//

import Foundation

struct Order: Codable  {
    var OrderID : String
    var Username: String
    var cost: String
    var userLocation: Location
    var destinationLocation: Location
    
}

struct Location: Codable {
    var latitude: Double
    var longitude: Double
}


