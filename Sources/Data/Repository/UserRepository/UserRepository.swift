//
//  File.swift
//  Data
//
//  Created by partnertientm2 on 4/11/25.
//

import Combine
import Foundation
import Domain

public final class UserRepositoryImpl: UserRepository {
    
    public init() {}

    public func getListUser(perPage: Int, since: Int) -> AnyPublisher<Result<Data, Domain.APIError>, Never> {
        NetworkServices.shared.request(request: APIEndPoint.getUsers(queryParams: .init(perPage: perPage, since: since)))
    }

    public func getUserDetails(userName: String) -> AnyPublisher<Result<Data, Domain.APIError>, Never> {
        NetworkServices.shared.request(request: APIEndPoint.getUser(param: .init(username: userName)))
    }
}
