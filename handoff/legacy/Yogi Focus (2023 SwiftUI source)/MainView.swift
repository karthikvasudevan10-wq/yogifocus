//
//  MainView.swift
//  Yogi Focus
//
//  Created by kartvasu on 25/12/2023.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Query() var taskModel: [TaskModel] = [TaskModel]()
    var body: some View {
        let onBoarded = UserDefaults.standard.bool(forKey: "_onboarded")
        let taskCount = taskModel.count
        
        if (onBoarded && taskCount == 0) {
            TaskForm()
        } else if (taskCount > 0) {
            TaskList()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    MainView()
}
