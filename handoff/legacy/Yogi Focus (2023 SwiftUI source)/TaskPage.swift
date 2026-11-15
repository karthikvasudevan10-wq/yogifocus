//
//  TaskPage.swift
//  Yogi Focus
//
//  Created by kartvasu on 25/12/2023.
//

import SwiftUI
import SwiftData
import EventKit

struct TaskPage: View {
    var task: TaskModel;
    var tagColor: Color;
    @State private var showAlert = false
    @State private var feedbackObject: [String: [FeedbackModel]] = [:]
    @Query() var taskModel: [TaskModel] = [TaskModel]()
    @Query() var taskFeedback: [FeedbackModel] = [FeedbackModel]()
    @Environment(\.modelContext) private var modelContext
    
    func deleteTask() -> Void {
        Task {
            let event: EKEvent? = try await EventStore.shared.getEventByEventIdentifier(identifier: task.eventIdentifier)
            if (event != nil) {
                _ = try await EventStore.shared.removeEventByEventIdentifier(event: event!)
            }
            modelContext.delete(task)
        }
    }
    func _createFeedbackObject() -> Void {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        for feedback in taskFeedback {
            if (feedbackObject[feedback.task.id as String] == nil) {
                feedbackObject[feedback.task.id as String] = []
            }
            
            feedbackObject[feedback.task.id as String]?.append(feedback)
        }
    }
    var body: some View {
        
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
            
            HStack(content: {
                
            }).onAppear(perform: {
                let _ =  _createFeedbackObject()
            })
            HStack(content: {
                HStack(content: {
                    Text(task.taskName).font(.custom("Tiro Devanagari Sanskrit", size: 40)).foregroundColor(.primaryText)
                    Button(action: {
                        self.showAlert = true
                    }, label: {
                        Image(systemName: "trash").frame(width: 30, height: 30)
                            .foregroundColor(.primaryText)
                            
                    }).alert(LocalizedStringKey("Delete?"), isPresented: $showAlert, actions: {
                        Button(String("Delete"), role: .destructive) {
                            self.deleteTask()
                        }
                        Button(String("Cancel"), role: .cancel) {}
                    }, message: {
                        Text("Are you certain about deleting this task? Doing so will result in the loss of your streak information associated with this task.")
                    })
                })
                
                Spacer()
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Image(systemName: "clock.arrow.2.circlepath").foregroundStyle(.secondaryText)
                    Text(task.taskStartTime).font(.custom("Inter-Regular", size: 16)).foregroundStyle(.secondaryText)
                })
            }).padding([.bottom], 10)
            Text(task.taskDetails).font(.custom("Inter-Regular", size: 24)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.primaryText).padding([.bottom], 15)
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Image(systemName: "mappin.and.ellipse").foregroundStyle(.secondaryText)
                    Text(task.taskLocation).font(.custom("Inter-Regular", size: 16)).foregroundStyle(.secondaryText)
                })
                Spacer()
                ZStack(content: {
                    RoundedRectangle(cornerRadius: 5).foregroundStyle(tagColor).frame(width: 180, height: 30)
                    Text(task.taskTag).font(.custom("Inter-Regular", size: 16)).foregroundStyle(.white)
                })
            }).padding([.bottom], 30)
            Divider()
            if feedbackObject.keys.count > 0 {
                let taskById = (feedbackObject[task.id]) as [FeedbackModel]?
                StreakCalView(task: task, feedback: taskById!).padding([.bottom], 15)
            }
//            StreakCalView(task: task, feedback: taskById!).padding([.bottom], 15)
            
        }).padding([.horizontal], 30)
    }
}
