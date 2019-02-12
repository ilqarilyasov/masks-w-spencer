//
//  CoreDataStack.swift
//  Masks
//
//  Created by Ilgar Ilyasov on 2/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    /// Create a shared one stack for the whole app
    static let shared = CoreDataStack()
    
    private lazy var container: NSPersistentContainer = {
        
        /// Create a container
        let container = NSPersistentContainer(name: "Masks") // Should be same as NSManagedObject
//        let container = NSPersistentContainer(name: kCFBundleNameKey as String)
        
        /// Load the persistent store
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent store: \(error)")
            }
        }
        
        return container
    }()
    
    /// This should help you remember that the viewContext should be used on the main thread
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
}
