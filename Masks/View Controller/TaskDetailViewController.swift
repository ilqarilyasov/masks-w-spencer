//
//  TaskDetailViewController.swift
//  Masks
//
//  Created by Ilgar Ilyasov on 2/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    
    // MARK: - Actions
    
    @IBAction func saveBarButtonTapped(_ sender: Any) {
        
        guard let name = nameTextField.text, !name.isEmpty else {
            // Present an alert
            return
        }

        let notes = notesTextView.text // Notes could be nil, it's optional. No need to unwrap
        _ = Mask(name: name, notes: notes) // This create a task in ManagedObjectContext
        
        /// Where to put the task?
        do {
            let moc = CoreDataStack.shared.mainContext
            try  moc.save() // This will take the tass from MOC and save it to PersistentStore
        } catch {
            NSLog("Error saving managed object context: \(error)")
            navigationController?.popViewController(animated: true)
        }
    }
}
