//
//  GradientExt.swift
//  Techanical Test
//
//  Created by Jit Patel on 14/7/20.
//  Copyright © 2020 Jit Patel. All rights reserved.
//

import Foundation
import UIKit


public struct GradientValue {
    let color: UIColor
    let position: Float
}


extension Array where Element == GradientValue {
    
    var colorList:[CGColor] {
        get {
            var colors = [CGColor]()
            
            for gValue in self {
                colors.append(gValue.color.cgColor)
            }
            
            return colors
        }
    }
    
    var colorPositionList:[NSNumber] {
        get {
            var positions = [NSNumber]()
            
            for gValue in self {
                positions.append(NSNumber(value: gValue.position))
            }
            
            return positions
        }
    }
    
    
    var gradientLayer:CAGradientLayer {
        get {
            let gradientLayer = CAGradientLayer()
            
            gradientLayer.locations = self.colorPositionList
            gradientLayer.colors = self.colorList
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.cornerRadius = 1.25
            
            return gradientLayer
        }
    }
    
   
    func getRGBA(atIndex:Int) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self[atIndex].color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
    
    
    func colorAt(position:Float) -> UIColor {
        
        if (position <= self[0].position) {
            return self[0].color
        }
        
       
        if (position >= self[count - 1].position) {
            return self[count - 1].color
        }
        
        var end:Int = 1
        
        
        while (self[end].position < position) {
            end += 1
        }
        
        
        let spanTime:Float = (position - self[end - 1].position) / (self[end].position - self[end - 1].position)
        
        let colorA = self.getRGBA(atIndex: end - 1)
        let colorB = self.getRGBA(atIndex: end)
        
       
        let cgSpanTime:CGFloat = CGFloat(spanTime)
        
      
        let lerpR:CGFloat = Util.lerp(colorA.red, b: colorB.red, t: cgSpanTime)
        let lerpG:CGFloat = Util.lerp(colorA.green, b: colorB.green, t: cgSpanTime)
        let lerpB:CGFloat = Util.lerp(colorA.blue, b: colorB.blue, t: cgSpanTime)
        let lerpA:CGFloat = Util.lerp(colorA.alpha, b: colorB.alpha, t: cgSpanTime)
        
        
        return UIColor(red: lerpR, green: lerpG, blue: lerpB, alpha: lerpA)
    }
}
