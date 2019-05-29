//
//  funcs.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 29/05/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit
func isInternetAvailable() -> Bool
{
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags = SCNetworkReachabilityFlags()
    
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    return (isReachable && !needsConnection)
}

func DisplayWarnining (warning: String, title: String, dismissing: Bool, sender: Any) -> Void {
    DispatchQueue.main.async {
        let warningController = UIAlertController(title: title, message: warning, preferredStyle: .alert)
        
        let buttonAction = UIAlertAction(title: "Got it!", style: .default)
        { (action: UIAlertAction!) in
            DispatchQueue.main.async {
                warningController.dismiss(animated: true, completion: nil)
                if dismissing == true {
                    (sender as AnyObject).navigationController?.popViewController(animated: true)
                    (sender as AnyObject).dismiss(animated: true, completion: nil)
                }
            }
        }
        warningController.addAction(buttonAction)
        (sender as AnyObject).present(warningController, animated: true, completion: nil)
    }
    
}
