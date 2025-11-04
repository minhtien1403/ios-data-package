//
//  File.swift
//  Data
//
//  Created by partnertientm2 on 4/11/25.
//

import Foundation
import Shared

struct APIEndPoint {
    
    struct getUsers: HTTPRequest {
        
        var path: String = "/users"
        var queryParams: [String : Any]?
        
        init(queryParams: APIParameters.getListUser) {
            self.queryParams = queryParams.asDictionary
        }
    }
    
    struct getUser: HTTPRequest {
        
        var path: String
                
        init(param: APIParameters.getUser) {
            path = "/users/\(param.username)"
        }
    }
}
