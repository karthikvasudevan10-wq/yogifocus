//
//  TaskFormSuccess.swift
//  Yogi Focus
//
//  Created by kartvasu on 25/12/2023.
//

import SwiftUI
import SwiftData

struct TaskFormSuccess: View {
    var startTime: Date
    let dateFormatter = DateFormatter()
    @State private var isButtonTouched = false
    @Query() var taskModel: [TaskModel] = [TaskModel]()
    
    var body: some View {
        let taskCount = taskModel.count
        NavigationStack {
            VStack (alignment: .trailing, content: {
                let _ = dateFormatter.dateFormat = "HH:mm"
                OnboardingPage(warp: "Warp_Yellow", yogi: "Yogi_ClosedEye", mainMessage: (taskCount > 1 ? "Task added successfully!" :  "Congrats on setting your first task!") + " Expect a daily reminder 5 mins before it starts. \n\n Ensure you are free from distractions every day at: " + dateFormatter.string(from: startTime)).navigationBarBackButtonHidden()
                Button(action: {
                    self.isButtonTouched = true;
                }, label: {
                    Text("Ok").font(.custom("Inter-Regular", size: 16)).frame(width: 100, height: 80)
                })
                
                .frame(width: 100, height: 80, alignment: .trailing)
                .foregroundColor(.primaryText)
                .background(.primaryButtons)
                .clipShape(AnyShape(Capsule()))
                .padding([.horizontal], 30)
                .padding([.vertical], 10)
            }) // first vstack ending
            .navigationDestination(isPresented: $isButtonTouched, destination: {
//                OnboardingView()
                TaskList().navigationBarBackButtonHidden()
            })
        }
    }
}

#Preview {
    TaskFormSuccess(startTime: Date())
}
