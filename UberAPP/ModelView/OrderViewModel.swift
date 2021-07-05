//
//  OrderViewModel.swift
//  UberAPP
//
//  Created by Samir Hasanli on 28.06.21.
//

import Foundation
import Alamofire
import KeychainAccess

class OrderViewModel: NSObject {
    
    func getKeychain(completionHandler: (String) -> ()){
        let keychain = Keychain(service: "com.higgstudio.UberAPP")
        guard let token = keychain["token"] else { return }
        completionHandler(token)
    }
}
