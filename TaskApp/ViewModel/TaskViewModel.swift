//
//  TaskViewModel.swift
//  TaskApp
//
//  Created by Enrique Poyato Ortiz on 26/5/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class TaskViewModel: ObservableObject {
    private let db = Firestore.firestore()
    @Published var tasks: [TaskMetaData]? = []
    
    init() {
        fetchTasks()
    }

    func addNewTask(taskMetaData: TaskMetaData) {
        if let tasks = tasks {
            let calendar = Calendar.current
            if let existingTaskMetaDataIndex = tasks.firstIndex(where: { calendar.isDate($0.taskDate, inSameDayAs: taskMetaData.taskDate) }) {
                self.tasks?[existingTaskMetaDataIndex].task.append(contentsOf: taskMetaData.task)
                updateTaskMetaDataInFirestore(taskMetaData: self.tasks?[existingTaskMetaDataIndex])
            } else {
                // Crear una nueva TaskMetaData para el mismo día
                let newTaskMetaData = TaskMetaData(id: UUID().uuidString, task: taskMetaData.task, taskDate: taskMetaData.taskDate)
                self.tasks?.append(newTaskMetaData)
                saveTaskMetaDataToFirestore(taskMetaData: newTaskMetaData)
            }
        } else {
            self.tasks = [taskMetaData]
            saveTaskMetaDataToFirestore(taskMetaData: taskMetaData)
        }
    }


    
    private func saveTaskMetaDataToFirestore(taskMetaData: TaskMetaData) {
        do {
            let documentRef = db.collection("task_meta_data").document(taskMetaData.id)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601 // Configura la estrategia de codificación de fechas
            let data = try encoder.encode(taskMetaData)

            // Convertir los datos codificados en un diccionario
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Error al convertir datos codificados en un diccionario")
                return
            }

            // Guardar los datos en Firestore
            documentRef.setData(dictionary, merge: true) { error in
                if let error = error {
                    print("Error al guardar el documento: \(error.localizedDescription)")
                } else {
                    print("Documento guardado con ID: \(documentRef.documentID)")
                }
            }
        } catch let error {
            print("Error al codificar los datos: \(error.localizedDescription)")
        }
    }

   
    
    func deleteTask(taskID: String) {
        guard var tasks = tasks else { return }

        // Encuentra el índice de la TaskMetaData que contiene la tarea a eliminar
        guard let taskMetaDataIndex = tasks.firstIndex(where: { $0.task.contains(where: { $0.id == taskID }) }) else { return }

        // Elimina la tarea del array task de la TaskMetaData
        tasks[taskMetaDataIndex].task.removeAll(where: { $0.id == taskID })

        // Verifica si el array de tareas está vacío después de eliminar la tarea
        if tasks[taskMetaDataIndex].task.isEmpty {
            // Verifica si el índice es válido antes de eliminar la TaskMetaData del array tasks
            if tasks.indices.contains(taskMetaDataIndex) {
                let taskMetaDataID = tasks[taskMetaDataIndex].id
                tasks.remove(at: taskMetaDataIndex)

                // Elimina la TaskMetaData de Firestore
                deleteTaskMetaDataFromFirestore(taskMetaDataID: taskMetaDataID)
            } else {
                print("Índice de TaskMetaData fuera de los límites válidos")
            }
        } else {
            // Verifica si el índice es válido antes de actualizar la TaskMetaData en Firestore
            if tasks.indices.contains(taskMetaDataIndex) {
                updateTaskMetaDataInFirestore(taskMetaData: tasks[taskMetaDataIndex])
            } else {
                print("Índice de TaskMetaData fuera de los límites válidos")
            }
        }

        self.tasks = tasks // Notificar a los observadores que el valor de tasks ha cambiado
    }


    private func deleteTaskMetaDataFromFirestore(taskMetaDataID: String) {
        db.collection("task_meta_data").document(taskMetaDataID).delete { error in
            if let error = error {
                print("Error al eliminar el documento: \(error.localizedDescription)")
            } else {
                print("Documento eliminado con ID: \(taskMetaDataID)")
            }
        }
    }



    func fetchTasks() {
        db.collection("task_meta_data").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error al obtener los documentos: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else {
                print("No se encontraron documentos")
                return
            }

            var fetchedTasks: [TaskMetaData] = []

            for document in snapshot.documents {
                let decoder = Firestore.Decoder()
                decoder.dateDecodingStrategy = .iso8601 // Configura la estrategia de decodificación de fechas
                if let taskMetaData = try? decoder.decode(TaskMetaData.self, from: document.data()) {
                    fetchedTasks.append(taskMetaData)
                   
                } else {
                    print("Error al obtener datos del documento \(document.documentID)")
                }
            }

            self.tasks = fetchedTasks
        }
    }


    
    private func updateTaskMetaDataInFirestore(taskMetaData: TaskMetaData?) {
        guard let taskMetaData = taskMetaData else { return }
        do {
            let documentRef = db.collection("task_meta_data").document(taskMetaData.id)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601 // Configura la estrategia de codificación de fechas
            let data = try encoder.encode(taskMetaData)

            // Convertir los datos codificados en un diccionario
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("Error al convertir datos codificados en un diccionario")
                return
            }

            // Actualizar los datos en Firestore
            documentRef.updateData(dictionary) { error in
                if let error = error {
                    print("Error al actualizar el documento: \(error.localizedDescription)")
                } else {
                    print("Documento actualizado con ID: \(documentRef.documentID)")
                }
            }
        } catch let error {
            print("Error al codificar los datos: \(error.localizedDescription)")
        }
    }
}
