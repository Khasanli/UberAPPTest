//
//  DriverViewModel.swift
//  UberAPP
//
//  Created by Samir Hasanli on 27.06.21.
//

import Foundation
import Alamofire
import KeychainAccess

class DriverViewModel: NSObject {

    func registerAsDriver(name: String, phoneNumber: String, password: String, latitude: Double, longitude: Double, completionHandler: @escaping (User?, Bool) -> ()){
        let params: Parameters = [
            "name": name,
            "phoneNumber": phoneNumber,
            "password": password,
            "latitude": latitude,
            "longitude": longitude
        ]

        AF.request("http://localhost:3500/api/driver/register", method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200 ..< 299).responseJSON { AFdata in
                do {
                    guard let jsonObject = try JSONSerialization.jsonObject(with: AFdata.data!) as? [String: Any] else {
                        print("Error: Cannot convert data to JSON object")
                        return
                    }
                    guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                        print("Error: Cannot convert JSON object to Pretty JSON data")
                        return
                    }
//                    guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
//                        print("Error: Could print JSON in String")
//                        return
//                    }
                    let newUser: User = try! JSONDecoder().decode(User.self, from: prettyJsonData)
                    let keychain = Keychain(service: "com.higgstudio.UberAPP")
                    keychain["token"] = newUser.token
                    keychain["_id"] = newUser._id
                    user = newUser
                    completionHandler(newUser, true)
                } catch {
                    completionHandler(nil, false)
                    print("Error: Trying to convert JSON data to string")
                    return
                }
            }
    }
    
    func loginAsDriver(phoneNumber: String, password: String, completionHandler: @escaping (User?, Bool) -> ()){
        let params: Parameters = [
            "phoneNumber": phoneNumber,
            "password": password
        ]
        AF.request("http://localhost:3500/api/driver/login", method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).validate(statusCode: 200 ..< 299).responseJSON { AFdata in
            print(AFdata.result)
                do {
                    guard let jsonObject = try JSONSerialization.jsonObject(with: AFdata.data!) as? [String: Any] else {
                        print("Error: Cannot convert data to JSON object")
                        return
                    }
                    guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                        print("Error: Cannot convert JSON object to Pretty JSON data")
                        return
                    }
//                    guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
//                        print("Error: Could print JSON in String")
//                        return
//                    }
                    let newUser: User = try! JSONDecoder().decode(User.self, from: prettyJsonData)
                    let keychain = Keychain(service: "com.higgstudio.UberAPP")
                    keychain["token"] = newUser.token
                    keychain["_id"] = newUser._id
                    user = newUser
                    completionHandler(newUser, true)
                } catch {
                    completionHandler(nil, false)
                    print("Error: Trying to convert JSON data to string")
                    return
                }
            }
    }
}


