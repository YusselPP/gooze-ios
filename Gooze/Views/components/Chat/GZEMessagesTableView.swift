//
//  GZEMessagesTableView.swift
//  Gooze
//
//  Created by Yussel on 3/30/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift

class GZEMessagesTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "GZEMessageTableCell"
    let messages = MutableProperty<[GZEChatMessage]>([])

    // MARK: - init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        initialize()
    }

    init() {
        super.init(frame: CGRect.zero, style: .plain)
        initialize()
    }


    // MARK: - private methods
    private func initialize() {
        log.debug("initializing \(self)")
        self.separatorStyle = .none
        self.register(GZEMessageTableCell.self, forCellReuseIdentifier: cellIdentifier)
        self.delegate = self
        self.dataSource = self

        self.messages.signal.observeValues {[weak self] messages in
            // TODO: reload only changes
            log.debug("messages changed, reloading table data")
            self?.reloadData()
        }
    }


    // MARK: - UITableViewDelegate


    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath)

        guard let msgCell = cell as? GZEMessageTableCell else {
            log.debug("unable to cast cell to \(GZEMessageTableCell.self)")
            return cell
        }

        msgCell.message = self.messages.value[indexPath.row]

        return msgCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.value.count
    }


    // MARK: - Deinitializer
    deinit {
        log.debug("\(self) disposed")
    }
}

class GZEMessageTableCell: UITableViewCell {

    var message: GZEChatMessage? {
        didSet {
            guard let message = self.message else {
                log.debug("nil chat message set")
                self.messageType = .invalid
                return
            }

            if message.isInfo {
                self.messageType = .info
                self.infoLabel.text = message.text
            } else if message.sent(by: GZEAuthService.shared.authUser?.id) {
                self.messageType = .sent
                self.bubble.text = message.text
            } else if message.hasRecipient {
                self.messageType = .received
                self.bubble.text = message.text
            } else {
                log.debug("Invalid message: \(String(describing: message.toJSON()))")
                self.messageType = .invalid
            }
        }
    }

    enum MessageType {
        case sent
        case received
        case info

        case invalid
    }

    var messageType: MessageType = .invalid {
        didSet { applyStyle() }
    }

    let bubble = GZEChatBubbleView()
    let infoLabel = GZELabel()

    // MARK: init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }

    init() {
        super.init(style: .default, reuseIdentifier: "GZEMessageTableCell")
        initialize()
    }


    // MARK: private methods
    private func initialize() {
        log.debug("initializing \(self)")
        self.backgroundColor = .clear
        self.infoLabel.textColor = GZEConstants.Color.mainTextColor
        self.infoLabel.textAlignment = .center
        self.addSubview(self.bubble)
        self.addSubview(self.infoLabel)

        self.bubble.translatesAutoresizingMaskIntoConstraints = false
        self.infoLabel.translatesAutoresizingMaskIntoConstraints = false

        self.topAnchor.constraint(equalTo: self.bubble.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.bubble.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.bubble.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.bubble.trailingAnchor).isActive = true

        self.topAnchor.constraint(equalTo: self.infoLabel.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.infoLabel.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.infoLabel.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.infoLabel.trailingAnchor).isActive = true
    }

    private func applyStyle() {
        self.clear()

        switch self.messageType {
        case .sent:
            self.bubble.style = .sent
            self.bubble.alpha = 1
        case .received:
            self.bubble.style = .received
            self.bubble.alpha = 1
        case .info:
            self.infoLabel.alpha = 1
        case .invalid: break
        }
    }

    private func clear() {
        self.bubble.alpha = 0
        self.infoLabel.alpha = 0
    }


    // MARK: - Deinitializer
    deinit {
        log.debug("\(self) disposed")
    }
}
