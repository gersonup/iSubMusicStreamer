//
//  ServerPlaylistsViewController.swift
//  iSub
//
//  Created by Benjamin Baron on 1/15/21.
//  Copyright © 2021 Ben Baron. All rights reserved.
//

import UIKit
import SnapKit
import CocoaLumberjackSwift
import Resolver

@objc final class ServerPlaylistsViewController: UIViewController {
    @Injected private var store: Store
    
    private let saveEditHeader = SaveEditHeader(saveType: "playlist", countType: "playlist", pluralizeClearType: false, isLargeCount: true)
    private let tableView = UITableView()
    
    private var serverPlaylistsLoader: ServerPlaylistsLoader?
    private var serverPlaylists = [ServerPlaylist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        title = "Server Playlists"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Colors.background
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.register(UniversalTableViewCell.self, forCellReuseIdentifier: UniversalTableViewCell.reuseId)
        tableView.rowHeight = Defines.rowHeight
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    deinit {
        cancelLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        Flurry.logEvent("ServerPlaylistsTab")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setEditing(false, animated: false)
    }
    
    private func addSaveEditHeader() {
        guard saveEditHeader.superview == nil else { return }
        
        saveEditHeader.delegate = self
        saveEditHeader.count = PlayQueue.shared.count
        view.addSubview(saveEditHeader)
        saveEditHeader.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.trailing.top.equalToSuperview()
        }
        
        tableView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(50)
        }
        tableView.setNeedsUpdateConstraints()
    }
    
    private func removeSaveEditHeader() {
        guard saveEditHeader.superview != nil else { return }
        
        saveEditHeader.removeFromSuperview()
        
        tableView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(0)
        }
        tableView.setNeedsUpdateConstraints()
    }
    
    private func reloadData() {
        tableView.refreshControl = nil
        setEditing(false, animated: false)
        removeSaveEditHeader()
        serverPlaylists = store.serverPlaylists(serverId: Settings.shared().currentServerId)
        if serverPlaylists.count > 0 {
            addSaveEditHeader()
        } else {
            loadServerPlaylists()
        }
        tableView.reloadData()
        tableView.refreshControl = RefreshControl(handler: { [unowned self] in
            loadServerPlaylists()
        })
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        saveEditHeader.setEditing(editing, animated: animated)
        
        if isEditing {
            // Deselect all the rows
            for i in 0..<serverPlaylists.count {
                tableView.deselectRow(at: IndexPath(row: i, section: 0), animated: false)
            }
        }
        saveEditHeader.selectedCount = 0
    }
    
    private func deleteServerPlaylists(indexPaths: [IndexPath]) {
        // TODO: implement this
    //    self.tableView.scrollEnabled = NO;
    //    [viewObjectsS showAlbumLoadingScreen:self.view sender:self];
    //
    //    for (NSNumber *index in rowIndexes) {
    //        NSString *playlistId = [[self.serverPlaylistsDataModel.serverPlaylists objectAtIndexSafe:[index intValue]] playlistId];
    //        NSMutableURLRequest *request = [NSMutableURLRequest requestWithSUSAction:@"deletePlaylist" parameters:@{@"id": n2N(playlistId)}];
    //        NSURLSessionDataTask *dataTask = [self.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    //            if (error) {
    //                // TODO: Handle error
    //            }
    //            [EX2Dispatch runInMainThreadAsync:^{
    //                [viewObjectsS hideLoadingScreen];
    //                [self reloadData];
    //            }];
    //        }];
    //        [dataTask resume];
    //    }
    }
    
    private func loadServerPlaylists() {
        cancelLoad()
        ViewObjects.shared().showAlbumLoadingScreenOnMainWindowWithSender(self)
        self.serverPlaylistsLoader = ServerPlaylistsLoader()
        self.serverPlaylistsLoader?.callback = { [unowned self] (success, error) in
            if success {
                self.serverPlaylists = self.serverPlaylistsLoader?.serverPlaylists ?? []
                self.saveEditHeader.count = self.serverPlaylists.count
                self.tableView.reloadData()
                self.addSaveEditHeader()
            } else {
                // TODO: Show error message
            }
            ViewObjects.shared().hideLoadingScreen()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    @objc func cancelLoad() {
        serverPlaylistsLoader?.cancelLoad()
        serverPlaylistsLoader?.callback = nil
        serverPlaylistsLoader = nil
    }
}

extension ServerPlaylistsViewController: SaveEditHeaderDelegate {
    func saveEditHeaderEditAction(_ saveEditHeader: SaveEditHeader) {
        setEditing(!isEditing, animated: true)
    }
    
    func saveEditHeaderSaveDeleteAction(_ saveEditHeader: SaveEditHeader) {
        if let indexPathsForSelectedRows = tableView.indexPathsForSelectedRows {
            deleteServerPlaylists(indexPaths: indexPathsForSelectedRows)
        }
        ViewObjects.shared().hideLoadingScreen()
    }
}

extension ServerPlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverPlaylists.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UniversalTableViewCell.reuseId) as! UniversalTableViewCell
        cell.hideNumberLabel = true
        cell.hideCoverArt = false
        cell.hideDurationLabel = true
        cell.hideSecondaryLabel = false
        cell.update(model: serverPlaylists[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            saveEditHeader.selectedCount += 1
            return
        }
        pushCustom(ServerPlaylistViewController(serverPlaylist: serverPlaylists[indexPath.row]))
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEditing {
            saveEditHeader.selectedCount -= 1
            return
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return SwipeAction.downloadQueueAndDeleteConfig(model: serverPlaylists[indexPath.row]) {
            self.deleteServerPlaylists(indexPaths: [indexPath])
        }
    }
}