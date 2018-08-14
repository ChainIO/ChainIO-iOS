//
//  CIFirestore.swift
//  ChainIO
//
//  Created by Lihao Li on 2018/8/13.
//  Copyright © 2018 Lihao Li. All rights reserved.
//

import UIKit
import Firebase

class CIFirestore: NSObject {
    let sharedInstance = CIFirestore()
    
    var configured = false
    
    var configureCompletionHolders = [CIFirestoreConfigureCompletionHolder]()
    
    private override init() {
        
    }
    
    
    func configure() {
        DispatchQueue.global().async {
            let googleServiceInfoPath = "GoogleService-Info"
            if let filePath = Bundle.main.path(forResource: googleServiceInfoPath, ofType: "plist") {
                if let options = FirebaseOptions(contentsOfFile: filePath) {
                    FirebaseApp.configure(options: options)
                    DispatchQueue.main.async {
                        self.configured = true
                        
                        for configureCompletionHolder in self.configureCompletionHolders {
                            configureCompletionHolder.completionQueue.async {
                                configureCompletionHolder.completion()
                            }
                        }
                        
                        self.configureCompletionHolders.removeAll()
                    }
                }
            }
        }
    }
    
    
    func waitForConfigureWith(completionQueue: DispatchQueue, completion: @escaping () -> ()) {
        DispatchQueue.main.async {
            if self.configured {
                completionQueue.async {
                    completion()
                }
            }else {
                let completionHolder = CIFirestoreConfigureCompletionHolder(completionQueue: completionQueue, completion: completion)
                self.configureCompletionHolders.append(completionHolder)
            }
        }
    }
}


class CIFirestoreConfigureCompletionHolder: NSObject {
    var completionQueue: DispatchQueue
    var completion: () -> ()
    
    init(completionQueue: DispatchQueue, completion: @escaping () -> ()) {
        self.completionQueue = completionQueue
        self.completion = completion
        
        super.init()
    }
}
