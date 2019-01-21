//
//  L2C_Central_ViewController.swift
//  L2CAPC copy
//
//  Created by Michel Bouchet on 2019/01/21.
//  Copyright © 2019 Michel Bouchet. All rights reserved.
//

import UIKit
import CoreBluetooth

class L2C_Central_ViewController: L2CAPC_ViewController,CBCentralManagerDelegate,CBPeripheralDelegate {
    var cbCenterMngr:CBCentralManager!, cbPerifHandle:CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Central"
        cbCenterMngr = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    // CBCentralManagerDelegate protocol implementation.
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(#function)
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: [service_UUID],
                                       options: nil)
        }
    }
    
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        print(#function)
        peripheral.delegate = self
        cbPerifHandle = peripheral
        central.connect(peripheral, options: nil)
        central.stopScan()
    }
    
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        print(#function)
        peripheral.discoverServices([service_UUID])
    }
    
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        print(#function)
        if error != nil {
            print("Error in \(#function) :\n\(error!)")
            return
        }
        
        central.connect(peripheral, options: nil)
    }
    
    
    // CBPeripheralDelegate protocol implementation.
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(#function)
        if error != nil {
            print("Error in \(#function) :\n\(error!)")
            return
        }
        
        for service in peripheral.services ?? [] {
            print("Discovered service \(service)")
            if service.uuid == service_UUID {
                peripheral.discoverCharacteristics([svcCharac_UUID], for: service)
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor
        service: CBService, error: Error?) {
        print(#function)
        if error != nil {
            print("Error in \(#function) :\n\(error!)")
            return
        }
        
        for characteristic in service.characteristics ?? [] {
            print("Discovered characteristic \(characteristic)")
            if characteristic.uuid ==  svcCharac_UUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        print(#function)
        print("characteristic : \(characteristic) \n\(characteristic.uuid)")
        if error != nil {
            print("Error in \(#function) :\n\(error!)")
            return
        }
        
        
        print("Read characteristic \(characteristic)")
        
        if let dataValue = characteristic.value, let string = String(data: dataValue, encoding: .utf8), let psm = UInt16(string) {
            print("Opening channel \(psm)")
            cbPerifHandle.openL2CAPChannel(psm)
            psmLabel.text = "PSM = \(psm)"
        } else {
            print("Problem decoding PSM")
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral,
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
