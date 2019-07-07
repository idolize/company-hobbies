//
//  Utils.swift
//  Hobbies
//
//  Created by David Idol on 7/6/19.
//  Copyright © 2019 David Idol. All rights reserved.
//

import UIKit

extension String {
    
    func camelCaseToWords() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                if $0.count > 0 {
                    return ($0 + " " + String($1))
                }
            }
            return $0 + String($1)
        }
    }
}

