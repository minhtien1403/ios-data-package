//
//  File.swift
//  Data
//
//  Created by partnertientm2 on 4/11/25.
//

import Foundation

public struct APIParameters {
    
    public struct getListUser: Encodable {
        
        public var perPage: Int
        public var since: Int
        
        public init(perPage: Int, since: Int) {
            self.perPage = perPage
            self.since = since
        }
        
        private enum CodingKeys: String, CodingKey {
            case perPage = "per_page"
            case since
        }
    }
    
    public struct getUser: Encodable {
        
        public init(username: String) {
            self.username = username
        }
        
        public var username: String
    }
}
