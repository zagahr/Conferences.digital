//
//  APIClient.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

final class APIClient {
    func send<T: Codable>(resource: Resource, completionHandler: @escaping (Result<[T], APIError>) -> Void) {
        let request = resource.urlRequest()

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(.http(error)))
                return
            }

            guard let data = data else {
                completionHandler(.failure(.unknown))
                return
            }

            if let models = try? JSONDecoder().decode([T].self, from: data) {
                completionHandler(.success(models))
            } else {
                completionHandler(.failure(.adapter))
            }

        }.resume()
    }
}
