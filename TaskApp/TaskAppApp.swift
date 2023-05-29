//
//  TaskAppApp.swift
//  TaskApp
//
//  Created by Enrique Poyato Ortiz on 26/5/23.
//

import SwiftUI
import Firebase

@main
struct TaskAppApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        
        
        WindowGroup {
            ContentView()
        }
    }
}
