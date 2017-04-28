//
//  MMPixelSdk.swift
//  MMPixelSdk

//  Copyright © 2017 MediaMath. All rights reserved.
//

import Foundation
import AdSupport

// We declare this here because there isn't any support yet for class var / class let
let globalSdk = MMPixelSdk();


public class MMPixelSdk {
    
    lazy private var session = URLSession()
    private var isDebug = false
    
    
    public static func setDebugOutput(debug: Bool) {
        globalSdk.isDebug = debug
    }
    
    
    public static func getDebugOutput() -> Bool {
        return globalSdk.isDebug
    }
    
    
    public static func report(advertiser: String, pixel: String, addlParams: String? = nil) {
        let adv = Int(advertiser)!
        let pix = Int(pixel)!
        report(advertiser: adv, pixel: pix, addlParams: addlParams)
    }
    
    
    public static func report(advertiser: Int, pixel: Int, addlParams: String? = nil) {
        let urlString = globalSdk.getPixelUrl(advertiser: advertiser, pixel: pixel, addlParams: addlParams)
        let pixelUrl = URL(string: urlString)
        
        if (globalSdk.isDebug) {
            print("MMPixelSdk firing " + urlString)
        }
        
        let task = URLSession.shared.dataTask(with: pixelUrl!) {(data, response, error) in
            if error != nil {
                print(error!)
            } else {
                if let usableData = data {
                    print(usableData)
                }
            }
        }
        
        task.resume()
    }
    
    
    func getPixelUrl(advertiser: Int, pixel: Int, addlParams : String?) -> String {
        let timeNow = UInt64(NSDate().timeIntervalSince1970)
        let mmFormat = MMPixelConfig.MM_MATHTAG_URL
        
        var urlString = String(format: mmFormat, arguments: [advertiser, pixel, timeNow])
        
        urlString += getTrackingParams(optedOut: isUserOptedOut());
        if ((addlParams) != nil) {
            urlString += "&" + addlParams!
        }
        
        return urlString
    }
    
    
    func isUserOptedOut() -> Bool {
        return !ASIdentifierManager.shared().isAdvertisingTrackingEnabled
    }
    
    
    func getTrackingParams(optedOut: Bool) -> String {
        let idfa: String
        if optedOut {
            // use a random UUID
            idfa = NSUUID().uuidString + "&optout=1"
        }
        else {
            // use the IDFA
            if let idfaUuuid = ASIdentifierManager.shared().advertisingIdentifier {
                idfa = idfaUuuid.uuidString
            }
            else {
                idfa = NSUUID().uuidString
            }
        }
        
        
        return "?mt_uuid=" + idfa
        
    }
}