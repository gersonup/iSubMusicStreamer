//
//  ServerPlaylistsLoader.swift
//  iSub
//
//  Created by Benjamin Baron on 1/11/21.
//  Copyright © 2021 Ben Baron. All rights reserved.
//

import Foundation
import Resolver

final class ServerPlaylistsLoader: AbstractAPILoader {
    @Injected private var store: Store
    
    let serverId: Int
    
    private(set) var serverPlaylists = [ServerPlaylist]()
    
    init(serverId: Int, delegate: APILoaderDelegate? = nil, callback: LoaderCallback? = nil) {
        self.serverId = serverId
        super.init(delegate: delegate, callback: callback)
    }
    
    // MARK: APILoader Overrides
    
    override var type: APILoaderType { .serverPlaylists }
    
    override func createRequest() -> URLRequest? {
        URLRequest(serverId: serverId, subsonicAction: "getPlaylists")
    }
    
    override func processResponse(data: Data) {
        let root = RXMLElement(fromXMLData: data)
        if !root.isValid {
            informDelegateLoadingFailed(error: NSError(ismsCode: Int(ISMSErrorCode_NotXML)))
        } else {
            if let error = root.child("error"), error.isValid {
                informDelegateLoadingFailed(error: NSError(subsonicXMLResponse: error))
            } else {
                serverPlaylists.removeAll()
                root.iterate("playlists.playlist") { e in
                    let serverPlaylist = ServerPlaylist(serverId: self.serverId, element: e)
                    if self.store.add(serverPlaylist: serverPlaylist) {
                        self.serverPlaylists.append(serverPlaylist)
                    }
                }
                informDelegateLoadingFinished()
            }
        }
    }
}
