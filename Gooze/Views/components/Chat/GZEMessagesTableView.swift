//
//  GZEMessagesTableView.swift
//  Gooze
//
//  Created by Yussel on 3/30/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import enum Result.NoError

class GZEMessagesTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "GZEMessageTableCell"
    let messages = MutableProperty<[GZEChatMessage]>([])
    let messagesEvents = MutableProperty<CollectionEvent?>(nil)
    var isObservingMessages = false
    var (topScrollSignal, topScrollSignalObserver) = Signal<Bool, NoError>.pipe()
    
    private var lastContentOffset: CGFloat = 0


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
            log.debug("scrolling to bottom")
            let indexPath = IndexPath(row: self.messages.value.count - 1, section: 0)
            self.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }


    // MARK: - private methods
    private func initialize() {
        log.debug("initializing \(self)")
        self.separatorStyle = .none
        self.register(GZEMessageTableCell.self, forCellReuseIdentifier: cellIdentifier)
        self.delegate = self
        self.dataSource = self

        startObservingMessages()
    }
    
    @objc private func startObservingMessages() {
        if isObservingMessages {
           return
        }
        
        isObservingMessages = true
        
        self.messagesEvents.signal.skipNil().observeValues {[weak self] event in
            guard let this = self else {return}
            
            let beforeContentSize = this.contentSize
            log.debug("messages event received: \(event)")
            
            log.debug("scroll content size: \(this.contentSize)")
            log.debug("scroll content offset: \(this.contentOffset)")
 
            let atEndOfTable = this.contentOffset.y >= (this.contentSize.height - this.frame.size.height - GZEChatBubbleView.minSize)
            
            UIView.setAnimationsEnabled(false)
            
            switch event {
            case .add(let at, let count):
                
                this.insertRows(at: (at..<(at + count)).map{IndexPath(row: $0, section: 0)}, with: UITableViewRowAnimation.automatic)
                this.layoutIfNeeded()

                if atEndOfTable {
                    log.debug("At end of the table")
                    this.scrollToBottom()
                } else {
                    //this.contentOffset = CGPoint(x: this.contentOffset.x, y: max(0, this.contentOffset.y + this.contentSize.height - beforeContentSize.height - GZEChatBubbleView.minSize))
                    DispatchQueue.main.async {
                        log.debug("scroll content size: \(this.contentSize)")
                        log.debug("scroll content offset: \(this.contentOffset)")
                        this.contentOffset.y = max(
                            0,
                            this.contentOffset.y +
                                this.contentSize.height -
                                beforeContentSize.height -
                                GZEChatBubbleView.minSize
                        )
                        UIView.setAnimationsEnabled(true)
                    }
                }
            case .remove(let at, let count):
                this.deleteRows(at: (at..<(at + count)).map{IndexPath(row: $0, section: 0)}, with: UITableViewRowAnimation.automatic)
            case .update(let at, let count):
                this.reloadRows(at: (at..<(at + count)).map{IndexPath(row: $0, section: 0)}, with: UITableViewRowAnimation.automatic)
            }
            
            
            
            log.debug("scroll content size: \(this.contentSize)")
            log.debug("scroll content offset: \(this.contentOffset)")
        }
    }


    // MARK: - UITableViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //log.debug("scrollview content size: \(scrollView.contentSize)")
        //log.debug("scrollview content offset: \(scrollView.contentOffset)")
        
        if scrollView.contentOffset.y < 40 {
            
            if (self.lastContentOffset > scrollView.contentOffset.y) {
                // moving up
                topScrollSignalObserver.send(value: true)
            }
        }
        
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calcCellHeight(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return calcCellHeight(indexPath: indexPath)
    }
    
    func calcCellHeight(indexPath: IndexPath) -> CGFloat {
        let message = self.messages.value[indexPath.row]
        
        let minBubbleSize: CGFloat = GZEChatBubbleView.minSize
        let textHeight = ceil(message.text.size(font: GZEChatBubbleView.font).height)
        let cellPadding = GZEChatBubbleView.labelPadding * 2 + GZEChatBubbleView.bubblePadding * 2
        
        return max(minBubbleSize, cellPadding + textHeight)
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

            if message.type == .info {
                self.messageType = .info
                self.infoLabel.text = message.localizedText()
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
        // log.debug("initializing \(self)")
        self.backgroundColor = .clear
        self.infoLabel.textColor = GZEConstants.Color.mainTextColor
        self.infoLabel.textAlignment = .center
        self.infoLabel.font = GZEChatBubbleView.font
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
        //log.debug("\(self) disposed")
    }
}
