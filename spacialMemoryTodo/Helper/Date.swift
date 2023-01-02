//
//  Date.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 2/1/23.
//

import Foundation

extension Date {
    func prettyTimeUntil(laterDate: Date) -> String {
        var interval = laterDate.timeIntervalSince(self)

        var isDue: Bool = false
        // if interval < 0, means that the later date is not actually after self
        if interval < 0 {
            isDue = true
        }
        // if the later date is actually before self, then we will append a "-" sign
        // to the end
        let isDueString = isDue ? "-" : ""
        interval = abs(interval)

        let minute: Double = 60
        let hour: Double = minute * 60
        let day: Double = hour * 24
        let week: Double = day * 7
        let year: Double = day * 365.25
        let month: Double = year / 12

        var timeDenominator: Double = 1
        var unitString: String = "?"

        if 0 <= interval, interval < hour { // 0s to 1 hour is specified in minutes
            timeDenominator = minute
            unitString = "min"
        } else if hour <= interval, interval < day { // 1 hour to 1 day is specified in hours
            timeDenominator = hour
            unitString = "hr"
        } else if day <= interval, interval < week { // 1 day to 1 week is specified in days
            timeDenominator = day
            unitString = "day"
        } else if week <= interval, interval < month { // 1 week to 1 month is specified in weeks
            timeDenominator = week
            unitString = "week"
        } else if month <= interval, interval < year { // 1 month to 1 year is specified in months
            timeDenominator = month
            unitString = "month"
        } else if year <= interval { // 1 year onwards is specified in years
            timeDenominator = year
            unitString = "year"
        }

        let dividedByTime = interval/timeDenominator
        let rounded = Int(dividedByTime.rounded(.toNearestOrAwayFromZero))
        let plural = rounded == 1 ? "" : "s"
        return "\(isDueString)\(rounded) \(unitString)\(plural)"
    }
}
