//
//  GZEChatCellModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/23/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

protocol GZEChatCellModel {
    var id: String {get}
    var user: GZEUserConvertible? {get}
    var title: String? {get}
    var preview: String? {get}
    var onClose: HandlerBlock<GZEChatsCollectionViewCell>? {get}
    var onTap: HandlerBlock<GZEChatsCollectionViewCell>? {get}
    var isBlocked: Bool {get}
    var isCloseShown: Bool {get}
}
