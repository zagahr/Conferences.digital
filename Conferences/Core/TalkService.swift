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
        if let search = notification.userInfo?["searchTerm"] as? String {
            searchTalks(by: search)
        } else if let _ = notification.userInfo?["Watchlist"] as? Bool {
            getWatchlist()
        } else {
            getAllTalks()
        }
    }

    private func searchTalks(by term: String) {

        let searchTerm = term.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")

        guard !searchTerm.isEmpty else {
            getAllTalks()
            return
        }

        var talks = self.talks.compactMap { $0 as? TalkModel }
        talks = talks.filter { $0.searchString.contains(searchTerm) }

        DispatchQueue.main.async {
            self.delegate?.didFetch(talks)
        }
    }

    private func getAllTalks() {
        DispatchQueue.main.async {
            self.delegate?.didFetch(self.talks)
        }
    }

    private func getWatchlist() {

        let watchlistIds = Storage.shared.getWatchlist()

        let talks = self.talks.filter {
            if let talk = $0 as? TalkModel {
                return watchlistIds.contains(talk.id)
            } else {
                return false
            }
        }

        DispatchQueue.main.async {
            self.delegate?.didFetch(talks)
        }
    }
}
