//
//  ViewController.swift
//  ObjectDetection
//
//  Created by Furkan Hanci on 9/18/20.
//

import UIKit
import AVKit
import CoreML
import Vision

class ViewController: UIViewController  , AVCaptureVideoDataOutputSampleBufferDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDvice = AVCaptureDevice.default(for: .video) else { return }
        
        guard  let input = try? AVCaptureDeviceInput(device: captureDvice) else { return }
        
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)
        
        previewLayer.frame = view.frame
        
        let dataOutPut = AVCaptureVideoDataOutput()
        dataOutPut.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutPut)
        
        
   
        
       // VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
        
    }

    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
       // print("Camera was able to capture a frame:" , Date())
        
        guard let  pixelBUffer : CVPixelBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        
        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finish, error) in
            
           // print(finish.results)
            
            guard let results = finish.results as? [VNClassificationObservation] else { return }
            
            guard let  firstObservation = results.first else { return }
            
            print(firstObservation.identifier , firstObservation.confidence)
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBUffer, options: [:]).perform([request])
    }

}

