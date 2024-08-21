//
//  DateFormatUtility.swift
//  WatchToDoApp
//
//  Created by L_0019 on 2024/08/13.
//

import UIKit

class DateFormatUtility {

    private let df = DateFormatter()

    init(format: String = "yyyy年MM月dd日 HH時mm分ss秒") {
        df.dateFormat = format
        df.locale = Locale(identifier: "ja_JP")
        df.calendar = Calendar(identifier: .gregorian)
    }
    
    public func getString(date: Date) -> String {
        return df.string(from: date)
    }
    
    public func getDate(str: String) -> Date {
        return df.date(from: str) ?? Date()
    }
}
