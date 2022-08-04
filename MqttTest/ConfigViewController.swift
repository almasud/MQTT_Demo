//
//  ConfigViewController.swift
//  MqttTest
//
//  Created by Abdullah Almasud on 3/8/22.
//

import UIKit

class ConfigViewController: UIViewController {
    
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var hostUrlTF: UITextField!
    private var mqttManger: MQTTManager = MQTTManager.shared()
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        
        print("ConfigViewController: viewDidLoad is called.")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mqttManger.delegate = self
        updateStatusView(isConnected: mqttManger.isConnected)
        
        print("ConfigViewController: viewDidAppear is called.")
    }
    
    
    @IBAction func connectMqtt(_ sender: UIButton) {
        if hostUrlTF?.text != nil {
            mqttManger.initializeMQTT(host: hostUrlTF.text!)
            mqttManger.connect()
        } else {
            print("hostTF is nil")
        }
    }
    
    private func updateStatusView(isConnected: Bool) {
        if isConnected {
            print("Connected")
            labelStatus.text = "Connected"
            labelStatus.backgroundColor = UIColor.green
        } else {
            print("Disconnected")
            labelStatus.text = "Disconnected"
            labelStatus.backgroundColor = UIColor.red
        }
    }
    
}

extension ConfigViewController: MqttEeventDelegate {
    func onConnectionStatus(isConnected: Bool) {
        updateStatusView(isConnected: isConnected)
    }
    
    func onSubscibe(topics: NSDictionary) {
        
    }
    
    func onUnsubscribe(topics: [String]) {
        
    }
    
    func onMessageArrived(message: String) {
        
    }
    
    
}
