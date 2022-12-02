//
//  WalletViewController.swift
//  oa-wallet-ios
//
//  Created by Tan Cher Shen on 2/12/22.
//

import UIKit
import UniformTypeIdentifiers

class WalletViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Wallet"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importTapped))
    }
    
    @objc func importTapped() {
        guard let oadocUTType = UTType("com.openattestation.document") else { return }
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [oadocUTType], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)
    }
}

extension WalletViewController: UIDocumentPickerDelegate {
    
}
