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
    
    public func verifyDocument(oaDocument: String, completion: @escaping verifyDocumentHandler) {
        self.oaDocument = oaDocument
        self.completion = completion

        let frameworkBundle = Bundle(for: OpenAttestation.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("OpenAttestationIOS.bundle")
        guard let resourceBundle = Bundle(url: bundleURL!) else {
            print("Resource bundle for OpenAttestationIOS.bundle not found")
            return
        }
        guard let path = resourceBundle.path(forResource: "oabundle", ofType: "js") else {
            print("oabundle.js not found")
            return
        }
        
        guard let jsSource = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
            print("oabundle.js cannot be loaded")
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
                print(error)
            }
            
            if let result = result as? Bool {
                print(result)
                self.completion?(result)
                
            }
        })
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    

}
