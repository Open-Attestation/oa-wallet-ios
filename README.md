# oa-wallet-ios
The OA Wallet iOS app is a reference implementation of how iOS apps can handle [OpenAttestation](https://www.openattestation.com/) documents using the [OpenAttestationIOS](https://github.com/Open-Attestation/open-attestation-ios) framework.

## Features

- Associate `.oa` documents to be opened with the app [[How?]](https://github.com/Open-Attestation/oa-wallet-ios/wiki/How-to-associate-.oa-documents-to-your-app)
- Import `.oa` into the wallet
- Verify `.oa` documents
- View the rendered `.oa` document
- Generate QR Code for document [[Setup instructions]](https://github.com/Open-Attestation/oa-wallet-backend-example#installationdeployment-instructions)
- Scan OA Wallet QR Codes to view document


## Setup
This project uses [CocoaPods](https://cocoapods.org/), run the command in the project root directory:
```
pod install
``` 
and open the project using `oa-wallet-ios.xcworkspace`


## Sample OpenAttestation documents
You can find sample OA documents in the [Sample OA documents](https://github.com/Open-Attestation/oa-wallet-ios/tree/master/Sample%20OA%20documents) folder. These can be used with the sample app.


## License

oa-wallet-ios is available under the Apache-2.0 license. See the LICENSE file for more info.
