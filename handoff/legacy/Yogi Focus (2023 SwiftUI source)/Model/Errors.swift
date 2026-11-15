//
//  Errors.swift
//  Yogi Focus
//
//  Created by kartvasu on 26/12/2023.
//

import Foundation

enum Errors: LocalizedError {
    case accessDenied
    case accessRestricted
    case unknown
    case saveEventError
    case removeEventError
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return NSLocalizedString(
                "The app doesn't have permission to read reminders.",
                comment: "access denied error description")
        case .accessRestricted:
            return NSLocalizedString(
                "This device doesn't allow access to reminders.",
                comment: "access restricted error description")
        case .unknown:
            return NSLocalizedString("An unknown error occurred.", comment: "unknown error description")
        case .saveEventError:
            return NSLocalizedString("Cannot save your event currently", comment: "Check logs for more information")
        case .removeEventError:
            return NSLocalizedString("Cannot remove your event currently", comment: "Check logs for more information")
        }
    }
}
