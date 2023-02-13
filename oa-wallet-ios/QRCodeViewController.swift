//
//  QRCodeViewController.swift
//  oa-wallet-ios
//
//  Created by Tan Cher Shen on 11/2/23.
//

import UIKit

class QRCodeViewController: UIViewController {
    @IBOutlet weak var qrImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func displayQRCode(for data: String) {
        if let image = generateQRCode(from: data) {
            self.qrImageView.image = image
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let QRFilter = CIFilter(name: "CIQRCodeGenerator") {
            QRFilter.setValue(data, forKey: "inputMessage")
            guard let QRImage = QRFilter.outputImage else {return nil}
            return UIImage(ciImage: QRImage)
        }
        return nil
    }
}
