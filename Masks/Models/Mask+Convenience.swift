//
//  Mask+Convenience.swift
//  Masks
//
//  Created by Ilgar Ilyasov on 2/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum MaskPriority: String {
    case low
    case normal
    case high
    case critical
    
    static var allPriorities: [MaskPriority] {
        return [.low, .normal, .high, .critical]
    }
}

extension Mask {
    
    @discardableResult /// Ignore the result if it's used
    convenience init(name: String, notes: String? = nil, priority: MaskPriority = .normal,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        /// Setting up the NSManagedObject part of the Mask object
        self.init(context: context)
        
        self.name = name
        self.notes = notes
        self.priority = priority.rawValue
    }
}
