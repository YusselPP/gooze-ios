//
//  GZEChatCellModelDates.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/23/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEChatCellModelDates: NSObject, GZEChatCellModel {
    let id: String
    let user: GZEUserConvertible?
    let title: String?
    let preview: String?
    let onClose: HandlerBlock<GZEChatsCollectionViewCell>?
    let onTap: HandlerBlock<GZEChatsCollectionViewCell>?
    let isBlocked: Bool
    let isCloseShown: Bool

    init(
        id: String,
        user: GZEUserConvertible? = nil,
        title: String? = nil,
        preview: String? = nil,
        onClose: HandlerBlock<GZEChatsCollectionViewCell>? = nil,
        onTap: HandlerBlock<GZEChatsCollectionViewCell>? = nil,
        isBlocked: Bool = false,
        isCloseShown: Bool = false
    ) {
        self.id = id
        self.user = user
        self.title = title
        self.preview = preview
        self.onClose = onClose
        self.onTap = onTap
        self.isBlocked = isBlocked
        self.isCloseShown = isCloseShown
    }
}

// MARK: Hashable
extension GZEChatCellModelDates {
//    static func == (lhs: GZEChatCellModelDates, rhs: GZEChatCellModelDates) -> Bool {
//        return lhs.id === rhs.id
//    }

    override var hashValue: Int {
        return self.id.hashValue
    }
}
