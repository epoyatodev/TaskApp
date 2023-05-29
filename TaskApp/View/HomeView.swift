//
//  HomeView.swift
//  TaskApp
//
//  Created by Enrique Poyato Ortiz on 26/5/23.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @State var currentDate: Date = Date()
    @State var showNewTask: Bool = false
    @State var newTaskText: String = ""
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false){
            VStack(spacing: 20){
                CustomDatePicker(currentDate: $currentDate)
            }
            .padding(.vertical)
        }
        .safeAreaInset(edge: .bottom){
            HStack{
                Button{
                    showNewTask.toggle()
                    
                }label: {
                    Text("Add Task")
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(Color("Orange"), in: Capsule())
                }
                .sheet(isPresented: $showNewTask) {
                    
                    VStack {
                        Text("New Task for \(currentDate, style: .date)")
                            .font(.title3.bold())
                            .foregroundColor(.black)
                            .padding(30)
                        TextEditor(text: $newTaskText)
                            .padding()
                            .foregroundColor(.black)
                            .buttonBorderShape(.roundedRectangle)
                            .background(.ultraThinMaterial)
                            .cornerRadius(30)
                            .font(.title3)
                            .padding()
                        Button {
                            if newTaskText != ""{
                                viewModel.addNewTask(taskMetaData: TaskMetaData(task: [Task(title: newTaskText, time: currentDate)], taskDate: currentDate))
                                newTaskText = ""
                            }
                            
                            showNewTask.toggle()
                            
                            
                        } label: {
                            Text("Save")
                                .padding()
                                .foregroundColor(.white)
                                .font(.title3.bold())
                                .background(Color.pink)
                                .cornerRadius(30)
                        }
                        
                        Spacer()
                    }
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    
                }
                
                
                Button{
                    
                }label: {
                    Text("Add Remainder")
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(Color("Purple"), in: Capsule())
                }
            }
            .padding(.horizontal)
            .padding([.top, .bottom], 10)
            .foregroundColor(.white)
            .background(.ultraThinMaterial)
            
            
            
            
        }
   
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(TaskViewModel())
    }
}
