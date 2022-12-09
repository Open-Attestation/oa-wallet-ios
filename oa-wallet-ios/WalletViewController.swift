//
//  WalletViewController.swift
//  oa-wallet-ios
//
//  Created by Tan Cher Shen on 2/12/22.
//

import UIKit
import UniformTypeIdentifiers

class WalletViewController: UIViewController {
    @IBOutlet weak var documentTableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    let reachability = try! Reachability()
    
    let oa = OpenAttestation()
    var oaDocuments: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Wallet"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importTapped))
        fetchDocuments()
        documentTableView.dataSource = self
        documentTableView.delegate = self
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func showLoadingIndicator() {
        loadingIndicatorView.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        loadingIndicatorView.isHidden = true
        loadingIndicator.stopAnimating()
    }
    
    func fetchDocuments() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            self.oaDocuments = fileURLs.filter({ url in
                UTType(filenameExtension: url.pathExtension) == .oa
            })
            print(self.oaDocuments)
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
    @objc func importTapped() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.oa], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)
    }
    
    func verifyDocument(url: URL) {
        guard let oaDocument = readDocument(url: url) else { return }
        showLoadingIndicator()
        oa.verifyDocument(view: self.view, oaDocument: oaDocument) { isValid in
            self.hideLoadingIndicator()
            let title = isValid ? "Verification successful" : "Verification failed"
            let message = isValid ? "This document is valid" : "This document has been tampered with"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func viewDocument(url: URL) {
        let fileName = url.lastPathComponent
        guard let oaDocument = readDocument(url: url) else { return }
        
        showLoadingIndicator()
        oa.verifyDocument(view: self.view, oaDocument: oaDocument) { isValid in
            self.hideLoadingIndicator()
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
    
    func deleteDocumentFromWallet(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error.localizedDescription)
        }
        fetchDocuments()
        documentTableView.reloadData()
    }
    
    func presentImportOptions(url: URL) {
        let fileName = url.lastPathComponent
        let alert = UIAlertController(title: fileName, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Save to wallet", style: .default , handler:{ (UIAlertAction) in
            let outputUrl = getDocumentsDirectory().appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(atPath: outputUrl.path) {
                let erroralert = UIAlertController(title: "Failed to import document", message: "\(fileName) already exists in your wallet.", preferredStyle: .alert)
                erroralert.addAction(.init(title: "Dismiss", style: .cancel))
                self.present(erroralert, animated: true, completion: nil)
                
                return
            }
            do {
                _ = url.startAccessingSecurityScopedResource()
                try FileManager.default.copyItem(at: url, to: outputUrl)
                url.stopAccessingSecurityScopedResource()
            } catch {
                print(error.localizedDescription)
            }
            self.fetchDocuments()
            self.documentTableView.reloadData()
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
    
    func presentDocumentOptions(url: URL) {
        let fileName = url.lastPathComponent
        let alert = UIAlertController(title: fileName, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Verify", style: .default , handler:{ (UIAlertAction) in
            self.verifyDocument(url: url)
        }))
        
        alert.addAction(UIAlertAction(title: "View", style: .default , handler:{ (UIAlertAction) in
            self.viewDocument(url: url)
        }))
        
        alert.addAction(UIAlertAction(title: "Share", style: .default , handler:{ (UIAlertAction) in
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (UIAlertAction) in
            self.deleteDocumentFromWallet(url: url)
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
        presentImportOptions(url: url)
    }
}

extension WalletViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return oaDocuments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = documentTableView.dequeueReusableCell(withIdentifier: "DocumentTableViewCell", for: indexPath) as! DocumentTableViewCell
        
        let url = oaDocuments[indexPath.row]
        let fileName = url.lastPathComponent
        cell.filenameLabel.text = fileName
        
        cell.onOptionsTapped = {
            self.presentDocumentOptions(url: url)
        }
        
        return cell
    }
}

extension WalletViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewDocument(url: oaDocuments[indexPath.row])
        documentTableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
}
