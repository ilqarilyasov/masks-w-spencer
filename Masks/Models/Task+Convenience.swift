//
//  Task+Convenience.swift
//  Tasks
//
//  Created by Ilgar Ilyasov on 2/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData


enum TaskPriority: String, CaseIterable {
    case low
    case normal
    case high
    case critical
}


extension Mask {
    
    @discardableResult /// Ignore the result if it's used
    convenience init(name: String, notes: String? = nil,
                     priority: TaskPriority = .normal, identifier: UUID = UUID(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        /// Setting up the NSManagedObject part of the Mask object
        self.init(context: context)
        
        self.name = name
        self.notes = notes
        self.priority = priority.rawValue
        self.identifier = identifier
    }
    
    @discardableResult
    convenience init?(taskRep: TaskRepresentation,
                      context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        // The identifier could be in the wrong format
        // The priority could be something other than the 4 priorities
        guard let identifier = UUID(uuidString: taskRep.identifier),
            let priority = TaskPriority(rawValue: taskRep.priority) else { return nil }
        
        self.init(name: taskRep.name, notes: taskRep.notes,
                  priority: priority, identifier: identifier, context: context)
    }
    
    var taskPepresentation: TaskRepresentation? {
        guard let name = name,
            let priority = priority,
            let identifier = identifier?.uuidString else { return nil }
        
        let taskRepresentation = TaskRepresentation(name: name, notes: notes, priority: priority, identifier: identifier)
        return taskRepresentation
    }
}
