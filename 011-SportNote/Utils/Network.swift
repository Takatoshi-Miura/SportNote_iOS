//
//  Network.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/03.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import Reachability

final class Network {

    static func isOnline() -> Bool {
        let reachability = try! Reachability()
        if reachability.connection == .unavailable {
            return false
        } else {
            return true
        }
    }

}
