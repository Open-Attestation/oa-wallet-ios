//
//  WalletViewController.swift
//  oa-wallet-ios
//
//  Created by Tan Cher Shen on 2/12/22.
//

import UIKit
import UniformTypeIdentifiers

class WalletViewController: UIViewController {
    let oa = OpenAttestation()
    
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
    
    func verifyDocument(url: URL) {
        do {
            let oaDocument = try String(contentsOf: url, encoding: .utf8)
            
            oa.verifyDocument(view: self.view, oaDocument: oaDocument) { isValid in
                let title = isValid ? "Verification successful" : "Verification failed"
                let message = isValid ? "This document is valid" : "This document has been tampered with"
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        catch {/* error handling here */}
    }
    
    func viewDocument(url: URL) {
        do {
            let fileName = url.lastPathComponent
            let oaDocument = try String(contentsOf: url, encoding: .utf8)
            
            oa.verifyDocument(view: self.view, oaDocument: oaDocument) { isValid in
                
                if isValid {
                    let rendererVC = OaRendererViewController(oaDocument: oaDocument)
                    rendererVC.title = fileName
                    let navigationController = UINavigationController(rootViewController: rendererVC)
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true)
                }
                else {
                    let title = "Invalid document"
                    let message = "This document has been tampered with and cannot be displayed"
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            
            
        }
        catch {/* error handling here */}
    }
    
    func presentImportActions(url: URL) {
        let fileName = url.lastPathComponent
        let alert = UIAlertController(title: fileName, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Save to wallet", style: .default , handler:{ (UIAlertAction) in
            let outputUrl = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                try _ = FileManager.default.replaceItemAt(outputUrl, withItemAt: url)
            } catch {
                print(error.localizedDescription)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Verify", style: .default , handler:{ (UIAlertAction) in
            self.verifyDocument(url: url)
        }))
        
        alert.addAction(UIAlertAction(title: "View", style: .default , handler:{ (UIAlertAction) in
            self.viewDocument(url: url)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction) in
            
        }))
        
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: {
            
        })
    }
}

extension WalletViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        presentImportActions(url: url)
    }
}
