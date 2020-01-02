//
//  FetchStatus.swift
//  Hobbies
//
//  Created by David Idol on 7/7/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import Foundation

enum CrudOperation {
    case create
    case read
    case update
    case delete
}

struct FetchStatus {
    static let notFetched = FetchStatus()
    static let completed = FetchStatus(needsRefetch: false)
    static let pendingRead = FetchStatus(pendingOperation: .read)
    
    var pendingOperation: CrudOperation? = nil
    var needsRefetch: Bool = true
    var error: Error? = nil
    
    var isFetching: Bool {
        return pendingOperation == .read
    }
    
    var isPending: Bool {
        return pendingOperation != nil
    }
    
    var isDoneFetching: Bool {
        return !needsRefetch && pendingOperation == nil
    }
}
