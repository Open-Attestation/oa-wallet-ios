//
//  OaRendererViewController.swift
//  oa-wallet-ios
//
//  Created by Tan Cher Shen on 5/12/22.
//

import UIKit
import WebKit

/// OaRendererViewController is a UIViewController that takes a wrapped document and renders the document template if the provided document is valid.
///
/// Use this ViewController to render the document template
///
///     let rendererVC = OaRendererViewController(oaDocument: oaDocument)
///     rendererVC.title = "<DOCUMENT NAME>"
///     let navigationController = UINavigationController(rootViewController: rendererVC)
///     navigationController.modalPresentationStyle = .fullScreen
///     self.present(navigationController, animated: true)
///
/// - Parameter oaDocument: The wrapped OpenAttestation document.
public class OaRendererViewController: UIViewController {
    enum LoadingState {
        case loading, complete
    }
    
    let oaDocument: String
    var webView: WKWebView!
    var loadingState: LoadingState = .loading
    
    public init(oaDocument: String) {
        self.oaDocument = oaDocument
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeTapped))
        
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
        
        webView = WKWebView(frame: self.view.frame, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.loadHTMLString("<html><head></head><body></body></html>", baseURL: nil)
    }
    
    @objc func closeTapped() {
        dismiss(animated: true)
    }
}

extension OaRendererViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        switch self.loadingState {
        case .loading:
            let getDataScript = "getData(\(oaDocument));"
            
            webView.evaluateJavaScript(getDataScript, completionHandler: { (document, error) in
                if let error = error {
                    print(error)
                }
                
                guard let document = document as? [String: Any] else { return }
                guard let template = document["$template"] as? [String: Any] else { return }
                guard let templateUrl = template["url"] as? String else { return }
                
                let frameworkBundle = Bundle(for: OpenAttestation.self)
                let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("OpenAttestationIOS.bundle")
                guard let resourceBundle = Bundle(url: bundleURL!) else {
                    print("Resource bundle for OpenAttestationIOS.bundle not found")
                    return
                }
                guard let path = resourceBundle.path(forResource: "oarenderer", ofType: "html") else {
                    print("oarenderer.html not found")
                    return
                }
                
                guard var rendererHtml = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
                    print("oarenderer.html cannot be loaded")
                    return
                }
                
                rendererHtml = rendererHtml.replacingOccurrences(of: "<TEMPLATE_RENDERER_URL>", with: templateUrl)
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document)
                    let jsonStr = String(data: jsonData,
                                         encoding: .utf8)
                    if let jsonStr = jsonStr {
                        rendererHtml = rendererHtml.replacingOccurrences(of: "<OA_DOCUMENT>", with: jsonStr)
                    }
                } catch {
                    print(error.localizedDescription)
                }
                webView.loadHTMLString(rendererHtml, baseURL: nil)
                self.loadingState = .complete
            })
        case .complete:
            break
        }
    }
}
