//
//  User.swift
//  UberAPP
//
//  Created by Samir Hasanli on 27.06.21.
//

import Foundation

struct User: Codable  {
    var token : String
    var _id : String
    var name : String
    var phoneNumber: String
    var latitude: Double
    var longitude: Double
}

