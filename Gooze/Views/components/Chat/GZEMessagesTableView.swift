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
import DeepDiff

class GZEMessagesTableView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let cellIdentifier = "GZEMessageTableCell"

    let (messagesSignal, messagesObserver) = Signal<[GZEChatMessage], NoError>.pipe()
    var messagesDisposable: Disposable?

    let (topScrollSignal, topScrollSignalObserver) = Signal<Bool, NoError>.pipe()
    var isAtBottom: Bool {
        return self.contentOffset.y >= (self.contentSize.height - self.frame.size.height - GZEChatBubbleView.minSize)
    }

    private var messages = [GZEChatMessage]()
    private var lastContentOffset: CGFloat = 0


    // MARK: - init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(frame: CGRect, collectionViewLayout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        initialize()
    }

    init() {
        super.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        initialize()
    }
    
    func initialize() {
        log.debug("initializing \(self)")
        self.register(GZEMessageTableCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.delegate = self
        self.dataSource = self

        startObservingMessages()
    }

    // MARK - Scroll
    func scrollToBottom(animated: Bool){
        if self.numberOfSections == 0 {
            return
        }

        log.debug("scrolling to bottom")
        let lastCell = IndexPath(item: self.numberOfItems(inSection: 0) - 1, section: 0)
        self.scrollTo(indexPath: lastCell, animated: animated)
    }

    func scrollTo(indexPath: IndexPath, animated: Bool) {
        if self.numberOfSections <= indexPath.section {
            return
        }

        let numberOfItems = self.numberOfItems(inSection: indexPath.section)
        if (numberOfItems == 0) {
            return
        }

        let collectionViewContentHeight = self.collectionViewLayout.collectionViewContentSize.height
        let isContentTooSmall = collectionViewContentHeight < self.bounds.height

        if (isContentTooSmall) {
            //  workaround for the first few messages not scrolling
            //  when the collection view content size is too small, `scrollToItemAtIndexPath:` doesn't work properly
            //  this seems to be a UIKit bug, see #256 on GitHub
            self.scrollRectToVisible(
                CGRect(x: 0.0, y: collectionViewContentHeight - 1.0, width: 1.0, height: 1.0),
                animated:animated
            )
            return
        }

        let item = max(min(indexPath.item, numberOfItems - 1), 0);
        let indexPath = IndexPath(item: item, section: 0)

        //  workaround for really long messages not scrolling
        //  if last message is too long, use scroll position bottom for better appearance, else use top
        //  possibly a UIKit bug, see #480 on GitHub
        let cellSize = self.collectionView(self, layout: self.collectionViewLayout, sizeForItemAt: indexPath)
        let maxHeightForVisibleMessage = self.bounds.height
            - self.contentInset.top
            - self.contentInset.bottom
        let scrollPosition: UICollectionViewScrollPosition = (cellSize.height > maxHeightForVisibleMessage) ? .bottom : .top

        self.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }

    
    // MARK: - UICollectionViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y < GZEChatBubbleView.minSize {
            // Reaching top of the collection view
            if (self.lastContentOffset > scrollView.contentOffset.y) {
                // moving up
                topScrollSignalObserver.send(value: true)
            }
        }
        
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }


    // MARK: - UITableViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        
        guard let msgCell = cell as? GZEMessageTableCell else {
            log.error("Unable to cast cell to \(GZEMessageTableCell.self)")
            return cell
        }

        guard indexPath.row >= 0 && indexPath.row < self.messages.count else {
            log.error("Index path out of messages array bounds")
            return msgCell
        }
        
        msgCell.message = self.messages[indexPath.row]
        
        return msgCell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.size.width, height: calcCellHeight(indexPath: indexPath))
    }

    // MARK: - Helpers
    private func startObservingMessages() {

        self.messagesDisposable?.dispose()

        self.messagesDisposable = (
            self.messagesSignal
                .flatMap(.concat) { messages -> SignalProducer<([GZEChatMessage], Observer<Void, NoError>), NoError> in
                    log.debug("messages signal received")
                    let (signal, observer) = Signal<Void, NoError>.pipe()

                    return SignalProducer {sink, dispose in
                        dispose.add {
                            log.debug("messages signal disposed")
                        }
                        sink.send(value: (messages, observer))
                        }
                        .take(until: signal)

                }.observeValues {[weak self] (messages, observer) in
                    log.debug("messages value received: \(messages)")

                    guard let this = self else {return}

                    let atEndOfTable = this.isAtBottom
                    let firstCell = this.indexPathsForVisibleItems.sorted{$0.0.row < $0.1.row}.first

                    let changes = diff(old: this.messages, new: messages)
                    this.messages = messages

                    log.debug("Changes: \(changes)")

                    UIView.setAnimationsEnabled(false)
                    this.reload(changes: changes, section: 0) { _ in
                        observer.sendCompleted()
                    }

                    if atEndOfTable {
                        log.debug("At end of the table")
                        this.scrollToBottom(animated: false)
                    } else {
                        log.debug("firstCell.indexPath: \(String(describing: firstCell))")

                        if var firstCell = firstCell {
                            let initialRow = firstCell.row

                            changes.forEach{change in
                                if let insert = change.insert, insert.index <= firstCell.row {
                                    firstCell.row += 1
                                } else if let delete = change.delete, delete.index < firstCell.row {
                                    firstCell.row -= 1
                                }
                            }

                            if firstCell.row > initialRow {
                                firstCell.row -= 1
                            }
                            log.debug("firstCell indexPath: \(firstCell)")
                            this.scrollTo(indexPath: firstCell, animated: false)
                        }
                    }
                    UIView.setAnimationsEnabled(true)
            }
        )
    }
    
    private func calcCellHeight(indexPath: IndexPath) -> CGFloat {
        guard indexPath.row >= 0 && indexPath.row < self.messages.count else {return 0}

        let message = self.messages[indexPath.row]
        
        let minBubbleSize: CGFloat = GZEChatBubbleView.minSize
        let textHeight = ceil(message.localizedText().size(font: GZEChatBubbleView.font).height)
        let cellPadding = GZEChatBubbleView.labelPadding * 2 + GZEChatBubbleView.bubblePadding * 2
        
        return max(minBubbleSize, cellPadding + textHeight)
    }


    // MARK: - Deinitializer
    deinit {
        log.debug("\(self) disposed")
    }
}

class GZEMessageTableCell: UICollectionViewCell {

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
                self.bubble.text = message.localizedText()
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    init() {
        super.init(frame: CGRect.zero)
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
