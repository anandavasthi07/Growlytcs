//
//  TrafficSourceInfo.swift
//  Growlytics
//
//  Created by Pradeep Singh on 08/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

final class TrafficSourceInfo {

    private var referrer        : String?
    private var utmInfo         : NSDictionary?

    init(_ referrer: String, _ utmInfo : NSDictionary) {
        self.referrer = referrer;
        self.utmInfo = utmInfo;
    }

    public func getReferrer() -> String {
        return self.referrer!
    }

    public func getUtmInfo() -> NSDictionary {
        return self.utmInfo!
    }
}
