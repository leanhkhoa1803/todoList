//
//  FirebaseTaskListener.swift
//  TodoList
//
//  Created by KhoaLA8 on 18/6/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseTaskListener {
    static let shared = FirebaseTaskListener()
    
    var taskListener: ListenerRegistration!
    
    //MARK: - Add Update Delete
    func saveTask(_ task: Task) {
        do {
            try FirebaseReference(.Task).document(task.id).setData(from: task)
            
        } catch {
            print("Error saving task", error.localizedDescription)
        }
    }
    
    func deleteTask(_ task: Task) {
        FirebaseReference(.Task).document(task.id).delete()
    }
    
    func downloadTasksCurrentDayFromFirebase(completion: @escaping (_ allTasks: [Task]?) ->Void) {
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = calendar.component(.year, from: Date())
        dateComponents.month = calendar.component(.month, from: Date())
        dateComponents.day = calendar.component(.day, from: Date())
        dateComponents.timeZone = TimeZone(secondsFromGMT: 7 * 3600) // UTC+7
        
        // Get the start and end of the day
        guard let startOfDay = calendar.date(from: dateComponents) else {
            print("Invalid date components")
            return
        }
        
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? startOfDay
        
        // Convert to Firestore Timestamps
        let startTimestamp = Timestamp(date: startOfDay)
        let endTimestamp = Timestamp(date: endOfDay)
        
        taskListener = FirebaseReference(.Task)
            .whereField(kUSERID, isEqualTo: User.currentId)
            .whereField(kCREATEDDATE, isGreaterThanOrEqualTo: startTimestamp)
            .whereField(kCREATEDDATE, isLessThanOrEqualTo: endTimestamp)
            .addSnapshotListener({ (querySnapshot, error) in
                
                guard let documents = querySnapshot?.documents else {
                    print("no documents")
                    if error != nil{
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                    return
                }
                
                if documents.isEmpty {
                    print("No tasks found for the current day")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                var allTasks = documents.compactMap { (queryDocumentSnapshot) -> Task? in
                    
                    return try? queryDocumentSnapshot.data(as: Task.self)
                }
                
                allTasks.sort(by: { $0.createdDate! > $1.createdDate! })
                completion(allTasks)
            })
    }
    
    func downloadAllTaskFromFirebase(completion: @escaping (_ allTasks: [Task]?) ->Void) {
        taskListener = FirebaseReference(.Task)
            .whereField(kUSERID, isEqualTo: User.currentId)
            .addSnapshotListener({ (querySnapshot, error) in
                
                guard let documents = querySnapshot?.documents else {
                    print("no documents")
                    if error != nil{
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                    return
                }
                
                if documents.isEmpty {
                    print("No tasks found for the current day")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                var allTasks = documents.compactMap { (queryDocumentSnapshot) -> Task? in
                    
                    return try? queryDocumentSnapshot.data(as: Task.self)
                }
                
                allTasks.sort(by: { $0.createdDate! > $1.createdDate! })
                completion(allTasks)
            })
    }
}
