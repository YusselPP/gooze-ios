//
//  GZECheckListViewController.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZECheckListViewController: UIViewController {

    var viewModel: GZECheckListViewModel!
    weak var dismissDelegate: GZEDismissVCDelegate?

    @IBOutlet weak var checkList: GZECheckListCollectionView!

    override func viewDidLoad() {
        log.debug("\(self) init")
        super.viewDidLoad()

        setupInterfaceObjects()
        setupBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects() {
        // nav
        let backButton = GZEBackUIBarButtonItem()
        backButton.onButtonTapped = {[weak self] _ in
            guard let this = self else {return}
            this.dismissDelegate?.onDismissTapped(this)
        }

        navigationItem.leftBarButtonItem = backButton
    }

    func setupBindings() {
        navigationItem.reactive.title <~ viewModel.title.map{$0?.capitalizingFirstLetter()}

        // checkList
        DispatchQueue.main.async {[weak self] in
            guard let this = self else {return}
            this.checkList.reactive.cells <~ this.viewModel.items
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    deinit {
        log.debug("\(self) disposed")
    }
}
