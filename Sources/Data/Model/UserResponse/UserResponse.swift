//
//  File.swift
//  Data
//
//  Created by partnertientm2 on 4/11/25.
//

import Foundation

public struct UserResponse: Codable {
    
    public let login: String
    public let avatarURL: String
    public let htmlURL: String
    public let id: Int

    enum CodingKeys: String, CodingKey {
        case login, id
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
    }
}

public struct UserDetailsResponse: Codable {
    
    public let login: String
    public let avatarURL: String
    public let blog: String
    public let location: String?
    public let followers: Int
    public let following: Int
    public let name: String

    enum CodingKeys: String, CodingKey {
        case login, name, blog, location, followers, following
        case avatarURL = "avatar_url"
    }
}
