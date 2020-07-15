//
//  GradientSlider.swift
//  Techanical Test
//
//  Created by Jit Patel on 14/7/20.
//  Copyright © 2020 Jit Patel. All rights reserved.
//
import Foundation
import UIKit

class GradientSlider: UISlider {
    
  
    enum ThumbCurrentState {
        case scaleDown
        case scaleUp
        case normal
    }
    
    
    enum manageState {
        case animating
        case normal
    }
    
    
    let sliderHeight:CGFloat = 3
    let thumbMinSize:CGFloat = 10.0
    let thumbMaxSize:CGFloat = 31.0
    
    
    var currentThumbSize:CGFloat = 10.0
    
    
    let animationFactor:CGFloat = 2.5
    var timerUpdate:Timer? = nil
    var currentAnimationState:ThumbCurrentState = .normal
    
   
    let trackAnimationTimeFactor:CGFloat = 0.08
    var trackAnimationTime:CGFloat = 0.0
    var startValue:CGFloat = 0.0
    var targetValue:CGFloat = 0.0
    var trackAnimationState:manageState = .normal
    
    
    var gradients:[GradientValue]? = nil
    
    
    var realValue:Float {
        get {
            if (trackAnimationState == .normal) {
                return self.value
            }
            
            return Float(self.targetValue)
        }
    }
    
