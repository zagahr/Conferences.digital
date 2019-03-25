//
//  ListViewDataSource.swift
//  Conferences
//
//  Created by Timon Blask on 13/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

protocol ListViewDataSourceDelegate: class {
    func didSelectTalk(_ talk: TalkModel)
    func reloadCellAt(index: Int)
}

final class ListViewDataSource: NSObject {
    weak var delegate: ListViewDataSourceDelegate?

    weak var filterTab: NSSegmentedControl?
    
    //var talks: [Codable] = []
    private var allTalks: [Codable] = []
    private var notWatchedTalks: [Codable] = []
    private var watchedTalks: [Codable] = []
    var talks: [Codable] {
        get {
            guard let t = self.filterTab else { return [] }
            
            switch t.selectedSegment {
            // All
            case 0: return self.allTalks
            // Not viewed
            case 1: return self.notWatchedTalks
            // Viewed
            case 2: return self.watchedTalks
            default: return []
            }
        }
        set {
            allTalks = newValue
            
            buildLists()
        }
    }
    
    func buildLists() {
        // Remove all the watched talks
        var nw: [Codable] = self.allTalks.compactMap {
            if let talk_Model = $0 as? TalkModel {
                return talk_Model.watched ? nil : $0
            }
            else { return $0 }
        }
        
        // After that, only include the conferences with any not watched talk
        self.notWatchedTalks = []
        for index in 0..<(nw.count) {
            if let _ = nw[index] as? ConferenceModel {
                if (index < nw.count-1) {
                    if let _ = nw[index+1] as? ConferenceModel { }
                    else {
                        self.notWatchedTalks.append(nw[index])
                    }
                }
            }
            else {
                self.notWatchedTalks.append(nw[index])
            }
        }
        
        // Remove all the not watched talks
        var w: [Codable] = self.allTalks.compactMap {
            if let talk_Model = $0 as? TalkModel {
                return talk_Model.watched ? $0 : nil
            }
            else { return $0 }
        }
        
        // After that, only include the conferences with any watched talk
        self.watchedTalks = []
        for index in 0..<(w.count) {
            if let _ = w[index] as? ConferenceModel {
                if (index < w.count-1) {
                    if let _ = w[index+1] as? ConferenceModel { }
                    else {
                        self.watchedTalks.append(w[index])
                    }
                }
            }
            else {
                self.watchedTalks.append(w[index])
            }
        }
    }

    func isTalk(at row: Int) -> Bool {
        if let _ = talks[row] as? TalkModel {
            return true
        } else {
            return false
        }
    }

    func removeWatchIcon() {
        guard let index = talks.firstIndex(where: { (talk) -> Bool in
            if var model = talk as? TalkModel {
                if model.currentlyPlaying == true {
                    model.currentlyPlaying = false
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }) else { return }

        self.delegate?.reloadCellAt(index: index)
    }

}

extension ListViewDataSource: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return talks.count
    }

    fileprivate struct Metrics {
        static let headerRowHeight: CGFloat = 232
        static let sessionRowHeight: CGFloat = 64
    }

    private struct Constants {
        static let sessionCellIdentifier = "sessionCell"
        static let titleCellIdentifier = "titleCell"
        static let rowIdentifier = "row"
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if isTalk(at: row) {
            return cellForSessionViewModel(tableView, at: row)
        } else {
            return cellForSectionTitle(tableView, at: row)
        }
    }

    func didSelectIndex(at row: Int) {
        if let talk = talks[row] as? TalkModel {
            self.delegate?.didSelectTalk(talk)
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        if let tableView = notification.object as? NSTableView {
            didSelectIndex(at: tableView.selectedRow)
        }
    }

    private func cellForSessionViewModel(_ tableView: NSTableView, at row: Int) -> TalkCellView? {

        var cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: Constants.sessionCellIdentifier), owner: tableView) as? TalkCellView

        if cell == nil {
            cell = TalkCellView(frame: .zero)
            cell?.identifier = NSUserInterfaceItemIdentifier(rawValue: Constants.sessionCellIdentifier)
        }


        if let talk = talks[row] as? TalkModel {
            cell!.configureView(with: talk)
        }


        return cell
    }

    private func cellForSectionTitle(_ tableView: NSTableView, at row: Int) -> TitleTableCellView? {
        var cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: Constants.titleCellIdentifier), owner: tableView) as? TitleTableCellView

        if cell == nil {
            cell = TitleTableCellView(frame: .zero)
            cell?.identifier = NSUserInterfaceItemIdentifier(rawValue: Constants.titleCellIdentifier)
        }

        if let conference = talks[row] as? ConferenceModel {
            cell?.configureView(with: conference)
        }

        return cell
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let _ = talks[row] as? TalkModel {
            return Metrics.sessionRowHeight
        } else {
            return Metrics.headerRowHeight
        }
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if isTalk(at: row) {
            return true
        } else {
            return false
        }
    }

    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        if isTalk(at: row) {
            return false
        } else {
            return true
        }
    }
}
