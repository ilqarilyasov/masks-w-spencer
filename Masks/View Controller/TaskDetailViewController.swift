//
//  TaskDetailViewController.swift
//  Masks
//
//  Created by Ilgar Ilyasov on 2/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var task: Mask? {
        didSet { updateViews() }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    

    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var prioritySegmentedControl: UISegmentedControl!
    
    // MARK: - Actions
    
    @IBAction func prioritySegmentedControlAction(_ sender: UISegmentedControl) {
        
    }
    
    
    @IBAction func saveBarButtonTapped(_ sender: Any) {
        
        guard let name = nameTextField.text, !name.isEmpty else {
            // Present an alert
            return
        }

        let notes = notesTextView.text // Notes could be nil, it's optional. No need to unwrap
        let priorityIndex = prioritySegmentedControl.selectedSegmentIndex
        let priority = MaskPriority.allPriorities[priorityIndex]
        
        if let task = task {
            task.name = name
            task.notes = notes
            task.priority = priority.rawValue
        } else {
            Mask(name: name, notes: notes, priority: priority) // This create a task in ManagedObjectContext
        }
        
        
        /// Where to put the task?
        do {
            let moc = CoreDataStack.shared.mainContext
            try  moc.save() // This will take the tass from MOC and save it to PersistentStore
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func updateViews() {
        guard let task = task,
            isViewLoaded else {
            title = "Create Task"
            return
        }
        
        title = task.name
        nameTextField.text = task.name
        notesTextView.text = task.notes
        
        var index: Int = 1

        switch task.priority {
        case MaskPriority.low.rawValue:
            index = 0
        case MaskPriority.normal.rawValue:
            index = 1
        case MaskPriority.high.rawValue:
            index = 2
        case MaskPriority.critical.rawValue:
            index = 3
        default:
            index = 1
        }

        prioritySegmentedControl.selectedSegmentIndex = index
        
//        guard let priorityString = task.priority,
//            let priority = MaskPriority(rawValue: priorityString) else { return}
//
//        let index = MaskPriority.allPriorities.firstIndex(of: priority)
//        prioritySegmentedControl.selectedSegmentIndex = index
    }
}
