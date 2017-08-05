//
//  CameraVC.swift
//  whatsThat
//
//  Created by Olteanu Andrei on 04/08/2017.
//  Copyright © 2017 Olteanu Andrei. All rights reserved.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController {

    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // STORYBOARD
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var captureImageView: UIImageViewX!
    @IBOutlet weak var cameraView: UIView!
    
    // GRADIENT ANIMATION
    @IBOutlet weak var headerView: UIViewX!
    var colorArray: [(color1: UIColor, color2: UIColor)] = []
    var currentCollorArrayIndex = -1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // COLORS FOR THE ANIMATION
        colorArray.append((color1: #colorLiteral(red: 0.2591436505, green: 0.6219938397, blue: 0.8805219531, alpha: 1) , color2: #colorLiteral(red: 0.4490969181, green: 0.7435027957, blue: 0.804695785, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.4490969181, green: 0.7435027957, blue: 0.804695785, alpha: 1) , color2: #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1) , color2: #colorLiteral(red: 0.5110332966, green: 0.2250769734, blue: 0.5661664605, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.5110332966, green: 0.2250769734, blue: 0.5661664605, alpha: 1) , color2: #colorLiteral(red: 0.3763405979, green: 0.3311273456, blue: 0.6556733251, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.3763405979, green: 0.3311273456, blue: 0.6556733251, alpha: 1) , color2: #colorLiteral(red: 0.2509262264, green: 0.4745180011, blue: 0.7170872092, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.2509262264, green: 0.4745180011, blue: 0.7170872092, alpha: 1) , color2: #colorLiteral(red: 0.6168116927, green: 0.2149784267, blue: 0.2845455408, alpha: 1)))
        animateHeaderView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        previewLayer.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        //let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            
            cameraOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(cameraOutput) == true {
                captureSession.addOutput(cameraOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                cameraView.layer.addSublayer(previewLayer)
                captureSession.startRunning()
                
            }
        } catch {
            debugPrint(error)
        }
        
    }
    
    // ANIMATING THE HEADER VIEW
    func animateHeaderView() {
        currentCollorArrayIndex = currentCollorArrayIndex == (colorArray.count - 1) ? 0 : currentCollorArrayIndex + 1
        
        UIView.transition(with: headerView, duration: 5, options: [.transitionCrossDissolve], animations: {
            
            self.headerView.firstColor = self.colorArray[self.currentCollorArrayIndex].color1
            self.headerView.secondColor = self.colorArray[self.currentCollorArrayIndex].color2
            
        }) { (success) in
            self.animateHeaderView()
        }
    }

    
    
    
}

