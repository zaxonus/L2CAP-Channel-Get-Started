//
//  ViewController.swift
//  L2CAPC
//
//  Created by Michel Bouchet on 2019/01/21.
//  Copyright © 2019 Michel Bouchet. All rights reserved.
//

import UIKit
import CoreBluetooth

class L2CAPC_ViewController: UIViewController,StreamDelegate {
    let service_UUID = CBUUID(string:"BC34CB8D-1841-42C4-ABE0-0A813CE2C8FE"),
    svcCharac_UUID = CBUUID(string:"C6465CBA-7C75-4035-98DB-9DF58114281C"),
    //svcCharac_UUID = CBUUID(string:CBUUIDL2CAPPSMCharacteristicString),
    titleLabel = UILabel(), messagePanel = UILabel(), psmLabel = UILabel(),
    sendInfo = UIButton()
    var outPutStream:OutputStream!, inPutStream:InputStream!,
    cbL2CAPChan:CBL2CAPChannel!, mustSendData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUserInterface()
    }
    
    
    func setUserInterface() {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = UIColor.brown
        titleLabel.backgroundColor = UIColor.yellow
        titleLabel.textAlignment = .center
        
        messagePanel.font = UIFont.preferredFont(forTextStyle: .headline)
        messagePanel.numberOfLines = 0
        messagePanel.adjustsFontSizeToFitWidth = true
        messagePanel.textColor = UIColor.blue
        messagePanel.textAlignment = .center
        messagePanel.text = ""
        
        psmLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        psmLabel.adjustsFontSizeToFitWidth = true
        psmLabel.numberOfLines = 0
        psmLabel.textColor = UIColor.purple
        psmLabel.textAlignment = .center
        psmLabel.text = ""
        
        sendInfo.isEnabled = false
        sendInfo.titleLabel!.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        sendInfo.titleLabel!.numberOfLines = 0
        sendInfo.titleLabel!.textAlignment = .center
        sendInfo.setTitleColor(UIColor.darkGray, for: .normal)
        sendInfo.setTitleColor(UIColor.lightGray, for: .disabled)
        sendInfo.setTitle("Send Random String", for: .normal)
        sendInfo.addTarget(self, action: #selector(makeAndSendL2CAPInfo), for: .touchUpInside)
        
        for component in [titleLabel,messagePanel,psmLabel,sendInfo] {
            component.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(component)
            view.addConstraint(NSLayoutConstraint(item: component, attribute: .centerX, relatedBy: .equal,
                                                  toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        }
        
        for component in [titleLabel,psmLabel,sendInfo] {
            component.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(component)
            view.addConstraints([
                NSLayoutConstraint(item: component, attribute: .width, relatedBy: .equal,
                                   toItem: view, attribute: .width, multiplier: 0.4, constant: 0.0),
                NSLayoutConstraint(item: component, attribute: .height, relatedBy: .equal,
                                   toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 40.0)])
        }
        
        view.addConstraints([
            NSLayoutConstraint(item: messagePanel, attribute: .width, relatedBy: .equal,
                               toItem: view, attribute: .width, multiplier: 0.9, constant: 0.0),
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal,
                               toItem: view, attribute: .top, multiplier: 1.0,
                               constant: UIApplication.shared.statusBarFrame.height + 5.0),
            NSLayoutConstraint(item: messagePanel, attribute: .top, relatedBy: .equal,
                               toItem: titleLabel, attribute: .bottom, multiplier: 1.0,
                               constant: UIApplication.shared.statusBarFrame.height),
            NSLayoutConstraint(item: messagePanel, attribute: .bottom, relatedBy: .equal,
                               toItem: psmLabel, attribute: .top, multiplier: 1.0, constant: -7.0),
            NSLayoutConstraint(item: psmLabel, attribute: .centerY, relatedBy: .equal,
                               toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: sendInfo, attribute: .centerY, relatedBy: .equal,
                               toItem: view, attribute: .centerY, multiplier: 1.5, constant: 0.0)])
    }
    
    
    func setInOutStreams(_ channel: CBL2CAPChannel?) {
        guard let channel = channel else {return}
        
        if let currentCAPChan = cbL2CAPChan {
            if currentCAPChan != channel
            {print("cbL2CAPChan will change")}
            if outPutStream != channel.outputStream
            {print("outPutStream will change")}
            if inPutStream != channel.inputStream
            {print("inPutStream will change")}
            outPutStream.close()
            inPutStream.close()
        }
        
        cbL2CAPChan = channel
        outPutStream = channel.outputStream
        outPutStream.delegate = self
        outPutStream.schedule(in: .current, forMode: .default)
        outPutStream.open()
        
        sendInfo.isEnabled = true
        
        inPutStream = channel.inputStream
        inPutStream.delegate = self
        inPutStream.schedule(in: .current, forMode: .default)
        inPutStream.open()
    }
    
    
    @objc func makeAndSendL2CAPInfo() {
        if !outPutStream.hasSpaceAvailable || !sendL2CAPInfo(outPutStream, reportPanel: messagePanel) {
            mustSendData = true
            sendInfo.isEnabled = false
        }
    }
    
    
    // StreamDelegate protocol implementation.
    
    func stream(_ aStream: Stream,
                handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("Stream.Event.hasBytesAvailable")
            receiveL2CAPInfo(inPutStream, reportPanel: messagePanel)
        case Stream.Event.hasSpaceAvailable:
            print("Stream.Event.hasSpaceAvailable")
            if mustSendData && sendL2CAPInfo(outPutStream, reportPanel: messagePanel) {
                mustSendData = false
                sendInfo.isEnabled = true
            }
        case Stream.Event.openCompleted:
            print("Stream.Event.openCompleted")
        case Stream.Event.endEncountered:
            print("Stream.Event.endEncountered")
        case Stream.Event.errorOccurred:
            print("Stream.Event.errorOccurred")
        default:
            print("Stream.Event.SOME-OTHER-THING-HAPPENED")
        }
    }
}
