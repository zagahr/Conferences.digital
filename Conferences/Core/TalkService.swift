//
//  TalkService.swift
//  Conferences
//
//  Created by Timon Blask on 13/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    public static let UserDidSearch = NSNotification.Name("UserDidSearchNotification")
}

protocol TalkServiceDelegate: class {
    func didFetch(_ talks: [Codable])
    func fetchFailed(with error: APIError)
}

final class TalkService {
    weak var delegate: TalkServiceDelegate?
    private let apiClient = APIClient()

    private var talks = [Codable]()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(filterTalks(_:)), name: Notification.Name.UserDidSearch, object: nil)
    }
    
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
    
    @objc func filterTalks(_ notification: NSNotification) {
        guard var searchTerm = notification.userInfo?["searchTerm"] as? String, !searchTerm.isEmpty else {
            
            DispatchQueue.main.async {
                self.delegate?.didFetch(self.talks)
            }
            
            return
        }
        
        searchTerm = searchTerm.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        var talks = self.talks.compactMap { $0 as? TalkModel }
        talks = talks.filter { $0.searchString.contains(searchTerm) }
        
        DispatchQueue.main.async {
            self.delegate?.didFetch(talks)
        }
    }
}
