//
//  GZEChatViewController.swift
//  Gooze
//
//  Created by Yussel on 3/30/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZEChatViewController: UIViewController {

    var viewModel: GZEChatViewModel!

    @IBOutlet weak var topButton: GZEButton! {
        didSet {
            self.topButton.setGrayFormat()
        }
    }
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var messagesTableView: GZEMessagesTableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!

    override func viewDidLoad() {
        log.debug("\(self) init")
        super.viewDidLoad()

        GZESocketManager.createChatSocket()

        let recipient = GZEUser()
        recipient.id = "asdf"
        self.viewModel = GZEChatViewModelDates(mode: .client, recipient: recipient)

        self.messagesTableView.messages.value.append(GZEChatMessage(chatId: "12345", text: "dummy message", senderId: "123", recipientId: "123", status: .sent, createdAt: Date()))

        self.messagesTableView.messages.value.append(GZEChatMessage(chatId: "12345", text: "very large dummy messa gagas dg asd g asd gas dg asd ga sdg asd gas dg asdg ads ga dsg asd gas dg asdg asd g asdg gasdg g ds gas dg asdg asdg ", senderId: "myid", recipientId: "123", status: .sent,  createdAt: Date()))
        self.messagesTableView.messages.value.append(GZEChatMessage(chatId: "12345", text: "dummy message", senderId: "123", recipientId: "123", status: .sent, createdAt: Date()))

        self.messagesTableView.messages.value.append(GZEChatMessage(chatId: "12345", text: "very large dummy messa gagas dg asd g asd gas dg asd ga sdg asd gas dg asdg ads ga dsg asd gas dg asdg asd g asdg gasdg g ds gas dg asdg asdg ", senderId: "myid", recipientId: "123", status: .sent,  createdAt: Date()))
        self.messagesTableView.messages.value.append(GZEChatMessage(chatId: "12345", text: "dummy message", senderId: "123", recipientId: "123", status: .sent, createdAt: Date()))

        self.messagesTableView.messages.value.append(GZEChatMessage(chatId: "12345", text: "very large dummy messa gagas dg asd g asd gas dg asd ga sdg asd gas dg asdg ads ga dsg asd gas dg asdg asd g asdg gasdg g ds gas dg asdg asdg ", senderId: "myid", recipientId: "123", status: .sent,  createdAt: Date()))

        setupBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupBindings() {
        self.viewModel.inputMessage <~ self.messageTextView.reactive.continuousTextValues


        self.sendButton.reactive.pressed = self.viewModel.sendButtonAction
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Deinitializer
    deinit {
        log.debug("\(self) disposed")
    }

}
