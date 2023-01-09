//
//  OpenAttestation.swift
//  oa-wallet-ios
//
//  Created by Tan Cher Shen on 5/12/22.
//

import UIKit
import WebKit

public typealias verifyDocumentHandler = (_ isValid: Bool) -> Void
public class OpenAttestation: NSObject {
    var oaDocument: String?
    var completion: verifyDocumentHandler?
    var webView: WKWebView!
    
    /// verifyDocument takes a wrapped document and performs a verifysignature on it. A boolean indicating if the document is valid is returned to the input completion handler.
    ///
    /// Use this method to check if the wrapped document is valid.
    ///
    ///     let oa = OpenAttestation()
    ///     oa.verifyDocument(oaDocument: oaDocument) { isValid in
    ///     if (isValid) {
    ///             // Document is valid
    ///         }
    ///     }
    ///
    /// - Parameter oaDocument: The wrapped OpenAttestation document.
    /// - Parameter completion: A closure with a boolean isValid parameter that states if the input oaDocument is valid
    public func verifyDocument(oaDocument: String, completion: @escaping verifyDocumentHandler) {
        self.oaDocument = oaDocument
        self.completion = completion

        let frameworkBundle = Bundle(for: OpenAttestation.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("OpenAttestationIOS.bundle")
        guard let resourceBundle = Bundle(url: bundleURL!) else {
            debugPrint("Resource bundle for OpenAttestationIOS.bundle not found")
            return
        }
        guard let path = resourceBundle.path(forResource: "oabundle", ofType: "js") else {
            debugPrint("oabundle.js not found")
            return
        }
        
        guard let jsSource = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
            debugPrint("oabundle.js cannot be loaded")
            return
        }
        
        let userScript = WKUserScript(source: jsSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        webView.loadHTMLString("<html><head></head><body></body></html>", baseURL: nil)
    }
}

extension OpenAttestation: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let oaDocument = self.oaDocument else { return }
        let scriptSource = "verifySignature(\(oaDocument));"
        
        webView.evaluateJavaScript(scriptSource, completionHandler: { (result, error) in
            if let error = error {
                debugPrint(error)
                self.completion?(false)
            }
            
            if let result = result as? Bool {
                self.completion?(result)
            }
        })
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint(error)
    }
}
