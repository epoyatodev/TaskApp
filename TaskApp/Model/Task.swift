//
//  Task.swift
//  TaskApp
//
//  Created by Enrique Poyato Ortiz on 26/5/23.
//

import SwiftUI

struct Task: Identifiable, Codable{
    var id = UUID().uuidString
    var title: String
    var time: Date
}

struct TaskMetaData: Identifiable, Codable{
    var id = UUID().uuidString
    var task: [Task]
    var taskDate: Date
}

func getSampleDate(offset: Int) -> Date {
    let calendar = Calendar.current
    
    let date = calendar.date(byAdding: .day, value: offset, to: Date())
    
    return date ?? Date()
}

var tasks: [TaskMetaData] = [
    TaskMetaData(task: [
        Task(title: "Learn SwiftUI", time: Date())
    ], taskDate: getSampleDate(offset: 1))
]
