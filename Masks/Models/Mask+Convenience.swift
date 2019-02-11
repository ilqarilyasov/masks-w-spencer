//
//  Mask+Convenience.swift
//  Masks
//
//  Created by Ilgar Ilyasov on 2/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Mask {
    
    convenience init(name: String, notes: String? = nil,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        /// Setting up the NSManagedObject part of the Mask object
        self.init(context: context)
        
        self.name = name
        self.notes = notes
    }
}
