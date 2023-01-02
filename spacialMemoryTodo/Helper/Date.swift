//
//  Date.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 2/1/23.
//

import Foundation

extension Date {
    func prettyTimeUntil(laterDate: Date) -> String {
        let interval = laterDate.timeIntervalSince(self)

        // if interval < 0, means that the later date is not actually after self
        guard interval >= 0 else {
            return "Due"
        }

        let minute: Double = 60
        let hour: Double = minute * 60
        let day: Double = hour * 24
        let week: Double = day * 7
        let year: Double = day * 365.25
        let month: Double = year / 12

        // 0s to 30 minutes is specified in minutes, rounded up
        if 0 <= interval, interval < minute*30 {
            return "\(Int((interval/minute).rounded(.awayFromZero))) mins"
        }
        // 30 minutes to 1 day is specified in hours, rounded up
        if minute*30 <= interval, interval < day {
            return "\(Int((interval/hour).rounded(.awayFromZero))) hrs"
        }
        // 1 day to 1 week is specified in days, rounded up
        if day <= interval, interval < week {
            return "\(Int((interval/day).rounded(.awayFromZero))) days"
        }
        // 1 week to 1 month is specified in weeks, rounded to the nearest week
        if week <= interval, interval < month {
            return "\(Int((interval/week).rounded(.toNearestOrAwayFromZero))) weeks"
        }
        // 1 month to 1 year is specified in months, rounded to the nearest month
        if month <= interval, interval < year {
            return "\(Int((interval/month).rounded(.toNearestOrAwayFromZero))) months"
        }
        // 1 year onwards is specified in years, rounded to the nearest year
        if year <= interval {
            return "\(Int((interval/year).rounded(.toNearestOrAwayFromZero))) years"
        }

        return "?"
    }
}
