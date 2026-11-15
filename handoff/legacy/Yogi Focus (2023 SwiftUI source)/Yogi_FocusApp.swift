//
//  Yogi_FocusApp.swift
//  Yogi Focus
//
//  Created by kartvasu on 11/12/2023.
//

import SwiftUI
import SwiftData

@main
struct Yogi_FocusApp: App {
    @Query() var taskModel: [TaskModel] = [TaskModel]()
    var body: some Scene {
        WindowGroup {
            MainView()
        }.modelContainer(for: TaskModel.self)
    }
}
