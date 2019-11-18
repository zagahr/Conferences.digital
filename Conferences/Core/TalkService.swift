//
//  TalkService.swift
//  Conferences
//
//  Created by Timon Blask on 13/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

protocol TalkServiceDelegate: class {
    func didFetch(_ talks: [Codable])
    func fetchFailed(with error: APIError)
}

final class TalkService {
    weak var delegate: TalkServiceDelegate?
    private let apiClient = APIClient()


    private var talks = [Codable]()

    func fetchData() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.apiClient.send(resource: ConferenceResource.all, completionHandler: { [weak self] (response: Result<[ConferenceModel], APIError>) in
                switch response {
                case .success(let models):
                    var result = [Codable]()

                    models.forEach {
                        result.append($0)
                        result.append(contentsOf: $0.talks)
                    }

                    self?.talks = result

                    DispatchQueue.main.async {
                        self?.delegate?.didFetch(result)
                    }

                case .failure(let error):
                    DispatchQueue.main.async { self?.delegate?.fetchFailed(with: error) }
                }
            })
        }
    }

    func removeEmptyConferences(_ list: [Searchable]) -> [Searchable] {
        var newList: [Searchable] = []
        
        for i in 0..<list.count {
            if let _ = list[i] as? ConferenceModel, i<(list.count-1), let _ = list[i+1] as? TalkModel {
                newList.append(list[i])
            }
            else if let _ = list[i] as? TalkModel {
                newList.append(list[i])
            }
        }
        
        return newList
    }
}
