//
//  File.swift
//  Data
//
//  Created by partnertientm2 on 4/11/25.
//

import Combine
import Foundation

public protocol UserRepository {
    
    func getListUser(param: APIParameters.getListUser) -> AnyPublisher<Result<Data, NetworkRequestError>, Never>
    func getUserDetails(param: APIParameters.getUser) -> AnyPublisher<Result<Data, NetworkRequestError>, Never>
}

public final class UserRepositoryImpl: UserRepository {
    
    public init() {}
    
    public func getListUser(param: APIParameters.getListUser) -> AnyPublisher<Result<Data, NetworkRequestError>, Never> {
        NetworkServices.shared.request(request: APIEndPoint.getUsers(queryParams: param))
    }
    
    public func getUserDetails(param: APIParameters.getUser) -> AnyPublisher<Result<Data, NetworkRequestError>, Never> {
        NetworkServices.shared.request(request: APIEndPoint.getUser(param: param))
    }
}
