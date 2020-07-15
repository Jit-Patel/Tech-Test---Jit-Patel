//
//  ViewController.swift
//  Techanical Test
//
//  Created by Jit Patel on 14/7/20.
//  Copyright © 2020 Jit Patel. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController, MTKViewDelegate {
    
    enum HSBRenderMode {
           case enabled
           case disabled
       }

    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    
   
    @IBOutlet weak var hueSlider: GradientSlider!
    @IBOutlet weak var saturationSlider: GradientSlider!   
    @IBOutlet weak var brightnessSlider: GradientSlider!
    
       
        var device: MTLDevice!
        var commandQueue: MTLCommandQueue!
        var sourceTexture: MTLTexture!
        
        
        @IBOutlet weak var metalView: MTKView!
        
        
        var context: CIContext!
        let saturationFilter = CIFilter(name: "CIColorControls")!
        let brightnessFilter = CIFilter(name: "CIColorControls")!
        let hueFilter = CIFilter(name: "CIHueAdjust")!
        let colorSpace = CGColorSpace.init(name: CGColorSpace.extendedLinearDisplayP3)!
        
        
        var renderStatus:HSBRenderMode = .enabled
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            resetButton.layer.cornerRadius=5
            previewButton.layer.cornerRadius=5
            undoButton.layer.cornerRadius=5
            redoButton.layer.cornerRadius=5
            
            device = MTLCreateSystemDefaultDevice()
            commandQueue = device.makeCommandQueue()!
            
            metalView.delegate = self
            metalView.device = device
            metalView.framebufferOnly = false
            
            context = CIContext(mtlDevice: device)
            
            
            let loader = MTKTextureLoader(device: device)
            let url = Bundle.main.url(forResource: "Neon-Source", withExtension: "png")!
            
          
            #if targetEnvironment(simulator)
            sourceTexture = try! loader.newTexture(URL: url,
                                                   options: [:])
            #else
            sourceTexture = try! loader.newTexture(URL: url,
                                                   options: [MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.flippedVertically])
            #endif
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
          
            let hueGradients:[GradientValue] = [
                GradientValue(color: UIColor(named: "Hue 0")!, position: 0.0),
                GradientValue(color: UIColor(named: "Hue 13")!, position: 0.13),
                GradientValue(color: UIColor(named: "Hue 31")!, position: 0.31),
                GradientValue(color: UIColor(named: "Hue 45")!, position: 0.45),
                GradientValue(color: UIColor(named: "Hue 56")!, position: 0.56),
                GradientValue(color: UIColor(named: "Hue 66")!, position: 0.66),
                GradientValue(color: UIColor(named: "Hue 73")!, position: 0.73),
                GradientValue(color: UIColor(named: "Hue 87")!, position: 0.87),
                GradientValue(color: UIColor(named: "Hue 100")!, position: 1.0)
            ]
             
            let satGradients:[GradientValue] = [
                GradientValue(color: UIColor(named: "Saturation 0")!, position: 0.0),
                GradientValue(color: UIColor(named: "Saturation 100")!, position: 1.0)
            ]
             
            let briGradients:[GradientValue] = [
                GradientValue(color: UIColor(named: "Brightness 0")!, position: 0.0),
                GradientValue(color: UIColor(named: "Brightness 100")!, position: 1.0)
            ]
             
            hueSlider.setBackgroundGradient(gradients: hueGradients)
            saturationSlider.setBackgroundGradient(gradients: satGradients)
            brightnessSlider.setBackgroundGradient(gradients: briGradients)
        }
        
       
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
    
        func draw(in view: MTKView) {
            if let currentDrawable = view.currentDrawable {
                let commandBuffer = commandQueue.makeCommandBuffer()!
                
                let inputImage = CIImage(mtlTexture: sourceTexture)!
                
               
                brightnessFilter.setValue(inputImage, forKey: kCIInputImageKey)
                brightnessFilter.setValue(brightnessSlider.value as NSNumber, forKey: kCIInputBrightnessKey)

                let brightnessOutput = brightnessFilter.outputImage!

               
                saturationFilter.setValue(brightnessOutput, forKey: kCIInputImageKey)
                saturationFilter.setValue(saturationSlider.value as NSNumber, forKey: kCIInputSaturationKey)

                let saturationOutput = saturationFilter.outputImage!

               
                hueFilter.setValue(saturationOutput, forKey: kCIInputImageKey)
                hueFilter.setValue(hueSlider.value as NSNumber, forKey: "inputAngle")

                let hueOutput = hueFilter.outputImage!

                context.render(hueOutput,
                              to: currentDrawable.texture,
                              commandBuffer: commandBuffer,
                              bounds: inputImage.extent,
                              colorSpace: colorSpace)
                
                commandBuffer.present(currentDrawable)
                commandBuffer.commit()
            }
        }
        
       
    @IBAction func resetFilter(_ sender: Any) {
         resetHSB()
    }
    
    @IBAction func previewImage() {
        disableHSB()
    }
     
    @IBAction func previewEnabled() {
        enableHSB()
    }
                  
        
        var tempHueValue:Float = 0.0
        var tempSaturationValue:Float = 0.0
        var tempBrightnessValue:Float = 0.0
        
        fileprivate func resetHSB() {
            self.hueSlider.setAnimatedValue(0.0)
            self.saturationSlider.setAnimatedValue(1.0)
            self.brightnessSlider.setAnimatedValue(0.0)
        }
        
        fileprivate func enableHSB() {
            if (renderStatus == .disabled) {
                renderStatus = .enabled
                
                hueSlider.setAnimatedValue(tempHueValue)
                saturationSlider.setAnimatedValue(tempSaturationValue)
                brightnessSlider.setAnimatedValue(tempBrightnessValue)
            }
        }
        
        fileprivate func disableHSB() {
          
            if (renderStatus == .enabled) {
                renderStatus = .disabled
                
                tempHueValue = hueSlider.realValue
                tempSaturationValue = saturationSlider.realValue
                tempBrightnessValue = brightnessSlider.realValue
                
                hueSlider.setAnimatedValue(0.0)
                saturationSlider.setAnimatedValue(1.0)
                brightnessSlider.setAnimatedValue(0.0)
            }
        }
    }

