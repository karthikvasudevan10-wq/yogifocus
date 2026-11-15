//
//  Feedback.swift
//  Yogi Focus
//
//  Created by kartvasu on 02/01/2024.
//

import SwiftData
import Foundation

@Model
final class FeedbackModel {
    @Attribute(.unique) var id: String = UUID().uuidString
    var feedbackScore: Int
    var dateSubmited: Date
    var forDate: Date
    var task: TaskModel
    
    init(id: String, feedbackScore: Int, dateSubmited: Date, forDate: Date, task: TaskModel) {
        self.id = id
        self.feedbackScore = feedbackScore
        self.dateSubmited = dateSubmited
        self.forDate = forDate
        self.task = task
    }
}
