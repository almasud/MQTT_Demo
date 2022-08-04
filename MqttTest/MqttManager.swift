//
//  MqttManager.swift
//  MqttTest
//
//  Created by Abdullah Almasud on 2/8/22.
//

import Foundation

import CocoaMQTT
import Combine

protocol MqttEeventDelegate: AnyObject {
    func onConnectionStatus(isConnected: Bool)
    func onSubscibe(topics: NSDictionary)
    func onUnsubscribe(topics: [String])
    func onMessageArrived(message: String)
}

final class MQTTManager {
    private var mqttClient: CocoaMQTT?
    private var host: String!
    private var topic: String!
    private var username: String!
    private var password: String!
    var isConnected: Bool = false
    weak var delegate : MqttEeventDelegate? = nil

    // MARK: Shared Instance

    private static let _shared = MQTTManager()

    // MARK: - Accessors

    class func shared() -> MQTTManager {
        return _shared
    }

    func initializeMQTT(host: String, username: String? = nil, password: String? = nil) {
        // If any previous instance exists then clean it
        if mqttClient != nil {
            mqttClient = nil
        }
        self.host = host
        self.username = username
        self.password = password
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)

        // TODO: Guard
        mqttClient = CocoaMQTT(clientID: clientID, host: host, port: 1883)
        // If a server has username and password, pass it here
        if let finalusername = self.username, let finalpassword = self.password {
            mqttClient?.username = finalusername
            mqttClient?.password = finalpassword
        }
        mqttClient?.keepAlive = 60
        mqttClient?.delegate = self
    }

    func connect() {
        mqttClient?.connect()
    }

    func subscribe(topic: String) {
        self.topic = topic
        mqttClient?.subscribe(topic, qos: .qos1)
    }

    func publish(with message: String) {
        mqttClient?.publish(topic, withString: message, qos: .qos1)
    }

    func disconnect() {
        mqttClient?.disconnect()
    }

    /// Unsubscribe from a topic
    func unSubscribe(topic: String) {
        mqttClient?.unsubscribe(topic)
    }

    /// Unsubscribe from a topic
    func unSubscribeFromCurrentTopic() {
        mqttClient?.unsubscribe(topic)
    }
    
    func currentHost() -> String? {
        return host
    }
    
}

extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics topics: NSDictionary, failed: [String]) {
        TRACE("topic: \(topics)")
        delegate?.onSubscibe(topics: topics)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        TRACE("topic: \(topics)")
        delegate?.onUnsubscribe(topics: topics)
    }

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        TRACE("ack: \(ack)")

        if ack == .accept {
            isConnected = true
            delegate?.onConnectionStatus(isConnected: true)
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        TRACE("message: \(String(describing: message.string?.description)), id: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        TRACE("id: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        TRACE("message: \(String(describing: message.string?.description)), id: \(id)")
        if message.string != nil {
            delegate?.onMessageArrived(message: message.string!)
        }
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        TRACE()
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        TRACE()
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        TRACE("\(err.debugDescription)")
        
        isConnected = false
        delegate?.onConnectionStatus(isConnected: false)
    }
}

extension MQTTManager {
    func TRACE(_ message: String = "", fun: String = #function) {
        let names = fun.components(separatedBy: ":")
        var prettyName: String
        if names.count == 1 {
            prettyName = names[0]
        } else {
            prettyName = names[1]
        }

        if fun == "mqttDidDisconnect(_:withError:)" {
            prettyName = "didDisconect"
        }

        print("[TRACE] [\(prettyName)]: \(message)")
    }
}

