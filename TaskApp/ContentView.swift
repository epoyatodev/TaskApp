//
//  ContentView.swift
//  TaskApp
//
//  Created by Enrique Poyato Ortiz on 26/5/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView().environmentObject(TaskViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
