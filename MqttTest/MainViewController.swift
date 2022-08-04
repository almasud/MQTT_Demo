//
//  ViewController.swift
//  MqttTest
//
//  Created by Abdullah Almasud on 2/8/22.
//

import UIKit
import CocoaMQTT

class MainViewController: UIViewController {

    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var subscribeTopicTF: UITextField!
    @IBOutlet weak var messageTV: UITextView!
    @IBOutlet weak var publishMessageTF: UITextField!
    private var mqttManger: MQTTManager = MQTTManager.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("MainViewController: viewDidLoad is called.")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mqttManger.delegate = self
        updateStatusView(isConnected: mqttManger.isConnected)
        
        print("MainViewController: viewDidAppear is called.")
    }
    
    @IBAction func subscribeTopic(_ sender: UIButton) {
        if subscribeTopicTF.text != nil {
            mqttManger.subscribe(topic: subscribeTopicTF.text!)
        }
    }
    
    @IBAction func publishMessage(_ sender: UIButton) {
        if publishMessageTF.text != nil {
            mqttManger.publish(with: publishMessageTF.text!)
            publishMessageTF.text = ""
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

extension MainViewController: MqttEeventDelegate {
    func onConnectionStatus(isConnected: Bool) {
        updateStatusView(isConnected: isConnected)
    }
    
    func onSubscibe(topics: NSDictionary) {
        
    }
    
    func onUnsubscribe(topics: [String]) {
        
    }
    
    func onMessageArrived(message: String) {
        print("onMessageArrived is called")
        
        messageTV.text = message
    }
    
    
}

