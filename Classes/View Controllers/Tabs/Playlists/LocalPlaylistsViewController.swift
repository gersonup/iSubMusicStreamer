//
//  LocalPlaylistsViewController.swift
//  iSub
//
//  Created by Benjamin Baron on 1/15/21.
//  Copyright © 2021 Ben Baron. All rights reserved.
//

import UIKit
import SnapKit
import CocoaLumberjackSwift
import Resolver

@objc final class LocalPlaylistsViewController: UIViewController {
    @Injected private var store: Store
    
    private let saveEditHeader = SaveEditHeader(saveType: "playlist", countType: "song", pluralizeClearType: false, isLargeCount: false)
    private let tableView = UITableView()
    
    private var localPlaylists = [LocalPlaylist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        title = "Local Playlists"
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        Flurry.logEvent("LocalPlaylistsTab")
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
        setEditing(false, animated: false)
        removeSaveEditHeader()
        localPlaylists = store.localPlaylists()
        if localPlaylists.count > 0 {
            addSaveEditHeader()
        }
        tableView.reloadData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        saveEditHeader.setEditing(editing, animated: animated)
        
        if isEditing {
            // Deselect all the rows
            for i in 0..<localPlaylists.count {
                tableView.deselectRow(at: IndexPath(row: i, section: 0), animated: false)
            }
        }
        saveEditHeader.selectedCount = 0
    }
    
    private func uploadPlaylist(name: String) {
        // TODO: implement this
    //    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:n2N(name), @"name", nil];
    //
    //    NSMutableArray *songIds = [NSMutableArray arrayWithCapacity:self.currentPlaylistCount];
    //    NSString *currTable = settingsS.isJukeboxEnabled ? @"jukeboxCurrentPlaylist" : @"currentPlaylist";
    //    NSString *shufTable = settingsS.isJukeboxEnabled ? @"jukeboxShufflePlaylist" : @"shufflePlaylist";
    //    NSString *table = PlayQueue.shared.isShuffle ? shufTable : currTable;
    //
    //    [databaseS.currentPlaylistDbQueue inDatabase:^(FMDatabase *db) {
    //         for (int i = 0; i < self.currentPlaylistCount; i++) {
    //             @autoreleasepool {
    //                 ISMSSong *aSong = [ISMSSong songFromDbRow:i inTable:table inDatabase:db];
    //                 [songIds addObject:n2N(aSong.songId)];
    //             }
    //         }
    //     }];
    //    [parameters setObject:[NSArray arrayWithArray:songIds] forKey:@"songId"];
    //    NSURLRequest *request = [NSMutableURLRequest requestWithSUSAction:@"createPlaylist" parameters:parameters];
    //    NSURLSessionDataTask *dataTask = [self.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    //        if (error) {
    //            if (settingsS.isPopupsEnabled) {
    //                [EX2Dispatch runInMainThreadAsync:^{
    //                    NSString *message = [NSString stringWithFormat:@"There was an error saving the playlist to the server.\n\nError %li: %@", (long)error.code, error.localizedDescription];
    //                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
    //                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    //                    [self presentViewController:alert animated:YES completion:nil];
    //                }];
    //            }
    //        } else {
    //            RXMLElement *root = [[RXMLElement alloc] initFromXMLData:data];
    //            if (!root.isValid) {
    //                NSError *error = [NSError errorWithISMSCode:ISMSErrorCode_NotXML];
    //                [self subsonicErrorCode:nil message:error.description];
    //            } else {
    //                RXMLElement *error = [root child:@"error"];
    //                if (error.isValid) {
    //                    NSString *code = [error attribute:@"code"];
    //                    NSString *message = [error attribute:@"message"];
    //                    [self subsonicErrorCode:code message:message];
    //                }
    //            }
    //        }
    //
    //        [EX2Dispatch runInMainThreadAsync:^{
    //            self.tableView.scrollEnabled = YES;
    //            [viewObjectsS hideLoadingScreen];
    //        }];
    //    }];
    //    [dataTask resume];
    //
    //    self.tableView.scrollEnabled = NO;
    //    [viewObjectsS showAlbumLoadingScreen:self.view sender:self];
    }
    
