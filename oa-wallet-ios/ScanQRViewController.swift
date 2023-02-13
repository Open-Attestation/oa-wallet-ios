//
//  ScanQRViewController.swift
//  oa-wallet-ios
//
//  Created by Tan Cher Shen on 11/2/23.
//

import AVFoundation
import UIKit
import OpenAttestationIOS

class ScanQRViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak var scannerView: UIView!
    
    let oa = OpenAttestation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = scannerView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        scannerView.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func found(code: String) {
        print(code)
        Task {
            guard let url = URL(string: code) else {
                let ac = UIAlertController(title: "Invalid QR code", message: "Please scan a compatible QR code.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.captureSession.startRunning()
                })
                present(ac, animated: true)
                return
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            if let response = response as? HTTPURLResponse {
                guard response.statusCode == 200 else {
                    let title = "Unable to download document!"
                    let message = "The QR code is no longer valid."
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel ){ _ in
                        self.captureSession.startRunning()
                    })
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
            guard let oaDocument = String(data: data, encoding: .utf8) else { return }
            oa.verifyDocument(oaDocument: oaDocument) { isValid in
                if isValid {
                    let rendererVC = OaRendererViewController(oaDocument: oaDocument)
                    rendererVC.title = "Document"
                    let navigationController = UINavigationController(rootViewController: rendererVC)
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true)
                }
                else {
                    let title = "Invalid document"
                    let message = "This document has been tampered with and cannot be displayed"
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel ){ _ in
                        self.captureSession.startRunning()
                    })
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension ScanQRViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
}
