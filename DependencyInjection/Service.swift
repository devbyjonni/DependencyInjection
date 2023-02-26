//
//  Service.swift
//  DependencyInjection
//
//  Created by Jonni Akesson on 2023-02-26.
//

import Foundation
import Combine

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponseStatus
    case dataTaskError(String)
    case corruptData
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("The endpoint URL is invalid", comment: "")
        case .invalidResponseStatus:
            return NSLocalizedString("The APIO failed to issue a valid response.", comment: "")
        case .dataTaskError(let string):
            return string
        case .corruptData:
            return NSLocalizedString("The data provided appears to be corrupt", comment: "")
        case .decodingError(let string):
            return string
        }
    }
}

protocol Servicing {
    associatedtype T
    func getData<T: Decodable>(url: URL, completionHandler: @escaping (Result<T, APIError>) -> Void)
    func getData<T: Decodable>(url: URL) async throws -> T
    func getData<T: Decodable>(url: URL) -> AnyPublisher<T, Error>
}

class Service: Servicing {
    typealias T = Decodable
    
    func getData<T: Decodable>(url: URL, completionHandler: @escaping (Result<T, APIError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
            else {
                completionHandler(.failure(.invalidResponseStatus))
                return
            }
            
            guard error == nil else {
                completionHandler(.failure(.dataTaskError(error!.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.corruptData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completionHandler(.success(decodedData))
            } catch {
                completionHandler(.failure(.decodingError(error.localizedDescription)))
            }
        }
        .resume()
    }
    
    func getData<T: Decodable>(url: URL) async throws -> T {
        do {
            let (data, response) = try await  URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
            else { throw APIError.invalidResponseStatus }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return decodedData
            } catch {
                throw APIError.decodingError(error.localizedDescription)
            }
            
        } catch {
            throw APIError.dataTaskError(error.localizedDescription)
        }
    }
    
    func getData<T: Decodable>(url: URL) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
                else {
                    throw APIError.invalidResponseStatus
                }
                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
