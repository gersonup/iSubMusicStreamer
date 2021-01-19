//
//  DownloadedFolderArtistsViewController.swift
//  iSub
//
//  Created by Benjamin Baron on 1/15/21.
//  Copyright © 2021 Ben Baron. All rights reserved.
//

import UIKit
import Resolver
import SnapKit
import CocoaLumberjackSwift

@objc final class DownloadedFolderArtistsViewController: UIViewController {
    @Injected private var store: Store
    
    private let tableView = UITableView()
    
    private var downloadedFolderArtists = [DownloadedFolderArtist]()
    
    private func registerForNotifications() {
        // Set notification receiver for when queued songs finish downloading to reload the table
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadTable), name: ISMSNotification_StreamHandlerSongDownloaded)
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadTable), name: ISMSNotification_CacheQueueSongDownloaded)
        
        // Set notification receiver for when cached songs are deleted to reload the table
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadTable), name: ISMSNotification_CachedSongDeleted)
        
        // Set notification receiver for when network status changes to reload the table
        NotificationCenter.addObserverOnMainThread(self, selector: #selector(reloadTable), name:NSNotification.Name.reachabilityChanged.rawValue)
    }
    
    private func unregisterForNotifications() {
        NotificationCenter.removeObserverOnMainThread(self, name: ISMSNotification_StreamHandlerSongDownloaded)
        NotificationCenter.removeObserverOnMainThread(self, name: ISMSNotification_CacheQueueSongDownloaded)
        NotificationCenter.removeObserverOnMainThread(self, name: ISMSNotification_CachedSongDeleted)
        NotificationCenter.removeObserverOnMainThread(self, name: NSNotification.Name.reachabilityChanged.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        title = "Downloaded Folders"
        setupDefaultTableView(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForNotifications()
        reloadTable()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterForNotifications()
    }
    
    @objc private func reloadTable() {
        downloadedFolderArtists = store.downloadedFolderArtists(serverId: Settings.shared().currentServerId)
        tableView.reloadData()
    }
}

extension DownloadedFolderArtistsViewController: UITableViewConfiguration {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedFolderArtists.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueUniversalCell()
        cell.show(cached: false, number: false, art: false, secondary: false, duration: false)
        cell.update(model: downloadedFolderArtists[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        SwipeAction.downloadQueueAndDeleteConfig(downloadHandler: nil, queueHandler: {
            // TODO: implement this
//            [viewObjectsS showLoadingScreenOnMainWindowWithMessage:nil];
//            [EX2Dispatch runInBackgroundAsync:^{
//                NSMutableArray *songMd5s = [[NSMutableArray alloc] initWithCapacity:50];
//                [databaseS.songCacheDbQueue inDatabase:^(FMDatabase *db) {
//                    FMResultSet *result = [db executeQuery:@"SELECT md5 FROM cachedSongsLayout WHERE seg1 = ? ORDER BY seg2 COLLATE NOCASE", folderArtist.name];
//                    while ([result next]) {
//                        @autoreleasepool {
//                            NSString *md5 = [result stringForColumnIndex:0];
//                            if (md5) [songMd5s addObject:md5];
//                        }
//                    }
//                    [result close];
//                }];
//
//                for (NSString *md5 in songMd5s) {
//                    @autoreleasepool {
//                        [[ISMSSong songFromCacheDbQueue:md5] addToCurrentPlaylistDbQueue];
//                    }
//                }
//
//                [NSNotificationCenter postNotificationToMainThreadWithName:ISMSNotification_CurrentPlaylistSongsQueued];
//
//                [EX2Dispatch runInMainThreadAsync:^{
//                    [viewObjectsS hideLoadingScreen];
//                }];
//            }];
        }, deleteHandler: {
            ViewObjects.shared().showLoadingScreenOnMainWindow(withMessage: nil)
            EX2Dispatch.runInBackgroundAsync {
                if self.store.deleteDownloadedSongs(downloadedFolderArtist: self.downloadedFolderArtists[indexPath.row]) {
                    Cache.shared().findCacheSize()
                    NotificationCenter.postNotificationToMainThread(name: ISMSNotification_CachedSongDeleted)
                    if (!CacheQueue.shared().isQueueDownloading) {
                        CacheQueue.shared().startDownloadQueue()
                    }
                }
                EX2Dispatch.runInMainThreadAsync {
                    ViewObjects.shared().hideLoadingScreen()
                }
            }
        })
    }
}