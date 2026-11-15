//
//  TaskForm.swift
//  Yogi Focus
//
//  Created by kartvasu on 14/12/2023.
//

import SwiftUI
import SwiftData

struct TaskForm: View {
    @State private var taskName: String = ""
    @State private var taskDetails: String = ""
    @State private var taskCategory: String = "Physical Health"
    @State private var startTime: Date = Date()
    @State private var location: String = ""
    @State private var isFormSubmitted = false
    let dateFormatter = DateFormatter()
    @Environment(\.modelContext) private var modelContext
    let catregory = ["Physical Health", "Mental Health", "Relationship", "Self-improvement", "Learning", "Financial", "Time Management", "Eating", "Productivity"]
    @FocusState private var taskNameFocused: Bool;
    @Query() var taskModel: [TaskModel] = [TaskModel]()
    
    private func _isValid() -> Bool {
        return !self.taskName.isEmpty && !self.taskDetails.isEmpty && !self.location.isEmpty
    }
    
    private func _addTask(eventIdentifier: String) {
        dateFormatter.dateFormat = "HH:mm"
        let task = TaskModel(taskName: self.taskName, taskDetails: self.taskDetails, taskTag: self.taskCategory, taskStartTime: dateFormatter.string(from: self.startTime), taskLocation: self.location, eventIdentifier: eventIdentifier)
        modelContext.insert(task)
    }
    
    var body: some View {
        let taskCount = taskModel.count
        NavigationStack {
            VStack(alignment: .trailing, content: {
                Form {
                    VStack(alignment: .trailing, content: {
                        VStack(alignment: .center, content: {
                            Image("Yogi_Normal").resizable().frame(width: 49, height: 80)
                            Text(taskCount == 0 ? "Add your first 10-minute task" : "Add another task")
                                .font(.custom("Inter-Regular", size: 24, relativeTo: .title))
                                .lineSpacing(/*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primaryText)
                        }).frame(maxWidth: .infinity)
                        
                        Section(footer: Text("Eg. Meditate").font(.custom("Inter-Regular", size: 12)).foregroundColor(.secondaryText), content: {
                            TextField("", text: $taskName, prompt: Text("Task Name").foregroundColor(.secondaryText))
                                .frame(height: 52).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                                .textFieldStyle(PlainTextFieldStyle())
                                .focused($taskNameFocused, equals: true)
                                .foregroundColor(.inputText)
                                .background(.tertiaryText)
                                .font(.custom("Inter-Regular", size: 20))
                        })
                        Section(footer: Text("Eg. Meditation enhances my focus. I'll close my eyes, centring on my forehead, practicing mindful breathing.").font(.custom("Inter-Regular", size: 12)).foregroundColor(.secondaryText), content: {
                            TextField("", text: $taskDetails, prompt: Text("Be more precise").foregroundColor(.secondaryText), axis: .vertical)
                                .lineSpacing(10.0)
                                .lineLimit(6...)
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                .textFieldStyle(PlainTextFieldStyle())
                                .focused($taskNameFocused, equals: true)
                                .foregroundColor(.inputText)
                                .background(.tertiaryText)
                                .font(.custom("Inter-Regular", size: 20))
                        })
                        Section(footer: Text("Eg. Mental Health").font(.custom("Inter-Regular", size: 12)).foregroundColor(.secondaryText), content: {
                            HStack(alignment: .center, spacing: 0, content: {
                                Text("Tag:").foregroundStyle(.secondaryText).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)).font(.custom("Inter-Regular", size: 20)).frame( alignment: .leading)
                                Picker("", selection: $taskCategory) {
                                    ForEach(catregory, id: \.self) {
                                        Text($0).font(.custom("Inter-Regular", size: 20));
                                    }
                                }.pickerStyle(.menu).fixedSize().tint(.inputText).frame(maxWidth: .infinity, alignment: .leading)
                            }).frame(height: 52).background(.tertiaryText)
                        })
                        Section(footer: Text("Eg. 8:30").font(.custom("Inter-Regular", size: 12)).foregroundColor(.secondaryText), content: {
                            HStack(alignment: .center, spacing: 0, content: {
                                Text("Start Time:").foregroundStyle(.secondaryText).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)).font(.custom("Inter-Regular", size: 20)).frame( alignment: .leading)
                                DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute).fixedSize().colorMultiply(.inputText).frame(maxWidth: .infinity, alignment: .leading).onAppear {
                                    UIDatePicker.appearance().minuteInterval = 5
                                }
                            }).frame(height: 52).background(.tertiaryText)
                        })

                        Section(footer: Text("Eg. At my attic").font(.custom("Inter-Regular", size: 12)).foregroundColor(.secondaryText), content: {
                            TextField("", text: $location, prompt: Text("Location").foregroundColor(.secondaryText))
                                .frame(height: 52).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(.inputText)
                                .background(.tertiaryText)
                                .font(.custom("Inter-Regular", size: 20))
                        });
                    }).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }.formStyle(.grouped) // form ending
               Button(action: {
                   Task {
                       let eventAccess = try await EventStore.shared.requestAccess();
                       print(eventAccess)
                       if (eventAccess) {
                           dateFormatter.dateFormat = "HH:mm"
                           let eventIdentifier = try await EventStore.shared.saveEvent(taskName: self.taskName, taskDetails: self.taskDetails, taskStartTime: dateFormatter.string(from: self.startTime))
                           self._addTask(eventIdentifier: eventIdentifier as! String);
                           self.isFormSubmitted = true
                       }
                   }
               }, label: {
                   Text("Set").font(.custom("Inter-Regular", size: 16)).frame(width: 100, height: 80)
               })
               .frame(width: 100, height: 80, alignment: .trailing)
               .foregroundColor(.primaryText)
               .background(self._isValid() ? .primaryButtons : .secondaryText)
               .clipShape(AnyShape(Capsule()))
               .padding([.horizontal], 30)
               .padding([.vertical], 10)
               .disabled(!self._isValid())
            }) // first vstack ending
            .navigationDestination(isPresented: $isFormSubmitted, destination: {
                TaskFormSuccess(startTime: self.startTime).navigationBarBackButtonHidden()
            })
        } // navigation stack ending
    }
}

#Preview {
    TaskForm()
}
