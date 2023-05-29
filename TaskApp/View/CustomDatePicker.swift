//
//  CustomDatePicker.swift
//  TaskApp
//
//  Created by Enrique Poyato Ortiz on 26/5/23.
//

import SwiftUI

struct CustomDatePicker: View {
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @Binding var currentDate: Date
    @State var currentMonth: Int = 0
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 35){
            
            HStack(spacing: 20){
                
                VStack(alignment: .leading, spacing: 10){
                    
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(extraDate()[1])
                        .font(.title.bold())
                }
                Spacer(minLength: 0)
                
                Button {
                    withAnimation {
                        currentMonth -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                
                Button {
                    withAnimation {
                        currentMonth += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
                
                
            }
            .padding(.horizontal)
            // Day view...
            HStack(spacing: 0){
                ForEach(days, id: \.self){ day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Dates ...
            // Lazy Grid..
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns,spacing: 15) {
                ForEach(extractDate()){ value in
                    CardView(value: value)
                        .background(
                            Capsule()
                                .fill(Color("Pink"))
                                .padding(.horizontal, 8)
                                .opacity(isSameDay(date1: value.date, date2: currentDate) ? 1 : 0)
                        )
                        .onTapGesture {
                            currentDate = value.date
                        }
                }
            }
            
            VStack(spacing: 15){
                Text("Tasks")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 20)
                
                if let task = viewModel.tasks?.first(where: { task in
                    return isSameDay(date1: task.taskDate, date2: currentDate)
                }){
                    
                    
                    ForEach(task.task){ task in
                        HStack(){
                            VStack(alignment: .leading, spacing: 10){
                                Text(task.time, style: .date)
                                
                                Text(task.title)
                                    .font(.title2.bold())
                            }
                            Spacer()
                            
                            Image(systemName: "trash")
                                .onTapGesture {
                                    showAlert = true
                                }
                                .alert(isPresented: $showAlert) {
                                    Alert(
                                        title: Text("Eliminar tarea"),
                                        message: Text("¿Estás seguro de que deseas eliminar este elemento?"),
                                        primaryButton: .destructive(Text("Eliminar")) {
                                            viewModel.deleteTask(taskID: task.id)
                                            
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
                        }
                        
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            Color("Purple")
                                .opacity(0.5)
                                .cornerRadius(10)
                            
                        )
                        
                    }
                    
                }else{
                    Text("No Task")
                }
            }
            .padding()
            
            
            
        }
        .onChange(of: currentMonth) { newValue in
            currentDate = getCurrentMonth()
        }
    }
    
    @ViewBuilder
    func CardView(value: DateValue)-> some View {
        VStack{
            if value.day != -1 {
                if let task = viewModel.tasks?.first(where: { task in
                    return isSameDay(date1: task.taskDate, date2: value.date)
                }){
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: task.taskDate, date2: currentDate) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                    Spacer()
                    Circle()
                        .fill(isSameDay(date1: task.taskDate, date2: currentDate) ? .white : Color("Pink"))
                        .frame(width: 8, height: 8)
                }
                else{
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: value.date , date2: currentDate) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
        .frame(height: 60, alignment: .top)
        
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool{
        let calendar = Calendar.current
        
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    // year
    
    func extraDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYY MMM"
        
        let date = formatter.string(from: currentDate)
        
        return date.components(separatedBy: " ")
    }
    
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month, value: currentMonth, to: Date()) else {
            return Date()
        }
        return currentMonth
    }
    
    func extractDate() -> [DateValue]{
        let calendar = Calendar.current
        
        let currentMonth = getCurrentMonth()
        var days =  currentMonth.getAllDates().compactMap{ date -> DateValue in
            let day = calendar.component(.day, from: date)
            
            return DateValue(day: day, date: date)
        }
        
        // adding offset days to get extract
        
        let firstWeekDay = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<firstWeekDay-2 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
}

struct CustomDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(TaskViewModel())
    }
}


extension Date{
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        
        // getting start Date...
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}
