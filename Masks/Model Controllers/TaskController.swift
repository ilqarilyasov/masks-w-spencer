//
//  TaskController.swift
//  Masks
//
//  Created by Ilgar Ilyasov on 2/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class TaskController {
    
    init() {
        fetchTasksFromServer()
    }
    
    // MARK: - Properties
    
    let baseURL = URL(string: "https://tasks-3f211.firebaseio.com/")!
    let moc = CoreDataStack.shared.mainContext
    
    
    // MARK: - CRUD methods
    
    @discardableResult
    func createTask(with name: String, notes: String?, priority: TaskPriority) -> Mask {
        
        let task = Mask(name: name, notes: notes, priority: priority)
        
        do {
            try CoreDataStack.shared.save()
        } catch {
            NSLog("Error saving newly created task to the main moc: \(error)")
        }
        
        put(task)
        return task
    }
    
    func updateTask(_ task: Mask, withName name: String, notes: String?, priority: TaskPriority) {
        task.name = name
        task.notes = notes
        task.priority = priority.rawValue
        
        put(task)
    }
    
    func fetchTasksFromServer(completion: @escaping (Error?) -> Void = { _ in } ) {
        
        let url = baseURL.appendingPathExtension("json")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching tasks: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let taskRepresentationJSON = try decoder.decode([String: TaskRepresentation].self, from: data)
                
                // Convert TaskRepresentation to Tasks
                // it should happen on a background context
                
                let backgroundMoc = CoreDataStack.shared.container.newBackgroundContext()
                
                backgroundMoc.performAndWait {
                    for (_, value) in taskRepresentationJSON {
                        if let task = self.task(for: value.identifier, context: backgroundMoc),
                            let priority = TaskPriority(rawValue: value.priority) {
                            self.updateTask(task, withName: value.name, notes: value.notes, priority: priority)
                        } else {
                            // Initialize the task in the background NOT on the main context
                            Mask(taskRep: value, context: backgroundMoc)
                        }
                    }
                    
                    do {
                        try CoreDataStack.shared.save(context: backgroundMoc)
                    } catch {
                        NSLog("Error saving background context: \(error)")
                    }
                }
                
                completion(nil)
            } catch {
                NSLog("Error deccoding MaskRespresentation: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    func put(_ task: Mask, completion: @escaping (Error?) -> Void = { _ in }) {
        // Create a URLRequest
        let identifier = task.identifier ?? UUID()
        let urlPlusID = baseURL.appendingPathComponent(identifier.uuidString)
        let urlPlusJSON = urlPlusID.appendingPathExtension("json")
        var request = URLRequest(url: urlPlusJSON)
        request.httpMethod = "PUT"
        
        // Mask -> TaskRepresentation -> JSNO Data
        guard let taskRepresentation = task.taskPepresentation else {
            NSLog("Unable to convert task to task representation")
            completion(NSError())
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let taskJSON = try encoder.encode(taskRepresentation)
            request.httpBody = taskJSON
        } catch {
            NSLog("Unable to encode task representation: \(error)")
            completion(error)
            return
        }
        
        // Create a URLSession.shared.dataTask
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                NSLog("Error putting tas to server: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    
    func deleteTaskFromServer(_ task: Mask, completion: @escaping (Error?) -> Void = { _ in }) {
        guard let identifier = task.identifier else {
            NSLog("Error unwrapping task identifier")
            completion(NSError())
            return
        }
        
        let url = baseURL.appendingPathComponent(identifier.uuidString)
        let url2 = url.appendingPathExtension("json")
        
        var request = URLRequest(url: url2)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting task: \(task)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    // See if a task with identifier exists already in CoreData
    
    func task(for uuid: String, context: NSManagedObjectContext) -> Mask? {
        let fetchRequest: NSFetchRequest<Mask> = Mask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid)
        var task: Mask?
        
        context.performAndWait {
            do {
                task = try context.fetch(fetchRequest).first
            } catch {
                NSLog("Error fetching task with \(uuid): \(error)")
            }
        }
        return task
    }
    
    
    // MARK: - Persistent Coordinator methods
    
//    func saveToPersistentStore() {
//        do {
//            try moc.save()
//        } catch {
//            moc.reset()
//            NSLog("Error saving managed object context: \(error)")
//        }
//    }
    
}
