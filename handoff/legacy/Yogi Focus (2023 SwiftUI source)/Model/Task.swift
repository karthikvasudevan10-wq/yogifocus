//
//  Task.swift
//  Yogi Focus
//
//  Created by kartvasu on 25/12/2023.
//
import SwiftData
import Foundation

@Model
final class TaskModel {
    @Attribute(.unique) var id: String = UUID().uuidString
    var taskName: String
    var taskDetails: String
    var taskTag: String
    var taskStartTime: String
    var taskLocation: String
    var eventIdentifier: String
    
    @Relationship(deleteRule: .cascade, inverse: \FeedbackModel.task)
    var feedback = [FeedbackModel]()
    
    init(taskName: String, taskDetails: String, taskTag: String, taskStartTime: String, taskLocation: String, eventIdentifier: String) {
        self.taskName = taskName
        self.taskDetails = taskDetails
        self.taskTag = taskTag
        self.taskStartTime = taskStartTime
        self.taskLocation = taskLocation
        self.eventIdentifier = eventIdentifier
    }
}
