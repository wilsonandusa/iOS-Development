//
//  ViewController.swift
//  BluetoothConnection
//
//  Created by Xiaosheng Wu on 6/8/16.
//  Copyright © 2016 Xiaosheng Wu. All rights reserved.
//

/**
 1. setup the CBCentralManager
 2. scan()  the peripherals based on service UUID   // didUpadteState()
 3. connect to a peripheral after discovered it     // didDiscoverPeripheral       centralManager?.connectPeripheral
 
 4.
 */

import UIKit
import CoreBluetooth

class BTLECentralViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet private weak var textView: UITextView!
    
    private var centralManager: CBCentralManager?
    private var discoveredPeripheral: CBPeripheral?
    
    //to store the incoming data
    private let data = NSMutableData();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set up the CBCentralNanager
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("Stopping Scan")
        centralManager?.stopScan()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
     Scan for 128 Bit CBUUID devices
    */
    func scan(){
        centralManager?.scanForPeripheralsWithServices(
            [transferServiceUUID], options: [
            CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(bool: true)
            ]
        )
        print("Scaning Started")
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("\(#line) \(#function)")
        guard central.state == .PoweredOn else{
            return
        }
        scan()
    }
    
    /*
     check if a peripheral is discovered check the RSSi, and make sure it is close enough
    */
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        print("Discovered \(peripheral.name) at \(RSSI)")
        
        if discoveredPeripheral != peripheral{
            discoveredPeripheral = peripheral
            print("Connecting to peripheral \(peripheral)")
            
            centralManager?.connectPeripheral(peripheral, options: nil)
        }
        
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect")
        cleanup()
    }
    
    
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Peripheral Connected")
        centralManager?.stopScan()
        print("Scanning Stoped")
        //clear the data
        data.length = 0;
        //make sure the discovery callbacks
        peripheral.delegate = self
        //search only for service that match our UUID
        peripheral.discoverServices([transferServiceUUID])
        
    }
    // the transfer service is discovered
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            cleanup()
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        //discover the characteristic
        for service in services{
            peripheral.discoverCharacteristics([transferCharacteristicUUID], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        guard error == nil else{
            cleanup()
            return
        }
        guard let characteristics = service.characteristics else{
            return
        }
        
        for characteristic in characteristics{
            if characteristic.UUID.isEqual(transferCharacteristicUUID){
                peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            }
        }
    }
    
    
    
    func cleanup(){
        
    }
}


















