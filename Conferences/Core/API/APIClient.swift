//
//  APIClient.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import ConferencesCore

final class APIClient {

    public static let shared = APIClient()

    func object<T: Codable>(recource: Resource, completionHandler: @escaping (Result<T, APIError>) -> Void) {
        send(resource: recource) { (result) in
            if let data = try? result.get() {
                if let model = try? JSONDecoder().decode([T].self, from: data).first {
                    completionHandler(.success(model!))
                } else {
                    completionHandler(.failure(.adapter))
                }
            } else {
                completionHandler(.failure(.unknown))
            }
        }
    }

    func list<T: Codable>(recource: Resource, completionHandler: @escaping (Result<[T], APIError>) -> Void) {
        send(resource: recource) { (result) in
            if let data = try? result.get() {
                 if let models = try? JSONDecoder().decode([T].self, from: data) {
                    completionHandler(.success(models))
                } else {
                    completionHandler(.failure(.adapter))
                }
            } else {
                completionHandler(.failure(.unknown))
            }
        }
    }

    func send(resource: Resource, completionHandler: @escaping (Result<Data, APIError>) -> Void) {
        let request = resource.urlRequest()

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completionHandler(.failure(.http(error!)))
                return
            }

            guard let data = data else {
                completionHandler(.failure(.unknown))

                return
            }

            completionHandler(.success(data))
        }.resume()
    }

}
