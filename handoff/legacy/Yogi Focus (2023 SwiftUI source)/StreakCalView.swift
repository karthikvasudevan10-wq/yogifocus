//
//  StreakCalView.swift
//  Yogi Focus
//
//  Created by kartvasu on 02/01/2024.
//

import SwiftUI
import SwiftData

struct StreakCalView: View {
    var task: TaskModel;
    var feedback: [FeedbackModel];
    let dateFormatterForWeek = DateFormatter()
    let dateFormatterForDay = DateFormatter()
    let dateFormatterForDate = DateFormatter()
    @State private var feedbackObject: [String: FeedbackModel] = [:]
    @State private var sliderValue = 0.0
    @State private var selectedDate = Date()
    
    @Environment(\.modelContext) private var modelContext
    
    func formatDateWithSuffix(_ date: Date) -> String {
        let dateFormatterReadable = DateFormatter()
        dateFormatterReadable.dateFormat = "d"
        
        let day = dateFormatterReadable.string(from: date)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        
        guard let dayWithSuffix = numberFormatter.string(from: NSNumber(value: Int(day)!)) else {
            return ""
        }
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        
        let month = monthFormatter.string(from: date)
        
        return "\(dayWithSuffix) \(month)"
    }
    
    func takeFeedbackForToday() -> Bool {
        //lets do this later
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: task.taskStartTime)
        let _ = dateFormatterForDate.dateFormat = "YYYY-MM-dd"
        if (dateFormatterForDate.string(from: selectedDate) == dateFormatterForDate.string(from: Date())) {
            if (Date() < date!) {
                return false
            }
        }
        
        return true
    }
    func _createFeedbackObject(_ feedbackModel: [FeedbackModel]) -> [String: FeedbackModel] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        for feedback in feedbackModel {
            feedbackObject[dateFormatter.string(from: feedback.dateSubmited)] = feedback
        }
         
        return feedbackObject
    }
    
    func _addTaskFeedback() -> Void {
        let _ = dateFormatterForDate.dateFormat = "YYYY-MM-dd"
        let feedback = FeedbackModel(id: UUID().uuidString, feedbackScore: Int(sliderValue), dateSubmited: Date(), forDate: selectedDate, task: task)
        modelContext.insert(feedback)
    }

    var body: some View {
        VStack(content: {
            let _ = print(feedback)
            let _ = dateFormatterForWeek.dateFormat = "EEEEEE"
            let _ = dateFormatterForDate.dateFormat = "YYYY-MM-dd"
            Text("Current Streak: 0 days").foregroundStyle(.secondaryText).font(.custom("Inter-Regular", size: 18)).padding([.bottom], 10)
            HStack(content: {
                ForEach(0..<7) { num in
                    let currentDate = Calendar.current.date(byAdding: .day, value: -((-num + 6)), to: Date())
                    if (num != 0) {
                        Spacer()
                    }
                    Text(dateFormatterForWeek.string(from: currentDate!)).font(.custom("Inter-Regular", size: 14)).foregroundStyle(.secondaryText).textCase(.uppercase).frame(width: 34)
                    if (num != 6) {
                        Spacer()
                    }
                }
            }).frame(maxWidth: .infinity)
            
            let _ = dateFormatterForDay.dateFormat = "d"
            HStack(content: {
                ForEach(0..<7) { num in
                    let currentDate = Calendar.current.date(byAdding: .day, value: -((-num + 13)), to: Date()) ?? Date()
                    if (num != 0) {
                        Spacer()
                    }
                
                    Button(action: {
                        self.selectedDate = currentDate
                        
                    }, label: {
                        Text(dateFormatterForDay.string(from: currentDate)).font(.custom("Inter-Regular", size: 14)).foregroundStyle(.inputText).textCase(.uppercase)
                    }).frame(width: 34, height: 34).background((dateFormatterForDate.string(from: selectedDate) == dateFormatterForDate.string(from: currentDate)) ? .selectedDateCalendar : .secondaryText).clipShape(Circle())
                    
                    if (num != 6) {
                        Spacer()
                    }
                }
            }).frame(maxWidth: .infinity)
            
            HStack(content: {
                ForEach(0..<7) { num in
                    let currentDate = Calendar.current.date(byAdding: .day, value: -((-num + 6)), to: Date()) ?? Date()
                    if (num != 0) {
                        Spacer()
                    }
                    VStack(content: {
                        Button(action: {
                            self.selectedDate = currentDate
                        }, label: {
                            Text(dateFormatterForDay.string(from: currentDate)).font(.custom("Inter-Regular", size: 14)).foregroundStyle(.inputText).textCase(.uppercase)
                        }).frame(width: 34, height: 34).background((dateFormatterForDate.string(from: selectedDate) == dateFormatterForDate.string(from: currentDate)) ? .selectedDateCalendar : .secondaryText).clipShape(Circle())
                        if (num == 6) {
                            Circle().fill( .blue ).frame(width: 8, height: 8)
                        }
                    }).frame(height: 50, alignment: .top)
                    if (num != 6) {
                        Spacer()
                    }
                }
            }).frame(maxWidth: .infinity)
            Divider()
            VStack(content: {
                let date = dateFormatterForDate.string(from: selectedDate) == dateFormatterForDate.string(from: Date()) ? "today?" : "on " + formatDateWithSuffix(selectedDate) + "?"
                Text("How did it go " + date).font(.custom("Inter-Regular", size: 18)).foregroundStyle(.secondaryText)
                HStack(content: {
                    VStack(alignment: .center, content: {
                        switch Int(sliderValue) {
                        case 0:
                            Text("😞").font(.system(size: 40))
                            Text("No").font(.custom("Inter-Regular", size: 12)).foregroundStyle(.secondaryText).multilineTextAlignment(.center)
                        case 1:
                            Text("🙂").font(.system(size: 40))
                            Text("Yes, with partial focus").font(.custom("Inter-Regular", size: 12)).foregroundStyle(.secondaryText).multilineTextAlignment(.center)
                        case 2:
                            Text("🥹").font(.system(size: 40))
                            Text("Yes, with full focus and with a positive attitude").font(.custom("Inter-Regular", size: 12)).foregroundStyle(.secondaryText).multilineTextAlignment(.center)
                        default:
                            Text("😞").font(.system(size: 40))
                            Text("No").font(.custom("Inter-Regular", size: 12)).foregroundStyle(.secondaryText).multilineTextAlignment(.center)
                        }
                    }).frame(width: 100, height: 100, alignment: .center)
                    Spacer()
                    Slider(value: $sliderValue, in: 0.0...2.0, step: 1.0).accentColor(.primaryButtons)
                    Spacer()
                    Button(action: {
                        _addTaskFeedback()
                    }, label: {
                        Image(systemName: "plus").foregroundColor(.primaryButtons).frame(width: 35, height: 35)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 3,
                                    style: .continuous
                                )
                                .stroke(.primaryButtons, lineWidth: 1)

                            )
                    })
                    
                })
                
            })
            
        })
        Divider()
    }
}
