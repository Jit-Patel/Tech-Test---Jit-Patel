//
//  Util.swift
//  Techanical Test
//
//  Created by Jit Patel on 14/7/20.
//  Copyright © 2020 Jit Patel. All rights reserved.
//

import Foundation
import UIKit

class Util {
    
    
    public class func map(_ x:CGFloat, inMin:CGFloat, inMax:CGFloat, outMin:CGFloat, outMax:CGFloat) -> CGFloat {
        return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
    }
    
   
    public class func clamp(_ x:CGFloat, minValue:CGFloat, maxValue:CGFloat) -> CGFloat {
        return min(max(x, minValue), maxValue)
    }
    
    
    public class func lerp(_ a:CGFloat, b:CGFloat, t:CGFloat) -> CGFloat {
        return (a * (1.0 - t)) + (b * t);
    }
    
   
    public class func curve(_ a:CGFloat, b:CGFloat, t:CGFloat) -> CGFloat {
        let cubicTime:CGFloat = t * t * (3.0 - 2.0 * t)
        
        return Util.lerp(a, b: b, t: cubicTime)
    }
}
