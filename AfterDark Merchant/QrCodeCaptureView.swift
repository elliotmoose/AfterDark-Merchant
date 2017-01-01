//
//  QrCodeCaptureView.swift
//  AfterDark
//
//  Created by Koh Yi Zhi Elliot - Ezekiel on 6/12/16.
//  Copyright © 2016 kohbroco. All rights reserved.
//

import UIKit
import AVFoundation

protocol QrCodeViewDelegate : class{
    func QrCodeCaptured(output : String)
}

class QrCodeCaptureView: UIView , AVCaptureMetadataOutputObjectsDelegate {
    
    
    //displaying
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?

    var qrCodeFrameView:UIView?
    
    //capturing
    var captureDevice : AVCaptureDevice?
    
    var captureSession : AVCaptureSession?
    
    //outputs
    let output = AVCaptureMetadataOutput()

    weak var delegate : QrCodeViewDelegate?     //call this when finished reading QR code
    
    //initializing
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        Initialize()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func Initialize()
    {

        //==================================================================================================
        //                                      init qr code reading device
        //==================================================================================================
        //                              init: device -> input -> output -> session
        
        //device
        InitCaptureDevice()
        
        //input output
        let input = InitCaptureDeviceInput()
        let output = InitCaptureDeviceOutput()

        //check for input before adding
        guard input != nil else {NSLog("cant initialize capture device input");return}
        
        //session
        InitCaptureSession(input: input!, output: output)
        

        
        //==================================================================================================
        //                                      init camera display
        //==================================================================================================
        InitPreviewDisplay()

    }
    
    private func InitCaptureDevice()
    {
        //init capture device as a video device
        captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    }
    
    private func InitCaptureDeviceInput() -> AVCaptureDeviceInput?
    {
        //init input
        var input : AVCaptureDeviceInput?
        do {input = try AVCaptureDeviceInput(device: self.captureDevice)}
        catch let error as NSError {NSLog(error.localizedDescription)}
        
        return input
    }
    
    private func InitCaptureDeviceOutput() -> AVCaptureMetadataOutput
    {
        //init output
        let captureMetadataOutput = AVCaptureMetadataOutput()

        return captureMetadataOutput
    }
    private func InitCaptureSession(input : AVCaptureDeviceInput, output : AVCaptureMetadataOutput)
    {
        //init capture session
        captureSession = AVCaptureSession()
        
        // Set the input device on the capture session.
        captureSession?.addInput(input as AVCaptureInput)
        
        // Set the output device on the capture session.
        captureSession?.addOutput(output)
        
        
        //these must be done after adding it as an output
        // Set delegate and queue for callback
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        //set metadata type to lookout for (during video capture)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
    }
    
    private func InitPreviewDisplay()
    {
        self.backgroundColor = UIColor.black
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = self.layer.bounds
        self.layer.addSublayer(videoPreviewLayer!)
        
        //highlights QR code
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView?.layer.borderWidth = 2
        self.addSubview(qrCodeFrameView!)
        self.bringSubview(toFront: qrCodeFrameView!)
    }
    
    //==================================================================================================
    //                                      public functions
    //==================================================================================================
    
    func BeginScan()
    {
        captureSession?.startRunning()
    }
    
    func StopScan()
    {
        captureSession?.stopRunning()
    }
    
    //==================================================================================================
    //                                      output functions
    //==================================================================================================
    
    //delegate function from AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            NSLog("cant find QR code")
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                let output = metadataObj.stringValue
                //******OUTPUT******
                self.OutputQrCode(output: output!)
            
            }
        }
    }
    
    private func OutputQrCode(output : String)
    {
        self.delegate?.QrCodeCaptured(output: output)
    }
}
