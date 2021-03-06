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
    
    var taskController: TaskController?
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
        let priority = TaskPriority.allCases[priorityIndex]
        
        if let task = task {
            taskController?.updateTask(task, withName: name, notes: notes, priority: priority)
        } else {
            taskController?.createTask(with: name, notes: notes, priority: priority) // This create a task in ManagedObjectContext
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
        guard let task = task else {
            title = "Create Task"
            prioritySegmentedControl.selectedSegmentIndex = 1
            return
        }
        
        title = task.name
        nameTextField.text = task.name
        notesTextView.text = task.notes
        
//        var index: Int = 1
//
//        switch task.priority {
//        case MaskPriority.low.rawValue:
//            index = 0
//        case MaskPriority.normal.rawValue:
//            index = 1
//        case MaskPriority.high.rawValue:
//            index = 2
//        case MaskPriority.critical.rawValue:
//            index = 3
//        default:
//            index = 1
//        }
//
//        prioritySegmentedControl.selectedSegmentIndex = index
        
        guard let priorityString = task.priority,
            let priority = TaskPriority(rawValue: priorityString),
            let index = TaskPriority.allCases.firstIndex(of: priority) else { return }

        prioritySegmentedControl.selectedSegmentIndex = index
    }
}
