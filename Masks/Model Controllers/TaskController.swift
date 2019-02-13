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
    
    
    // MARK: - CRUD methods
    
    @discardableResult
    func createTask(with name: String, notes: String?, priority: MaskPriority) -> Mask {
        
        let task = Mask(name: name, notes: notes, priority: priority)
        saveToPersistentStore()
        
        return task
    }
    
    func updateTask(_ task: Mask, withName name: String, notes: String?, priority: MaskPriority) {
        task.name = name
        task.notes = notes
        task.priority = priority.rawValue
        
        saveToPersistentStore()
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
                let maskRepresentationJSON = try decoder.decode([String: MaskRepresentation].self, from: data)
//                _ = maskRepresentationJSON.map{ Mask(maskRep: $0.value) }
                
                for (_, value) in maskRepresentationJSON {
                    if let mask = self.mask(for: value.identifier),
                        let priority = MaskPriority(rawValue: value.priority) {
                        self.updateTask(mask, withName: value.name, notes: value.notes, priority: priority)
                    } else {
                        Mask(maskRep: value)
                    }
                }
                
                self.saveToPersistentStore()
                completion(nil)
            } catch {
                NSLog("Error deccodind MaskRespresentation: \(error)")
                completion(error)
            }
        }.resume()
    }
    
    
    // See if a task with identifier exists already in CoreData
    
    func mask(for uuid: String) -> Mask? {
        let fetchRequest: NSFetchRequest<Mask> = Mask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", uuid)
        
        do {
            let moc = CoreDataStack.shared.mainContext
            return try moc.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching task with \(uuid): \(error)")
            return nil
        }
    }
    
    
    // MARK: - Persistent Coordinator methods
    
    func saveToPersistentStore() {
        let moc = CoreDataStack.shared.mainContext
        
        do {
            try moc.save()
        } catch {
            moc.reset()
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
}
