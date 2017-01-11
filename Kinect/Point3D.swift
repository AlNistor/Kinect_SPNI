//
//  Point3D.swift
//  Kinect
//
//  Created by Alexandru Nistor on 1/8/17.
//  Copyright © 2017 ASSIST. All rights reserved.
//

import Foundation
import SwiftyJSON

final class Point3D {
    // MARK: - Public Variables
    final var X             : Float         = 0.0
    final var Y             : Float         = 0.0
    final var Z             : Float         = 0.0
    final var ScreenPoint   : CGPoint       = CGPoint()
    final var type          : String        = ""
    
    // MARK: - Constructor
    init(x : Float, y : Float, z : Float, screenPoint : CGPoint, type_ : String) {
        X = x
        Y = y
        Z = z
        ScreenPoint = screenPoint
        type = type_
    }
    
    init(jsonPoint : JSON) {
        X = jsonPoint["X"].floatValue
        Y = jsonPoint["Y"].floatValue
        Z = jsonPoint["Z"].floatValue
        type = jsonPoint["Type"].stringValue
        ScreenPoint = CGPoint(x: jsonPoint["ScreenPoint"]["X"].intValue, y: jsonPoint["ScreenPoint"]["Y"].intValue)
    }
    
    // MARK: - Static functions
    func sqrEuclideanDistance(b : Point3D) -> Double {
        let res = (self.X - b.X) * (self.X - b.X) + (self.Y - b.Y) * (self.Y - b.Y) + (self.Z - b.Z) * (self.Z - b.Z)
        return Double(res)
    }
}
