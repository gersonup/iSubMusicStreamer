//
//  SwipeAction.swift
//  iSub
//
//  Created by Benjamin Baron on 11/11/20.
//  Copyright © 2020 Ben Baron. All rights reserved.
//

import UIKit

// TODO: Don't show actions for videos (song.isVideo == YES)
// TODO: Don't show download action when in offline mode
@objc class SwipeAction: NSObject {
    @objc static func downloadAndQueueConfig(_ model: TableCellModel) -> UISwipeActionsConfiguration {
        let config = UISwipeActionsConfiguration.init(actions: [download(model), queue(model)])
        config.performsFirstActionWithFullSwipe = false;
        return config;
    }
    
    @objc static func downloadQueueAndDeleteConfig(_ model: TableCellModel, deleteHandler: @escaping () -> ()) -> UISwipeActionsConfiguration {
        let config = UISwipeActionsConfiguration.init(actions: [download(model), queue(model), delete(handler: deleteHandler)])
        config.performsFirstActionWithFullSwipe = false;
        return config;
    }
    
    @objc static func download(_ model: TableCellModel) -> UIContextualAction {
        let action = UIContextualAction.init(style: .normal, title: "Download") { _, _, completionHandler in
            model.download()
            completionHandler(true)
        }
        action.backgroundColor = .systemBlue
        return action
    }
    
    @objc static func queue(_ model: TableCellModel) -> UIContextualAction {
        let action = UIContextualAction.init(style: .normal, title: "Queue") { _, _, completionHandler in
            model.queue()
            completionHandler(true)
        }
        action.backgroundColor = .systemGreen
        return action
    }
    
    @objc static func delete(handler: @escaping () -> ()) -> UIContextualAction {
        let action = UIContextualAction.init(style: .normal, title: "Delete") { _, _, completionHandler in
            handler()
            completionHandler(true)
        }
        action.backgroundColor = .systemRed
        return action
    }
}
