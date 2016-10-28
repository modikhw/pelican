//
//  RandomFunction.swift
//  flapps
//
//  Created by Mahmoud Khwaiter on 2016-10-26.
//  Copyright © 2016 Mahmoud Khwaiter. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat {

    public static func random() -> CGFloat {
    
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    
    }

    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
    
        return CGFloat.random() * (max - min) + min
    
    }


}
