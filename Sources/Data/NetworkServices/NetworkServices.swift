//
//  File.swift
//  Data
//
//  Created by partnertientm2 on 4/11/25.
//

import Foundation
import Combine
import Shared

struct NetworkServices {
    
    /// URLSession instance for handling network requests.
    private let urlSession: URLSession
    
    /// Shared instance of `NetworkServices` (Singleton Pattern).
    static let shared = NetworkServices()
    
    /// Private initializer to enforce singleton usage.
    private init() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = 10  // Sets resource timeout
        sessionConfig.timeoutIntervalForRequest = 10   // Sets request timeout
        urlSession = URLSession(configuration: sessionConfig)
    }
    
    /// Performs a network request and retrieves the cached data if available.
    ///
    /// - Parameters:
    ///   - request: The `HTTPRequest` to be executed.
    ///   - cacheExpiryTime: The time interval (in seconds) before the cache expires.
    /// - Returns: A publisher emitting a `Result` containing the decoded response or an error.
    func request(request: HTTPRequest, cacheExpiryTime: TimeInterval = 3600) -> AnyPublisher<Result<Data, NetworkRequestError>, Never> {
        // Attempt to build a valid URLRequest from the HTTPRequest object.
        guard let request = request.buildRequest() else {
            return Just(.failure(.invalidRequest)).eraseToAnyPublisher()
        }
        // If no cache is found, proceed with the network request.
        return makeRequest(request: request, cacheExpiryTime: cacheExpiryTime)
    }
    
    /// Executes a network request and caches the response if successful.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to be executed.
    ///   - cacheExpiryTime: The cache expiry duration in seconds.
    /// - Returns: A publisher emitting a `Result` containing the decoded response or an error.
    private func makeRequest(request: URLRequest, cacheExpiryTime: TimeInterval = 3600) -> AnyPublisher<Result<Data, NetworkRequestError>, Never> {
        Log.info("Make request - [\(request.httpMethod?.uppercased() ?? "")] '\(request.url?.absoluteString ?? "")'")

        return urlSession.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw httpError(0) // Invalid response
                }

                Log.info("[\(httpResponse.statusCode)] '\(request.url?.absoluteString ?? "")'")

                // Try to pretty-print JSON if possible
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                   let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    Log.info(jsonString)
                } else {
                    Log.warning("Failed to decode JSON")
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    throw httpError(httpResponse.statusCode)
                }

                return data
            }
            .map { data in
                Result.success(data)
            }
            .catch { error in
                Just(.failure(handleError(error)))
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Maps HTTP status codes to `NetworkRequestError` cases.
    ///
    /// - Parameter statusCode: The HTTP response status code.
    /// - Returns: Corresponding `NetworkRequestError` type.
    private func httpError(_ statusCode: Int) -> NetworkRequestError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 402, 405...499: return .error4xx(statusCode)
        case 500: return .serverError
        case 501...599: return .error5xx(statusCode)
        default: return .unknownError
        }
    }
    
    /// Handles general errors encountered during network requests.
    ///
    /// - Parameter error: The encountered error.
    /// - Returns: Corresponding `NetworkRequestError` type.
    private func handleError(_ error: Error) -> NetworkRequestError {
        switch error {
        case is Swift.DecodingError:
            return .decodingError(error.localizedDescription)
        case let urlError as URLError:
            if urlError.code == .timedOut {
                return .timeOut
            }
            if urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                return .noInternet
            }
            return .urlSessionFailed(urlError)
        case let error as NetworkRequestError:
            return error
        default:
            return .unknownError
        }
    }
}
