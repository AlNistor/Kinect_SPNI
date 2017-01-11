//
//  PostureManager.swift
//  Kinect
//
//  Created by Alexandru Nistor on 1/8/17.
//  Copyright © 2017 ASSIST. All rights reserved.
//

import Foundation
import SwiftyJSON

final class PostureManager {
    static func loadPostures() -> [BodyPosture] {
        var postures = [BodyPosture]()
        
        if let path = Bundle.main.path(forResource: "posturi", ofType: ".json"){

            do {
                let text = try String(contentsOfFile: path)
                let jsonFile = JSON(data: text.data(using: .utf8)!)
                
                for item in jsonFile.array! {
                    
                    let bP = BodyPosture(jsonData: item)
                    postures.append(bP)
                }
                
            }
            catch {/* error handling here */}
        }
        
        return postures
    }
    
    static func savePosturesToFile(fileName : String, postures : [BodyPosture]){
        let jsonPost = JSON(postures)
        
        do {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let path = dir.appendingPathComponent(fileName)
            try jsonPost.rawString()?.write(to: path, atomically: false, encoding: .utf8)
            }
        }catch {
            print("Something went wrong with saving")
        }
    }
}
