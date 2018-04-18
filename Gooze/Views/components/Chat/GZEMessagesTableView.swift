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
    var isObservingMessages = false

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
    
    func scrollToBottom(){
        if self.messages.value.count > 0 {
            //DispatchQueue.main.async { [weak self] in
                //guard let this = self else {return}
                let indexPath = IndexPath(row: self.messages.value.count-1, section: 0)
                self.scrollToRow(at: indexPath, at: .bottom, animated: false)
            //}
        }
    }


    // MARK: - private methods
    private func initialize() {
        log.debug("initializing \(self)")
        self.separatorStyle = .none
        self.register(GZEMessageTableCell.self, forCellReuseIdentifier: cellIdentifier)
        self.delegate = self
        self.dataSource = self
        
        // Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startObservingMessages), userInfo: nil, repeats: false)
        startObservingMessages()
    }
    
    @objc private func startObservingMessages() {
        if isObservingMessages {
           return
        }
        
        isObservingMessages = true
        
        self.messages.producer.startWithValues {[weak self] messages in
            // TODO: reload only changes
            guard let this = self else {return}
            //log.debug("messages changed: \(String(describing: messages.toJSONArray()))")
            let numberOfRows = this.numberOfRows(inSection: 0)
            let numberOfMessages = messages.count
            
            log.debug("number of rows: \(numberOfRows)")
            log.debug("number of messages: \(messages.count)")
            
            if numberOfMessages > numberOfRows {
                this.insertRows(at: (numberOfRows..<numberOfMessages).map{IndexPath(row: $0, section: 0)}, with: UITableViewRowAnimation.none)
                this.scrollToBottom()
            } else if numberOfMessages < numberOfRows {
                // TODO: delete rows
            }
        }
    }


    // MARK: - UITableViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 40 {
            // log.debug("scroll top limit reached. Requesting older messages")
            
            // retrieveHistory(offset: self.messages.value.count + 20, limit: 20)
        }
    }


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
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        log.debug("willDisplay cell at indexPath: \(indexPath)")
//
//        if let lastVisibleRow = tableView.indexPathsForVisibleRows?.last?.row, indexPath.row == lastVisibleRow {
//            log.debug("last row will display")
//            // startObservingMessages()
//        }
//    }
    
    


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

            if message.type == .info {
                self.messageType = .info
                self.infoLabel.text = message.text
            } else if message.type == .user {
                if message.sent(by: GZEAuthService.shared.authUser?.toChatUser()) {
                    self.messageType = .sent
                } else {
                    self.messageType = .received
                }
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
