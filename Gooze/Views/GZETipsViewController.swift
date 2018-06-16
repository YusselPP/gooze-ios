//
//  GZETipsViewController.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/26/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZETipsViewController: UIViewController {

    let stackView = UIStackView()
    let backButton = GZECloseUIBarButtonItem()

    let tips = [
        "Lorem ipsum dolor sit amet, coctetuer adipiscing elit, sed diam nonum",
        "Lorem ipsum dolor sit amet, coctetuer adipiscing elit, sed diam nonum dolor sit amet, coctetuer adipiscing elit, sed diam nonum",
        "Lorem ipsum dolor sit amet, coctetuer adipiscing elit, sed diam nonum",
        "Lorem ipsum dolor sit amet, coctetuer adipiscing elit, sed diam nonum dolor sit amet, coctetuer adipiscing elit, sed diam nonum",
        "Lorem ipsum dolor sit amet, coctetuer adipiscing elit, sed diam nonum",
    ]

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInterfaceObjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects() {
        self.navigationItem.rightBarButtonItem = GZEExitAppButton.shared
        self.navigationItem.leftBarButtonItem = self.backButton

        self.backButton.onButtonTapped = {[weak self] _ in
            self?.previousController(animated: true)
        }

        self.stackView.axis = .vertical
        self.stackView.alignment = .center
        self.stackView.distribution = .fill
        self.stackView.spacing = 10

        self.scrollView.addSubview(self.stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: self.stackView.topAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor).isActive = true
        self.contentView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true

        for (index, tip) in tips.enumerated() {
            if index > 0 {
                let separator = self.createSeparator()
                self.stackView.addArrangedSubview(separator)
                self.stackView.widthAnchor.constraint(equalTo: separator.widthAnchor, multiplier: 5).isActive = true
            }
            let label = self.createTipLabel(tip)
            self.stackView.addArrangedSubview(label)
            self.stackView.widthAnchor.constraint(equalTo: label.widthAnchor, multiplier: 1.5).isActive = true
        }
    }

    func createTipLabel(_ text: String) -> UILabel {
        let tipLabel = GZELabel()
        tipLabel.setWhiteFontFormat()
        tipLabel.font = GZEConstants.Font.mainBig
        tipLabel.text = text
        tipLabel.numberOfLines = 0
        tipLabel.translatesAutoresizingMaskIntoConstraints = false

        return tipLabel
    }

    func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .white
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

        return separator
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