    private func deleteLocalPlaylists(indexPaths: [IndexPath]) {
        // TODO: implement this
    //    // Sort the row indexes to make sure they're accending
    //    NSArray<NSNumber*> *sortedRowIndexes = [rowIndexes sortedArrayUsingSelector:@selector(compare:)];
    //
    //    [databaseS.localPlaylistsDbQueue inDatabase:^(FMDatabase *db) {
    //        [db executeUpdate:@"DROP TABLE localPlaylistsTemp"];
    //        [db executeUpdate:@"CREATE TABLE localPlaylistsTemp(playlist TEXT, md5 TEXT)"];
    //        for (NSNumber *index in [sortedRowIndexes reverseObjectEnumerator]) {
    //            @autoreleasepool {
    //                NSInteger rowId = [index integerValue] + 1;
    //                NSString *md5 = [db stringForQuery:[NSString stringWithFormat:@"SELECT md5 FROM localPlaylists WHERE ROWID = %li", (long)rowId]];
    //                [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE playlist%@", md5]];
    //                [db executeUpdate:@"DELETE FROM localPlaylists WHERE md5 = ?", md5];
    //            }
    //        }
    //        [db executeUpdate:@"INSERT INTO localPlaylistsTemp SELECT * FROM localPlaylists"];
    //        [db executeUpdate:@"DROP TABLE localPlaylists"];
    //        [db executeUpdate:@"ALTER TABLE localPlaylistsTemp RENAME TO localPlaylists"];
    //    }];
    //
    //    [self.tableView reloadData];
    //
    //    [self editPlaylistAction:nil];
    //    [self reloadData];
    }
    
    @objc func cancelLoad() {
        // TODO: Cancel the upload
        ViewObjects.shared().hideLoadingScreen()
    }
    
    private func showSavePlaylistAlert() {
        let alert = UIAlertController(title: "Save Playlist", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Playlist name"
        }
        alert.addAction(title: "Save", style: .default) { action in
            // TODO: implement this
    //        NSString *name = [[[alert textFields] firstObject] text];
    //            NSString *tableName = [NSString stringWithFormat:@"splaylist%@", name.md5];
    //            if ([databaseS.localPlaylistsDbQueue tableExists:tableName]) {
    //                // If it exists, ask to overwrite
    //                [self showOverwritePlaylistAlert:name];
    //            } else {
    //                [self uploadPlaylist:name];
    //            }
        }
        alert.addCancelAction()
        present(alert, animated: true, completion: nil)
    }
}

extension LocalPlaylistsViewController: SaveEditHeaderDelegate {
    func saveEditHeaderEditAction(_ saveEditHeader: SaveEditHeader) {
        setEditing(!isEditing, animated: true)
    }
    
    func saveEditHeaderSaveDeleteAction(_ saveEditHeader: SaveEditHeader) {
        if !saveEditHeader.deleteLabel.isHidden {
            ViewObjects.shared().showLoadingScreenOnMainWindow(withMessage: "Deleting")
            EX2Dispatch.runInBackgroundAsync {
                if let indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows {
                    self.deleteLocalPlaylists(indexPaths: indexPathsForSelectedRows)
                }
                EX2Dispatch.runInMainThreadAsync {
                    ViewObjects.shared().hideLoadingScreen()
                }
            }
        }
    }
}

extension LocalPlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localPlaylists.count
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
        cell.hideCoverArt = true
        cell.hideDurationLabel = true
        cell.hideSecondaryLabel = false
        cell.update(model: localPlaylists[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            saveEditHeader.selectedCount += 1
            return
        }
        
        pushCustom(LocalPlaylistViewController(localPlaylist: localPlaylists[indexPath.row]))
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEditing {
            saveEditHeader.selectedCount -= 1
            return
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return SwipeAction.downloadQueueAndDeleteConfig(model: localPlaylists[indexPath.row]) {
            self.deleteLocalPlaylists(indexPaths: [indexPath])
        }
    }
}