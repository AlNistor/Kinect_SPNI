//
//  BodyMovement.swift
//  Kinect
//
//  Created by Alexandru Nistor on 1/8/17.
//  Copyright © 2017 ASSIST. All rights reserved.
//

import Foundation

final class BodyMovement {
    final var name = ""
    final var bodyPostures = [BodyPosture]()
    
    func movingDistance(bm2 : BodyMovement) -> Double {
        var m = [[Double]]()
        var po1 = self.bodyPostures
        var po2 = bm2.bodyPostures
        
        m[0][0] = po1[0].distanta(toBody: po2[0])
        
        for (index, _) in po1.enumerated() {
            if index == 0 {
                continue
            }
            m[index][0] = po1[index].distanta(toBody: po2[0]) + m[index - 1][0]
        }
        
        for (index, _) in po2.enumerated() {
            if index == 0 {
                continue
            }
            m[0][index] = po2[index].distanta(toBody: po1[0]) + m[0][index - 1]
        }
        
        for (i, _) in po1.enumerated() {
            if i == 0 {
                continue
            }
            for (j, _) in po2.enumerated() {
                if j == 0 {
                    continue
                }
                m[i][j] = min(min(m[i-1][j-1], m[i-1][j]), m[i][j-1]) + po1[i].distanta(toBody: po2[j])
            }
        }
        
        return m[po1.count-1][po2.count-1]
    }
    
    
}
