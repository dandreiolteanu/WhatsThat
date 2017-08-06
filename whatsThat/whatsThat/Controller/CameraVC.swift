//
//  CameraVC.swift
//  whatsThat
//
//  Created by Olteanu Andrei on 04/08/2017.
//  Copyright © 2017 Olteanu Andrei. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision
import NVActivityIndicatorView

enum FlashState {
    case off
    case on
}

@available(iOS 11.0, *)
class CameraVC: UIViewController {
    
    var speechSynthesizer = AVSpeechSynthesizer()
    
    var flashControlState: FlashState = .off
    
    var photoData: Data?
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // STORYBOARD
    @IBOutlet weak var spinner: NVActivityIndicatorView!
    @IBOutlet weak var flashBtnLbl: UILabel!
    @IBOutlet weak var percentLbl: UILabel!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var confidenceLbl: SACountingLabel!
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var captureImageView: UIImageViewX!
    @IBOutlet weak var cameraView: UIView!
    
    // GRADIENT ANIMATION
    
    @IBOutlet weak var headerView: UIViewX!
    var colorArray: [(color1: UIColor, color2: UIColor)] = []
    var flashONColorArray: [(color1: UIColor, color2: UIColor)] = []
    var currentFlashONColorArrayIndex = -1
    var currentColorArrayIndex = -1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechSynthesizer.delegate = self
        
        // COLORS FOR THE ANIMATION
        colorArray.append((color1: #colorLiteral(red: 0.2591436505, green: 0.6219938397, blue: 0.8805219531, alpha: 1) , color2: #colorLiteral(red: 0.4490969181, green: 0.7435027957, blue: 0.804695785, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.4490969181, green: 0.7435027957, blue: 0.804695785, alpha: 1) , color2: #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1) , color2: #colorLiteral(red: 0.5110332966, green: 0.2250769734, blue: 0.5661664605, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.5110332966, green: 0.2250769734, blue: 0.5661664605, alpha: 1) , color2: #colorLiteral(red: 0.3763405979, green: 0.3311273456, blue: 0.6556733251, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.3763405979, green: 0.3311273456, blue: 0.6556733251, alpha: 1) , color2: #colorLiteral(red: 0.2509262264, green: 0.4745180011, blue: 0.7170872092, alpha: 1)))
        animateHeaderView()
        
        confidenceLbl.countFrom(fromValue: 50, to: 0, withDuration: 2, andAnimationType: .EaseOut, andCountingType: .Int)
        
        spinner.type = NVActivityIndicatorType.ballGridPulse
    }
    /*
     *    // ANIMATING THE HEADER VIEW
     */
    
    func animateHeaderView() {
        currentColorArrayIndex = currentColorArrayIndex == (colorArray.count - 1) ? 0 : currentColorArrayIndex + 1
        // SETTING THE DURATION OF THE ANIMATION FROM HERE
        UIView.transition(with: headerView, duration: 7, options: [.transitionCrossDissolve], animations: {
            
            self.headerView.firstColor = self.colorArray[self.currentColorArrayIndex].color1
            self.headerView.secondColor = self.colorArray[self.currentColorArrayIndex].color2
            
        }) { (success) in
            self.animateHeaderView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        previewLayer.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
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
                
                cameraView.addGestureRecognizer(tap)
                
                captureSession.startRunning()
                
            }
        } catch {
            debugPrint(error)
        }
        
    }
    

    func resultsMethod(request: VNRequest, error: Error?) {
        
        guard let results = request.results as? [VNClassificationObservation] else { return }
        
        for classification in results {
            
            if classification.confidence < 0.5 {
                let unknownObjMessage = "Not sure what's that"
                self.identificationLbl.text = unknownObjMessage + " 🤔."
                synthesizeSpeech(fromString: "\(unknownObjMessage). Take another photo")
                self.confidenceLbl.countFrom(fromValue: 0, to: classification.confidence * 100, withDuration: 2, andAnimationType: .EaseOut, andCountingType: .Int)
                self.percentLbl.isHidden = false
                break
            } else {
                
                var identifier = classification.identifier
                if let index1 = identifier.index(of: ",") {
                    let endIndex = identifier.endIndex
                    let range = index1 ..< endIndex
                    identifier = identifier.replacingCharacters(in: range, with: "")
                }
                
                self.identificationLbl.text = identifier.capitalized + " 🎉👏🏼"
                self.confidenceLbl.countFrom(fromValue: 0, to: classification.confidence * 100, withDuration: 3, andAnimationType: .EaseOut, andCountingType: .Int)
                self.percentLbl.isHidden = false
                synthesizeSpeech(fromString: "This looks like a \(identifier) and I'm \(Int(classification.confidence * 100)) percent sure.")
                break
                
            }
        }
    }
    
    func synthesizeSpeech(fromString string: String) {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynthesizer.speak(speechUtterance)
    }
    
    @objc @available(iOS 11.0, *)
    func didTapCameraView() {

        self.cameraView.isUserInteractionEnabled = false
//        self.spinner.isHidden = false
//        self.spinner.startAnimating()
        
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat

        if flashControlState == .off {
            settings.flashMode = .off
        } else {
            settings.flashMode = .on
        }
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func flashBtnPressed(_ sender: UIButton) {
        
        switch flashControlState {
        case .off:
            self.flashBtn.setImage(UIImage(named: "flashON"), for: .normal)
            self.flashBtnLbl.text = "ON"
            flashControlState = .on
        case .on:
            self.flashBtn.setImage(UIImage(named: "flashOFF"), for: .normal)
            self.flashBtnLbl.text = "OFF"
            flashControlState = .off
        }
    }
    
    
}

@available(iOS 11.0, *)
extension CameraVC: AVCapturePhotoCaptureDelegate {
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation()
            
            do {
                
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            } catch {
                debugPrint(error)
            }
            
            let image = UIImage(data: photoData!)
            self.captureImageView.image = image
            self.spinner.isHidden = false
            self.spinner.startAnimating()
        }
    }
}

@available(iOS 11.0, *)
extension CameraVC: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.cameraView.isUserInteractionEnabled = true
        self.spinner.isHidden = true
        self.spinner.stopAnimating()
    }
}







