//
//  GZEChatsViewController.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/21/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZEChatsViewController: UIViewController {

    let segueToChat = "segueToChat"

    var viewModel: GZEChatsViewModel!

    let backButton = GZEBackUIBarButtonItem()
    let chatsCollectionView = GZEChatsCollectionView()
    // let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    @IBOutlet weak var chatListContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupInterfaceObjects()
        self.setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.viewWillAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewModel.viewDidDisappear()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects() {
        self.backButton.onButtonTapped = {[weak self] _ in
            self?.previousController(animated: true)
        }
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = GZEExitAppButton.shared

        // ChatsCollectionView
        self.chatsCollectionView.backgroundColor = .clear
        self.chatsCollectionView.alwaysBounceVertical = true

        self.chatListContainer.addSubview(self.chatsCollectionView)

        // ChatsCollectionView Constraints
        self.chatsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.chatListContainer.leadingAnchor.constraint(equalTo: self.chatsCollectionView.leadingAnchor).isActive = true
        self.chatListContainer.topAnchor.constraint(equalTo: self.chatsCollectionView.topAnchor).isActive = true
        self.chatListContainer.trailingAnchor.constraint(equalTo: self.chatsCollectionView.trailingAnchor).isActive = true
        self.chatListContainer.bottomAnchor.constraint(equalTo: self.chatsCollectionView.bottomAnchor).isActive = true
    }

    func setupBindings() {
        // Producers
        self.navigationItem.reactive.title <~ self.viewModel.title
        self.chatsCollectionView.reactive.cells <~ self.viewModel.chatsList
        self.viewModel.error.producer.skipNil().startWithValues{
            GZEAlertService.shared.showBottomAlert(text: $0)
        }

        // Signals
        self.viewModel.loading.signal.skipRepeats().observeValues{[weak self] loading in
            guard let this = self else {return}
            if loading {
                this.chatListContainer.showWaitIndicator()
            } else {
                this.chatListContainer.removeWaitIndicator()
            }
        }

        self.viewModel.dismiss.signal.observeValues{[weak self] in
            self?.previousController(animated: true)
        }

        self.viewModel.segueToChat.signal.observeValues{[weak self] chatViewModel in
            guard let this = self else {return}
            this.performSegue(withIdentifier: this.segueToChat, sender: chatViewModel)
        }

        // Actions

    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == segueToChat {
            self.prepareChatSegue(segue.destination, vm: sender)
        }
    }

    func prepareChatSegue(_ vc: UIViewController, vm: Any?) {
        guard let vc = vc as? GZEChatViewController else {
            log.error("Unable to cast segue.destination as? GZEChatViewController")
            return
        }

        guard let vm = vm as? GZEChatViewModelDates else {
            log.error("Unable to cast sender as? GZEChatViewModelDates")
            return
        }

        vc.viewModel = vm
    }

    // MARK: - deinit
    deinit {
        log.debug("\(self) disposed")
    }
}
