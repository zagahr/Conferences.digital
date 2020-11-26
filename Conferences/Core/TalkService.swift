//
//  TalkService.swift
//  Conferences
//
//  Created by Timon Blask on 13/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension NSNotification.Name {
    public static let UserDidSearch = NSNotification.Name("UserDidSearchNotification")
}

protocol TalkServiceType {
    func fetchData() -> Observable<[Codable]>
}

final class TalkService: TalkServiceType {

    // MARK: - Properties

    private let apiClient: APIClient

    private var talks = [Codable]()

    // MARK: - Initalization

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchData() -> Observable<[Codable]> {
        Observable.create({ observer -> Disposable in
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
                            observer.onNext(result)
                        }

                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            }

            return Disposables.create()
        })
        .take(1)
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
//            self.delegate?.didFetch(talks)
        }
    }

    private func getAllTalks() {
        DispatchQueue.main.async {
//            self.delegate?.didFetch(self.talks)
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
//            self.delegate?.didFetch(talks)
        }
    }
}
