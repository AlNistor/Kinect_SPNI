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
    
    static func loadPostures(fromURL : URL, completion: @escaping (([BodyPosture]) -> Void) ) {
        var postures = [BodyPosture]()
        
        let sharedSession = URLSession.shared
        
        let downloadTask = sharedSession.downloadTask(with: fromURL) { (url, urlResponse, error) in
            do {
                let contents = try NSString(contentsOf: url!, encoding: String.Encoding.utf8.rawValue)
                
                let jsonFile = JSON(data: contents.data(using: String.Encoding.utf8.rawValue)!)
                
                for item in jsonFile.array! {
                    
                    let bP = BodyPosture(jsonData: item)
                    postures.append(bP)
                }
                
                completion(postures)
            } catch {
                print("Error readling file at path:   \(url?.absoluteString)")
            }
        }

        downloadTask.resume()
    }
    
    static func savePosturesToFile(fileName : String, postures : [BodyPosture]){
        let jsonPost = JSONSerializer.toJson(postures)
        
        let start = jsonPost.index(after: jsonPost.startIndex)
        let end = jsonPost.index(jsonPost.endIndex, offsetBy: -1)
        
        do {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let path = dir.appendingPathComponent(fileName)
                try jsonPost[start..<end].write(to: path, atomically: false, encoding: .utf8)
                
                print("Write to file succeded!")
            }
        }catch {
            print("Something went wrong with saving")
        }
    }
}

func generateRandomNumber(min: Int, max: Int) -> Int {
    let randomNum = Int(arc4random_uniform(UInt32(max) - UInt32(min)) + UInt32(min))
    return randomNum
}
