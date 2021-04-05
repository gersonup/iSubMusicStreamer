//
//  DownloadQueueViewController.swift
//  iSub
//
//  Created by Benjamin Baron on 2/17/21.
//  Copyright © 2021 Ben Baron. All rights reserved.
//

import UIKit
import Resolver
import SnapKit
import CocoaLumberjackSwift

final class DownloadQueueViewController: AbstractDownloadsViewController {
    @Injected private var store: Store
    @Injected private var settings: Settings
    @Injected private var cache: Cache
    @Injected private var cacheQueue: CacheQueue
    
    var serverId: Int { Settings.shared().currentServerId }
    
//    private var downloadedSongs = [DownloadedSong]()
    override var itemCount: Int { store.downloadQueueCount() ?? 0 }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Download Queue"
        saveEditHeader.set(saveType: "Song", countType: "Song", isLargeCount: true)
        tableView.rowHeight = Defines.tallRowHeight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadTable), name: Notifications.cacheQueueSongAdded)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadTable), name: Notifications.cacheQueueSongRemoved)
    }

    @objc override func reloadTable() {
//        downloadedSongs = store.downloadedSongs(serverId: serverId)
        super.reloadTable()
        addOrRemoveSaveEditHeader()
    }
    
    override func deleteItems(indexPaths: [IndexPath]) {
//        HUD.show()
//        DispatchQueue.userInitiated.async {
//            for indexPath in indexPaths {
//                _ = self.store.delete(downloadedSong: self.downloadedSongs[indexPath.row])
//            }
//            self.cache.findCacheSize()
//            HUD.hide()
//            NotificationCenter.postOnMainThread(name: Notifications.cachedSongDeleted)
//            if (!self.cacheQueue.isDownloading) {
//                self.cacheQueue.start()
//            }
//        }
    }
}

extension DownloadQueueViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueUniversalCell()
//        if let song = store.song(downloadedSong: downloadedSongs[indexPath.row]) {
//            cell.update(song: song, number: false, cached: false, art: true)
//        }
        if let song = store.songFromDownloadQueue(position: indexPath.row) {
            cell.update(song: song, number: false, cached: false, art: true)
            cell.hideHeaderLabel = false
            if indexPath.row == 0 {
                cell.headerText = "Downloading!"
            } else {
                cell.headerText = "Waiting..."
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
//        if !isEditing, let song = store.playSong(position: indexPath.row, downloadedSongs: downloadedSongs), !song.isVideo {
//            NotificationCenter.postOnMainThread(name: Notifications.showPlayer)
//        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // TODO: implement this
        return nil
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let song = store.songFromDownloadQueue(position: indexPath.row)
        return contextMenuDownloadAndQueueConfig(model: song)
    }
}