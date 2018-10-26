//
//  ReachabilityManager.swift
//  Blocain
//
//  Created by Lihao Li on 2018/10/22.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import Foundation
import Reachability


@objc protocol ReachabilityManagerListenerProtocol: class {
    func reachabilityDidChange(hasNetwork: Bool)
}

class ReachabilityManager: NSObject {
    static let sharedManager = ReachabilityManager()
    
    var listeners = NSHashTable<ReachabilityManagerListenerProtocol>.weakObjects()
    
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .none
    }
    
    var reachabilityStatus: Reachability.Connection = .none
    
    let reachability = Reachability()
    
    
    private override init() {
    }
    
    
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: Notification.Name.reachabilityChanged,
                                               object: reachability)
        do{
            try reachability?.startNotifier()
        } catch {
            debugPrint("Could not start reachability notifier")
        }
    }
    
    
    func stopMonitoring(){
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.reachabilityChanged,
                                                  object: reachability)
    }
    
    
    func addListener(_ listener: ReachabilityManagerListenerProtocol) {
        listeners.add(listener)
    }
    
    
    func removeListener(_ listener: ReachabilityManagerListenerProtocol) {
        listeners.remove(listener)
    }
    
    
    @objc func reachabilityChanged(notification: Notification) {
        let enumerator = listeners.objectEnumerator()
        let reachability = notification.object as! Reachability
        switch reachability.connection {
        case .none:
            while let next = enumerator.nextObject() as? ReachabilityManagerListenerProtocol {
                next.reachabilityDidChange(hasNetwork: false)
            }
            break
        default:
            while let next = enumerator.nextObject() as? ReachabilityManagerListenerProtocol {
                next.reachabilityDidChange(hasNetwork: true)
            }
            break
        }
    }
}
