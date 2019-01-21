//
//  L2C_Peripheral_ViewController.swift
//  L2CAPC
//
//  Created by Michel Bouchet on 2019/01/21.
//  Copyright © 2019 Michel Bouchet. All rights reserved.
//

import UIKit
import CoreBluetooth

class L2C_Peripheral_ViewController: L2CAPC_ViewController,CBPeripheralManagerDelegate {
    var cbPerifMngr:CBPeripheralManager!, mutaSRVC:CBMutableService!,
    svcCharac:CBMutableCharacteristic!, subscribCentrals:[CBCentral]!,
    l2capPSM:CBL2CAPPSM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Peripheral"
        cbPerifMngr = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    
    func updateSubscribersL2CAPSM() {
        if let data = "\(l2capPSM!)".data(using: .utf8) {
            svcCharac.value = data
            cbPerifMngr.updateValue(data, for: svcCharac,
                                    onSubscribedCentrals: subscribCentrals)
        }
    }
    
    
    // CBPeripheralManagerDelegate protocol implementation.
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print(#function)
        if peripheral.state == .poweredOn {
            mutaSRVC = CBMutableService(type: service_UUID, primary: true)
            svcCharac = CBMutableCharacteristic(type: svcCharac_UUID,
                                                properties: [.read, .notify],
                                                value: nil,
                                                permissions: .readable)
            mutaSRVC.characteristics = [svcCharac]
            cbPerifMngr?.add(mutaSRVC)
            cbPerifMngr?.publishL2CAPChannel(withEncryption: false)
        }
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print(#function)
        if error != nil {
            print("Error in \(#function) :\n\(error!)")
            return
        }
        
        cbPerifMngr.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[service.uuid]])
    }
    
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print(#function)
        if error != nil {
            print("Error in \(#function) :\n\(error!)")
            return
        }
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           central: CBCentral,
                           didSubscribeTo characteristic: CBCharacteristic) {
        print(#function)
        if subscribCentrals == nil {subscribCentrals = [CBCentral]()}
        subscribCentrals.append(central)
        
        guard let _ = l2capPSM else {return}
        
        updateSubscribersL2CAPSM()
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didPublishL2CAPChannel PSM: CBL2CAPPSM,
                           error: Error?) {
        print(#function)
        if error != nil {
            print("Error in \(#function) :\n\(error!)")
            return
        }
        
        psmLabel.text = "PSM = \(PSM)"
        print("PSM: \(PSM)")
        l2capPSM = PSM
        
        guard let _ = subscribCentrals, subscribCentrals.count > 0
            else {return}
        
        updateSubscribersL2CAPSM()
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didOpen channel: CBL2CAPChannel?,
                           error: Error?) {
        print(#function)
        if error != nil {
            print("Error in \(#function) :\n\(error!)")
            return
        }
        
        setInOutStreams(channel)
    }
}
