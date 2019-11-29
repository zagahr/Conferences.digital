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
}

final class ListViewDataSource: NSObject {
    weak var delegate: ListViewDataSourceDelegate?

    var talks: [Codable] = []

    func isTalk(at row: Int) -> Bool {
        if let _ = talks[row] as? TalkModel {
            return true
        } else {
            return false
        }
    }

}

extension ListViewDataSource: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return talks.count
    }

    fileprivate struct Metrics {
        static let headerRowHeight: CGFloat = 75
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
