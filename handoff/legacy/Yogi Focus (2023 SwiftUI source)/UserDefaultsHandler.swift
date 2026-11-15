//
//  File.swift
//  Yogi Focus
//
//  Created by kartvasu on 14/12/2023.
//

import Foundation

class UserDefaultsHandler: ObservableObject {
    static let shared = UserDefaultsHandler()
    let ONBOARDED = "_onboarded";
    
    private init() {
        UserDefaults.standard.set(false, forKey: ONBOARDED)
    }
}
