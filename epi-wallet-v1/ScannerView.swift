//
//  ViewController.swift
//  epi-wallet-v1
//
//  Created by Pranav Singhal on 01/01/23.
//

import UIKit
import WebKit
import AVFoundation

class ScannerView: UIViewController, WKNavigationDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if (granted) {
                DispatchQueue.main.async {
                    self.captureSession = AVCaptureSession()
                    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                        print("error: you cannot access camera")
                        return
                    }
                    
                    let videoInput: AVCaptureDeviceInput
                    
                    do {
                        videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                    } catch {
                        print("error: your device cannot give video input")
                        return
                    }
                    
                    if (self.captureSession.canAddInput(videoInput)) {
                        self.captureSession.addInput(videoInput)
                    } else {
                        print("error: cannot input the capture session")
                        return
                    }
                    
                    let metadataOutput = AVCaptureMetadataOutput()
                    
                    if (self.captureSession.canAddOutput(metadataOutput)) {
                        self.captureSession.addOutput(metadataOutput)
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                    } else {
                        print("error: unable to add metadata output")
                        return
                    }
                    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                    self.previewLayer.frame  = self.view.layer.bounds
                    self.previewLayer.videoGravity = .resizeAspectFill
                    self.view.layer.addSublayer(self.previewLayer)
                    self.captureSession.startRunning()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // open homepage when the scanner is closed
        let url = URL(string: BASE_URL_WEB_WALLET)!
        webView?.load(URLRequest(url: url))
        
    }
    
    
    @IBAction func backToWebView(_ sender: UIButton) {
        NotificationCenter.default.post(name: .reload, object: nil, userInfo: ["urlString": "\(BASE_URL_WEB_WALLET)/send/new"])
        
        dismiss(animated: true)
    }
}

extension ScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let first = metadataObjects.first {
            guard let readableObject = first as? AVMetadataMachineReadableCodeObject else {
                print("error: object not readable")
                return
            }
            
            guard let stringValue = readableObject.stringValue else {
                print("cannot get string value of readable object")
                return
            }
            
            found(code: stringValue)
        } else {
            print("error: not able to read code. try again")
        }
    }
    
    func found(code: String) {
        print("Code string: \(code)")
        if (isEthereumAddressString(qrString: code)) {
            print("eth string found: \(code)")
        } else {
            let jsonData = code.data(using: .utf8)!
            
            let qrCodeObject: VendorQrModel = try! JSONDecoder().decode(VendorQrModel.self, from: jsonData)
            print(qrCodeObject.vendorName)
    
            NotificationCenter.default.post(name: .reload, object: nil, userInfo: ["urlString": "\(BASE_URL_WEB_WALLET)/transaction/new?QRId=\(String(qrCodeObject.QRId))&vendorName=\(qrCodeObject.vendorName)&amount=\(qrCodeObject.amount)"])
    
                dismiss(animated: true)

        }
        
    }
}

