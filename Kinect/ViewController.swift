//
//  ViewController.swift
//  Kinect
//
//  Created by Alexandru Nistor on 1/8/17.
//  Copyright © 2017 ASSIST. All rights reserved.
//

import Cocoa
import Quartz
import CocoaAsyncSocket

class ViewController: NSViewController {

    @IBOutlet weak var imgView: NSImageView!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var recordButton: NSButton!
    
    fileprivate var offlinePostures : [BodyPosture]!
    fileprivate var currentPosture : BodyPosture!
    fileprivate var bodyMovement : BodyMovement! = BodyMovement()
    fileprivate var bodyMovements : [BodyMovement]!
    fileprivate var recording : Bool = false
    
    private var socket : GCDAsyncSocket!
    fileprivate var timer : Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        offlinePostures = PostureManager.loadPostures()
        loadPostureToUI(bp: offlinePostures[5])

        setupSocket()
        
//        PostureManager.savePosturesToFile(fileName: "test.json", postures: offlinePostures)
        
        statusLabel.stringValue = category(bp: offlinePostures[5])
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { (timer) in
            self.setupSocket()
        })
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func recordMovements(_ sender: Any) {
        recordButton.title = recording ? "Start Recording" : "Stop Recording"
        
        recording = !recording
    }
    
    private func setupSocket(){
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        try! socket.connect(toHost: "172.20.0.158", onPort: 12345)
        
        socket.readData(withTimeout: -1, tag: 1)
        socket.disconnectAfterReading()
    }
    
    fileprivate func loadPostureToUI(bp : BodyPosture){
        if self.imgView.subviews.count > 0 {
            self.imgView.subviews.removeAll()
        }
        
        let newImgToDisplay = bp.toImage(width: self.view.frame.size.width , height: self.view.frame.size.height)
        
        let subviews = newImgToDisplay.subviews
        
        for v in subviews {
            self.imgView.subviews.insert(v, at: 0)
        }
    }
}

extension ViewController : GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        
        if let stringifyData = String(data: data, encoding: .ascii) {
            let posture = BodyPosture(text: stringifyData)
            currentPosture = posture
            if recording {
                bodyMovement.bodyPostures.append(currentPosture)
            }
            
            
            loadPostureToUI(bp: currentPosture)
        }
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
    }
    
    fileprivate func category(bp : BodyPosture) -> String {

        if !recording {
            let result = offlinePostures.sorted(by: {$0.distanta(toBody: bp) < $1.distanta(toBody: bp)})
            return result.first!.type
        }
        
        return ""
    }
    
    fileprivate func movementCategory(bm : BodyMovement) -> String{
        if !recording {
            let result = bodyMovements.sorted(by: {$0.movingDistance(bm2: bm) < $1.movingDistance(bm2: bm)})
            return result.first!.name
        }
        
        return ""
    }
}
