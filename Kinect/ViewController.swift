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
import SwiftyJSON

class ViewController: NSViewController {

    @IBOutlet weak var imgView: NSImageView!
    @IBOutlet weak var getPostureButton: NSButton!
    @IBOutlet weak var classNameTextField: NSTextField!
    @IBOutlet weak var resultClasificationTextField: NSTextField!
    @IBOutlet weak var saveToFileButton: NSButton!
    @IBOutlet weak var loadFileButton: NSButton!
    @IBOutlet weak var classifyButton: NSButton!
    @IBOutlet weak var leftScrollView: NSScrollView!
    @IBOutlet weak var rightScrollView: NSScrollView!
    @IBOutlet var leftTextView: NSTextView!
    @IBOutlet var rightTextView: NSTextView!
    
    
    fileprivate var offlinePostures : [BodyPosture] = []
    fileprivate var savedPostures : [BodyPosture] = []
    fileprivate var currentPosture : BodyPosture!
    fileprivate var bodyMovement : BodyMovement! = BodyMovement()
    fileprivate var bodyMovements : [BodyMovement] = []
    fileprivate var recording : Bool = false
    
    fileprivate let useSOCKET : Bool = false
    
    private var socket : GCDAsyncSocket!
    fileprivate var timer : Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        offlinePostures = PostureManager.loadPostures()
        loadPostureToUI(bp: offlinePostures[5])
        
//        PostureManager.savePosturesToFile(fileName: "test.json", postures: offlinePostures)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { (timer) in
            if self.useSOCKET {
                self.setupSocket()
            }else {
                self.currentPosture = BodyPosture.generateRandomPostures(frame: self.imgView.frame)
                self.loadPostureToUI(bp: self.currentPosture)
            }
        })
        
        timer.fire()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - Actions
    @IBAction func getPostureAction(_ sender: Any) {
        if classNameTextField.stringValue.isEmpty {
            print("Please insert a name for this posture!")
            return
        }
        
        currentPosture.name = classNameTextField.stringValue.uppercased()
        savedPostures.append(currentPosture)
        
        var tempString = ""
        for item in savedPostures {
            tempString += JSONSerializer.toJson(item) + "\n\n\n"
        }
        
        leftTextView.string = tempString
        
        leftTextView.scrollToEndOfDocument(nil)
    }
    
    @IBAction func savePosturesToFileAction(_ sender: Any) {
        if savedPostures.isEmpty {
            print("You don't have any postures saved yet.")
            return
        }
        
        PostureManager.savePosturesToFile(fileName: "postures_\(Date().toString()).json", postures: savedPostures)
        
        savedPostures = []
        leftTextView.string = "File has been saved!"
    }
    
    @IBAction func loadFromFileAction(_ sender: Any) {
        let dialog = NSOpenPanel()
        
        dialog.title                   = "Alegeti un fisier cu extensia .json"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["json"]
        
        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                PostureManager.loadPostures(fromURL: result!, completion: { (newPostures) in
                    self.offlinePostures = newPostures
                    
                    var tempString = ""
                    for item in self.offlinePostures {
                        tempString += JSONSerializer.toJson(item) + "\n\n\n"
                    }
                    
                    DispatchQueue.main.async(execute: { 
                        self.rightTextView.string = tempString + "\n\n END OF FILE"
                    })
                })
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func classifyAction(_ sender: Any) {
        if offlinePostures.isEmpty {
            print("Nu avem posturi cu care sa comparam.")
            return
        }
        
        resultClasificationTextField.stringValue = category(bp: currentPosture)
    }
    
    // MARK: - Private Methods
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
            v.frame.origin.y = v.frame.origin.y - 400
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
            loadPostureToUI(bp: currentPosture)
        }
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
    }
    
    fileprivate func category(bp : BodyPosture) -> String {
        let result = offlinePostures.sorted(by: {$0.distanta(toBody: bp) < $1.distanta(toBody: bp)})
        return result.first!.name
    }
    
    fileprivate func movementCategory(bm : BodyMovement) -> String{
        let result = bodyMovements.sorted(by: {$0.movingDistance(bm2: bm) < $1.movingDistance(bm2: bm)})
        return result.first!.name
    }
}
