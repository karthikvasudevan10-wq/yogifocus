//
//  ReminderStore.swift
//  Yogi Focus
//
//  Created by kartvasu on 26/12/2023.
//

/*
 See LICENSE folder for this sample’s licensing information.
 */

import EventKit
import Foundation

class EventStore {
    static let shared = EventStore()
    private let ekStore = EKEventStore()

    var isAvailable: Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }

    public func requestAccess() async throws -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        print(status);
        switch status {
            case .authorized:
                return true
            case .restricted:
                throw Errors.accessRestricted
            case .notDetermined:
                let accessGranted = try await ekStore.requestFullAccessToEvents()
            print(accessGranted)
                guard accessGranted else {
                    throw Errors.accessDenied
                }
                return true
            case .denied:
                throw Errors.accessDenied
            case .fullAccess:
                return true
            case .writeOnly:
                return true
            @unknown default:
                throw Errors.unknown
        }
    }
    
    public func saveEvent(taskName: String, taskDetails: String, taskStartTime: String) async throws -> Any {
        guard isAvailable else {
            throw Errors.accessDenied
        }
        let defaultCalendar: EKCalendar = ekStore.defaultCalendarForNewEvents!;
        let startTime = taskStartTime.components(separatedBy: ":");
        let date = Calendar.current.date(bySettingHour: Int(startTime[0])!, minute: Int(startTime[1])!, second: 0, of: Date())!
        
        let newEvent = EKEvent(eventStore: ekStore)
        newEvent.availability = .busy
        newEvent.startDate = date
        newEvent.endDate = Calendar.current.date(byAdding: .minute, value: 10, to: date)
        newEvent.isAllDay = false
        newEvent.title = "Yogi Focus: " + taskName
        newEvent.notes = taskDetails
        newEvent.calendar = defaultCalendar
        
        let newRecurring = EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: .none)
        newEvent.addRecurrenceRule(newRecurring)
        
        
        let newAlarm = EKAlarm()
        newAlarm.relativeOffset = -300
//        let newSecondAlarm = EKAlarm()
//        newSecondAlarm.relativeOffset = 600
        
        newEvent.addAlarm(newAlarm)
        
        
        
        let newSpan = EKSpan.futureEvents;
        
        do {
            try ekStore.save(newEvent, span: newSpan, commit: true)
            print("Yoga reminder set successfully!")
            return newEvent.eventIdentifier as Any
        } catch {
            print("Error setting event: \(error.localizedDescription)")
            throw Errors.saveEventError
        }
    }
    
    public func getEventByEventIdentifier(identifier: String) async throws -> EKEvent? {
        return ekStore.event(withIdentifier: identifier)
    }
    
    public func removeEventByEventIdentifier(event: EKEvent) async throws -> Any {
        do {
            try ekStore.remove(event, span: EKSpan.futureEvents, commit: true)
            print("Event deleted successfully")
            return true
        } catch {
            print("Error removing event: \(error.localizedDescription)")
            throw Errors.removeEventError
        }
    }
}
