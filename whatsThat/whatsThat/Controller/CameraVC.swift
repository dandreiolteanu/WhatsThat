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
    var currentColorArrayIndex = -1
    
    var colorArrayFlashON: [(color1: UIColor, color2: UIColor)] = []
    var currentFlashONColorArrayIndex = -1
    
    var colorArrayFlashOFF: [(color1: UIColor, color2: UIColor)] = []
    var currentFlashOFFColorArrayIndex = -1

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechSynthesizer.delegate = self
        
        // COLORS FOR THE ANIMATION
        colorArray.append((color1: #colorLiteral(red: 0.2591436505, green: 0.6219938397, blue: 0.8805219531, alpha: 1) , color2: #colorLiteral(red: 0.4490969181, green: 0.7435027957, blue: 0.804695785, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.4490969181, green: 0.7435027957, blue: 0.804695785, alpha: 1) , color2: #colorLiteral(red: 0.2834140658, green: 0.3753284812, blue: 1, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.2808943391, green: 0.3773900867, blue: 1, alpha: 1) , color2: #colorLiteral(red: 0, green: 0.5921684504, blue: 1, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0, green: 0.5912120938, blue: 0.9986155629, alpha: 1) , color2: #colorLiteral(red: 0.7379384637, green: 0.526999712, blue: 0.9968449473, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.7365908027, green: 0.5287910104, blue: 0.9967978597, alpha: 1) , color2: #colorLiteral(red: 0.9972050786, green: 0.1419899464, blue: 0.8185440898, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.9972050786, green: 0.1419899464, blue: 0.8185440898, alpha: 1) , color2: #colorLiteral(red: 1, green: 0.4325678945, blue: 0.586425364, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.9993091226, green: 0.4343143404, blue: 0.5869914293, alpha: 1) , color2: #colorLiteral(red: 1, green: 0.6235074401, blue: 0.3715840578, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.9977305532, green: 0.6254910231, blue: 0.3733866215, alpha: 1) , color2: #colorLiteral(red: 0.555644393, green: 0.751979053, blue: 0.6523420215, alpha: 1)))
        colorArray.append((color1: #colorLiteral(red: 0.555644393, green: 0.751979053, blue: 0.6523420215, alpha: 1) , color2: #colorLiteral(red: 0.03810773417, green: 0.6029273272, blue: 0.8819715381, alpha: 1)))

        animateHeaderView()
        
//        colorArrayFlashON.append((color1: #colorLiteral(red: 0.2591436505, green: 0.6219938397, blue: 0.8805219531, alpha: 1) , color2: #colorLiteral(red: 0.4490969181, green: 0.7435027957, blue: 0.804695785, alpha: 1)))
//        colorArrayFlashON.append((color1: #colorLiteral(red: 0.4490969181, green: 0.7435027957, blue: 0.804695785, alpha: 1) , color2: #colorLiteral(red: 0.2834140658, green: 0.3753284812, blue: 1, alpha: 1)))
//        colorArrayFlashON.append((color1: #colorLiteral(red: 0.2808943391, green: 0.3773900867, blue: 1, alpha: 1) , color2: #colorLiteral(red: 0, green: 0.5921684504, blue: 1, alpha: 1)))
//
//        colorArrayFlashOFF.append((color1: #colorLiteral(red: 0, green: 0.5912120938, blue: 0.9986155629, alpha: 1) , color2: #colorLiteral(red: 0.9972050786, green: 0.1419899464, blue: 0.8185440898, alpha: 1)))
//        colorArrayFlashOFF.append((color1: #colorLiteral(red: 0.9972050786, green: 0.1419899464, blue: 0.8185440898, alpha: 1) , color2: #colorLiteral(red: 1, green: 0.4325678945, blue: 0.586425364, alpha: 1)))
//        colorArrayFlashOFF.append((color1: #colorLiteral(red: 0.9993091226, green: 0.4343143404, blue: 0.5869914293, alpha: 1) , color2: #colorLiteral(red: 1, green: 0.6235074401, blue: 0.3715840578, alpha: 1)))
//        colorArrayFlashOFF.append((color1: #colorLiteral(red: 1, green: 0.6235074401, blue: 0.3715840578, alpha: 1) , color2: #colorLiteral(red: 0.03810773417, green: 0.6029273272, blue: 0.8819715381, alpha: 1)))
        
        confidenceLbl.countFrom(fromValue: 50, to: 0, withDuration: 2, andAnimationType: .EaseOut, andCountingType: .Int)
        
        spinner.type = NVActivityIndicatorType.ballGridPulse
    }
    
    
    /*              ##########################################
     *
     *              // FUNCTIONS FOR ANIMATING THE HEADER VIEW
     *
     *              ###########################################
     */
    
    
    func animateHeaderView() {
        currentColorArrayIndex = currentColorArrayIndex == (colorArray.count - 1) ? 0 : currentColorArrayIndex + 1
        // SETTING THE DURATION OF THE ANIMATION FROM HERE
        UIView.transition(with: headerView, duration: 6, options: [.transitionCrossDissolve], animations: {
            
            self.headerView.firstColor = self.colorArray[self.currentColorArrayIndex].color1
            self.headerView.secondColor = self.colorArray[self.currentColorArrayIndex].color2
            
        }) { (success) in
            self.animateHeaderView()
        }
    }
    
    func animateHeaderViewFlashON() {
        currentFlashONColorArrayIndex = currentFlashONColorArrayIndex == (colorArrayFlashON.count - 1) ? 0 : currentFlashONColorArrayIndex + 1
        // SETTING THE DURATION OF THE ANIMATION FROM HERE
        UIView.transition(with: headerView, duration: 2, options: [.transitionCrossDissolve], animations: {
            
            self.headerView.firstColor = self.colorArrayFlashON[self.currentFlashONColorArrayIndex].color1
            self.headerView.secondColor = self.colorArrayFlashON[self.currentFlashONColorArrayIndex].color2
            
        }) { (success) in
            self.animateHeaderViewFlashON()
        }
    }
    
    func animateHeaderViewFlashOFF() {
        currentFlashOFFColorArrayIndex = currentFlashOFFColorArrayIndex == (colorArrayFlashOFF.count - 1) ? 0 : currentFlashOFFColorArrayIndex + 1
        // SETTING THE DURATION OF THE ANIMATION FROM HERE
        UIView.transition(with: headerView, duration: 2, options: [.transitionCrossDissolve], animations: {
            
            self.headerView.firstColor = self.colorArrayFlashOFF[self.currentFlashOFFColorArrayIndex].color1
            self.headerView.secondColor = self.colorArrayFlashOFF[self.currentFlashOFFColorArrayIndex].color2
            
        }) { (success) in
            self.animateHeaderViewFlashOFF()
        }
    }
    
    
    /*              ###################################################
     *
     *              // FINISHED FUNCTIONS FOR ANIMATING THE HEADER VIEW
     *
     *              ###################################################
     */
    
    
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
//            self.animateHeaderViewFlashOFF()
            self.flashBtn.setImage(UIImage(named: "flashON"), for: .normal)
            self.flashBtnLbl.text = "ON"
            flashControlState = .on
        case .on:
//            self.animateHeaderViewFlashON()
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







