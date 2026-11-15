//
//  TaskList.swift
//  Yogi Focus
//
//  Created by kartvasu on 25/12/2023.
//

import SwiftUI
import SwiftData
import EventKit

struct TaskList: View {
    @Query() var taskModel: [TaskModel] = [TaskModel]()
    @State private var isAddBtnPressed = false
    @State private var viewToggle: String = UserDefaults.standard.string(forKey: "_viewToggle") ?? "Tab"
    @Environment(\.modelContext) private var modelContext
    
    let category = ["Physical Health", "Mental Health", "Relationship", "Self-improvement", "Learning", "Financial", "Time Management", "Eating", "Productivity"]
    let categoryColor:[Color] = [.tagPH, .tagMH, .tagR, .tagSI, .tagL, .tagF, .tagTM, .tagE, .tagP]
    
    func deleteTask(_ indexSet: IndexSet) -> Void {
        Task {
            for index in indexSet {
                let event: EKEvent? = try await EventStore.shared.getEventByEventIdentifier(identifier: taskModel[index].eventIdentifier)
                if (event != nil) {
                    _ = try await EventStore.shared.removeEventByEventIdentifier(event: event!)
                }
                modelContext.delete(taskModel[index])
            }
        }
    }
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, content: {
                HStack(alignment: .top, content: {
                    Button(action: {
                        self.viewToggle = self.viewToggle == "Tab" ? "List" : "Tab"
                        UserDefaults.standard.set(self.viewToggle, forKey: "_viewToggle")
                    }, label: {
                        Image(systemName: self.viewToggle == "Tab" ? "list.dash" : "square.stack").frame(width: 30, height: 30)
                    })
                        .foregroundColor(.primaryText)
                        .buttonStyle(.bordered).buttonBorderShape(.roundedRectangle).controlSize(.regular)
//                        .background(.primaryButtons)
//                        .clipShape(AnyShape(RoundedRectangle(cornerRadius: 5)))
                }).padding([.horizontal], 30).frame(maxWidth: .infinity, alignment: .trailing)
                
                
                switch viewToggle {
                case "Tab":
                    TabView(content: {
                        ForEach(Array(taskModel.enumerated()), id: \.element) { index, TaskModel in
                            TaskPage(task: TaskModel, tagColor: categoryColor[category.firstIndex(of: TaskModel.taskTag)!])
                        }
                    })
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                case "List":
                    List(content: {
                        ForEach(taskModel) { TaskModel in
                            VStack(content: {
                                HStack(content: {
                                    Text(TaskModel.taskName).font(.custom("Tiro Devanagari Sanskrit", size: 30)).foregroundColor(.primaryText)
                                    Spacer()
                                    HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                                        Image(systemName: "clock.arrow.2.circlepath").foregroundStyle(.secondaryText)
                                        Text(TaskModel.taskStartTime).font(.custom("Inter-Regular", size: 20)).foregroundStyle(.secondaryText)
                                    })
                                }).padding([.bottom], 8)
                                Text(TaskModel.taskDetails).font(.custom("Inter-Regular", size: 16)).foregroundStyle(.primaryText).frame(maxWidth: .infinity, alignment: .leading).padding([.bottom], 8)
                                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                                    HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                                        Image(systemName: "mappin.and.ellipse").foregroundStyle(.secondaryText)
                                        Text(TaskModel.taskLocation).font(.custom("Inter-Regular", size: 16)).foregroundStyle(.secondaryText)
                                    })
                                    Spacer()
                                    ZStack(content: {
                                        RoundedRectangle(cornerRadius: 5).foregroundStyle(categoryColor[category.firstIndex(of: TaskModel.taskTag)!]).frame(width: 150, height: 30)
                                        Text(TaskModel.taskTag).font(.custom("Inter-Regular", size: 16)).foregroundStyle(.white)
                                    })
                                })
                            })
                        }
                        
                        .onDelete(perform: { indexSet in
                            deleteTask(indexSet)
                        })
                        
                    })
                default:
                    TabView(content: {
                        ForEach(Array(taskModel.enumerated()), id: \.element) { index, TaskModel in
                            TaskPage(task: TaskModel, tagColor: categoryColor[category.firstIndex(of: TaskModel.taskTag)!])
                        }
                    })
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                }
                
                
                HStack(alignment: .center) {
                    Button(action: {
                        self.isAddBtnPressed = true;
                    }, label: {
                        Image(systemName: "plus").frame(width: 80, height: 80)
                    })
                    .frame(width: 80, height: 80)
                        .foregroundColor(.primaryText)
                        .background(.primaryButtons)
                        .clipShape(AnyShape(Circle()))
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
            }) // vstack close
            .navigationDestination(isPresented: $isAddBtnPressed, destination: {
                TaskForm()
            })
        } // navi stack close
    }
}

#Preview {
    TaskList()
}