    required init? (coder: NSCoder) {
        super.init(coder: coder)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gesture:)))
        panGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(panGesture)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        
        self.addGestureRecognizer(tapGestureRecognizer)
        
        
        self.addTarget(self, action: #selector(touchDown), for:UIControl.Event.touchDown)
        self.addTarget(self, action: #selector(touchUp), for:UIControl.Event.touchUpInside)
        self.addTarget(self, action: #selector(touchUp), for:UIControl.Event.touchUpOutside)
        
       
        self.timerUpdate = Timer.scheduledTimer(timeInterval: 0.01,
                                                target: self,
                                                selector: #selector(update),
                                                userInfo: nil,
                                                repeats: true)
    }
    
   
    @objc func update() {
        switch currentAnimationState {
        case .scaleDown:
           
            let newSize:CGFloat = currentThumbSize + animationFactor
            
            let clampedSize:CGFloat = Util.clamp(newSize,
                                                 minValue: thumbMinSize,
                                                 maxValue: thumbMaxSize)
            
            
            if (clampedSize < newSize) {
                currentAnimationState = .normal
                currentThumbSize = thumbMaxSize
            }
            else {
                currentThumbSize = clampedSize
            }
        case .scaleUp:
            
            let newSize:CGFloat = currentThumbSize - animationFactor
            
            let clampedSize:CGFloat = Util.clamp(newSize,
                                                 minValue: thumbMinSize,
                                                 maxValue: thumbMaxSize)
            
           
            if (clampedSize > newSize) {
                currentAnimationState = .normal
                currentThumbSize = thumbMinSize
            }
            else {
                currentThumbSize = clampedSize
            }
        case .normal:
            break
        }
        
        switch trackAnimationState {
        case .animating:
            let currentValue:CGFloat = Util.curve(self.startValue,
                                                 b: self.targetValue,
                                                 t: self.trackAnimationTime)
            
            let newTrackTime:CGFloat = self.trackAnimationTime + self.trackAnimationTimeFactor
            let clampedTrackTime:CGFloat = Util.clamp(newTrackTime, minValue: 0.0, maxValue: 1.0)
            
           
            if (newTrackTime > clampedTrackTime) {
                self.setValue(Float(self.targetValue), animated: true)
                trackAnimationState = .normal
            }
            else {
                trackAnimationTime = clampedTrackTime
                self.setValue(Float(currentValue), animated: true)
            }
        case .normal:
            break
        }
        
        
        if (currentAnimationState != .normal || trackAnimationState != .normal) {
            updateThumbTintColor()
        }
    }
    
    @objc func touchDown() {
        currentAnimationState = .scaleDown
    }
    
    @objc func touchUp() {
        currentAnimationState = .scaleUp
    }
    
    
    @objc func panGesture(gesture:UIPanGestureRecognizer) {
        if (gesture.state == .changed && trackAnimationState == .normal) {
            // perform the smooth transition
            let currentPoint = gesture.location(in: self)
            let percentage = currentPoint.x / self.bounds.size.width;
            let delta = Float(percentage) * (self.maximumValue - self.minimumValue)
            let value = self.minimumValue + delta

            self.setValue(value, animated: true)
            
            updateThumbTintColor()
        }
        
        if (gesture.state == .began) {
            touchDown()
        }
        else if (gesture.state == .ended) {
            touchUp()
        }
    }
    
    
    @objc func tapGesture(gesture:UITapGestureRecognizer) {
        let slider: UISlider? = gesture.view as? UISlider
        
        if (slider?.isHighlighted)! {
            return
        }

        let pt: CGPoint = gesture.location(in: slider)
        let percentage = pt.x / (slider?.frame.size.width)!
        let delta = Float(percentage) * Float((slider?.maximumValue)! - (slider?.minimumValue)!)
        let value = (slider?.minimumValue)! + delta
        
        setAnimatedValue(Float(value))
    }
    
   
    public func setBackgroundGradient(gradients: [GradientValue]) {
        self.gradients = gradients
        let gradientLayer = gradients.gradientLayer
        
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: sliderHeight)

        UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, false, 0.0)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let stretchedImage = image?.stretchableImage(withLeftCapWidth: 14, topCapHeight: 0)

        self.setMinimumTrackImage(stretchedImage, for: .normal)
        self.setMaximumTrackImage(stretchedImage, for: .normal)
        
        updateThumbTintColor()
    }
    
   
    public func setAnimatedValue(_ value:Float) {
        self.targetValue = CGFloat(value)
        self.startValue = CGFloat(self.value)
        self.trackAnimationTime = 0.0
        self.trackAnimationState = .animating
    }
    
  
    private func updateThumbTintColor() {
        if (self.gradients != nil) {
            let mappedValue:CGFloat = Util.map(CGFloat(self.value),
                                             inMin:CGFloat(self.minimumValue),
                                             inMax:CGFloat(self.maximumValue),
                                             outMin:0.0,
                                             outMax:1.0)
            
            let thumbColor:UIColor = gradients!.colorAt(position: Float(mappedValue))
            
           
            self.thumbTintColor = thumbColor
            
           
            setThumbColor(color:thumbColor, withRadius:currentThumbSize)
        }
    }
    
   
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let currentBounds:CGRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        
        let minTrack:CGFloat = 0.0
        let maxTrack:CGFloat = bounds.size.width - bounds.size.height
        
       
        let trackFactor:CGFloat = Util.map(currentThumbSize,
                                         inMin:thumbMinSize,
                                         inMax:thumbMaxSize,
                                         outMin:thumbMinSize,
                                         outMax:0.0)
        
     
        let minNewTrack:CGFloat = minTrack - trackFactor - (currentThumbSize / 2.0)
        let maxNewTrack:CGFloat = maxTrack + trackFactor + (currentThumbSize / 2.0)
        
        let currentValue:CGFloat = currentBounds.origin.x
        
       
        let mappedValue:CGFloat = Util.map(currentValue,
                                         inMin:minTrack,
                                         inMax:maxTrack,
                                         outMin:minNewTrack,
                                         outMax:maxNewTrack)
        
        let modifiedBounds:CGRect = CGRect(x: mappedValue,
                                           y: currentBounds.origin.y,
                                           width: currentBounds.size.width,
                                           height: currentBounds.size.height)
        
        return modifiedBounds
    }
    
  
    func setThumbColor(color: UIColor, withRadius: CGFloat) {
        let imageSize:CGSize = CGSize(width: thumbMaxSize, height: thumbMaxSize)
        let circleSize:CGSize = CGSize(width: withRadius, height: withRadius)
        
        let circleImage:UIImage = makeCircleWith(size: imageSize, circleSize: circleSize, backgroundColor: color)
        
        self.setThumbImage(circleImage, for: .normal)
        self.setThumbImage(circleImage, for: .highlighted)
    }
    
   
    fileprivate func makeCircleWith(size: CGSize, circleSize: CGSize, backgroundColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(backgroundColor.cgColor)
        context.setStrokeColor(UIColor.clear.cgColor)
        
        let originPt:CGFloat = Util.map(circleSize.width,
                                        inMin: thumbMinSize,
                                        inMax: thumbMaxSize,
                                        outMin: thumbMinSize,
                                        outMax: 0.0)
        
        let origin:CGPoint = CGPoint(x: originPt, y: originPt)
        
        let bounds = CGRect(origin: origin, size: circleSize)
        context.addEllipse(in: bounds)
        context.drawPath(using: .fill)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
