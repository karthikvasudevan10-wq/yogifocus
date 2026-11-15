//
//  Temp.swift
//  Yogi Focus
//
//  Created by kartvasu on 26/12/2023.
//

import SwiftUI
import EventKit

struct Temp: View {
    var body: some View {
        VStack {
            Button("Set Yoga Reminder") {
                setYogaReminder()
            }
        }
    }

    func setYogaReminder() {
        let eventStore = EKEventStore()

        // Request access to the event store
        eventStore.requestFullAccessToEvents() { (granted, error) in
            let _ = print(granted)
            let ff = print(error)
            if granted && error == nil {
                // Access granted, create and save the reminder
                let reminder = EKReminder(eventStore: eventStore)
                reminder.title = "Yoga Practice"
                reminder.notes = "Time for daily yoga practice"
                reminder.calendar = eventStore.defaultCalendarForNewReminders()

                // Set the reminder time to 8:30 AM
                let alarmDate = Calendar.current.date(bySettingHour: 12, minute: 40, second: 0, of: Date())
                let alarm = EKAlarm(absoluteDate: alarmDate!)
                reminder.addAlarm(alarm)

                do {
                    try eventStore.save(reminder, commit: true)
                    print("Yoga reminder set successfully!")
                } catch {
                    print("Error setting yoga reminder: \(error.localizedDescription)")
                }
            } else {
                print("Access to reminders not granted.")
            }
        }
    }
}

#Preview {
    Temp()
}
