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
    private var backup = [Codable]()

    init() {
        observe()
    }

    func observe() {
        NotificationCenter.default.addObserver(self, selector: #selector(filterTalks), name: .refreshTableView, object: nil)
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
                    self?.backup = result

                    DispatchQueue.main.async {
                        self?.delegate?.didFetch(result)
                    }

                case .failure(let error):
                    DispatchQueue.main.async { self?.delegate?.fetchFailed(with: error) }
                }
            })
        }
    }

    @objc private func filterTalks() {
        guard let seachableBackup = self.backup as? [Searchable] else { return }
        let activeTags = TagSyncService.shared.tags.filter { $0.isActive }

        if activeTags.isEmpty {
            self.talks = backup
        } else {
            var currentBatch = seachableBackup
            activeTags.forEach ({ (tag) in
                currentBatch = currentBatch.filter { $0.searchString.contains(tag.query)}
            })

            self.talks = currentBatch as! [Codable]
        }

        DispatchQueue.main.async {
            self.delegate?.didFetch(self.talks)
        }
    }
}
