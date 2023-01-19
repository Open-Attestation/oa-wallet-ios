# OpenAttestationIOS
The OpenAttestationIOS framework allows iOS app developers to build apps that can verify and view OpenAttestation documents

## Usage
### verifyDocument
`verifyDocument` takes a wrapped document and performs a [verifysignature](https://github.com/Open-Attestation/open-attestation#verify-signature-of-document) on it. A boolean indicating if the document is valid is returned as a parameter to the input completion handler.

```
    import OpenAttestationIOS
    
    ...
    
    let oa = OpenAttestation()
    oa.verifyDocument(oaDocument: oaDocument) { isValid in
        if (isValid) {
            // Document is valid
        }
    }
```
### OaRendererViewController
`OaRendererViewController` is a UIViewController that takes a wrapped document and renders the document template.
```
    import OpenAttestationIOS
    
    ...
    
    let rendererVC = OaRendererViewController(oaDocument: "<DOCUMENT CONTENT>")
    rendererVC.title = "<DOCUMENT NAME>"
    let navigationController = UINavigationController(rootViewController: rendererVC)
    navigationController.modalPresentationStyle = .fullScreen
    self.present(navigationController, animated: true)
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

OpenAttestationIOS is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'OpenAttestationIOS'
```

## Sample App
### OA Wallet iOS
A sample app that uses this framework to interact with OpenAttestation documents can be found on https://github.com/Open-Attestation/oa-wallet-ios

## License

OpenAttestationIOS is available under the Apache-2.0 license. See the LICENSE file for more info.
