//
//  TasksTableViewController.swift
//  Masks
//
//  Created by Ilgar Ilyasov on 2/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class TasksTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
//    var tasks: [Mask] {
//        /// What do we want to fetch from the PersistentStore
//        let fetchRequest: NSFetchRequest<Mask> = Mask.fetchRequest()
//
//        /// We could say what kind of tasks we want to fetched
//        let moc = CoreDataStack.shared.mainContext
//
//        do {
//            let tasks = try moc.fetch(fetchRequest)
//            return tasks
//        } catch {
//            NSLog("Error fetching tasks from PersistentStore")
//            return []
//        }
//    }
    
    let taskController = TaskController()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Mask> = {
        let fetchRequest: NSFetchRequest<Mask> = Mask.fetchRequest()
        let prioritySortDescriptor = NSSortDescriptor(key: "priority", ascending: true)
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [prioritySortDescriptor, nameSortDescriptor]
        
//        let predicate = NSPredicate(format: "priority == %@", "critical")
//        fetchRequest.predicate = predicate
        
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: moc,
                                             sectionNameKeyPath: "priority", cacheName: nil)
        frc.delegate = self
        try! frc.performFetch() // If it's going to fail it's better to crash
        
        return frc
    }()
    
    @IBAction func refresh(_ sender: Any) {
        taskController.fetchTasksFromServer { (error) in
            if let error = error {
                NSLog("Error fethching tasks from server: \(error)")
            }
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return tasks.count
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
//        cell.textLabel?.text = tasks[indexPath.row].name
        cell.textLabel?.text = fetchedResultsController.object(at: indexPath).name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            let task = tasks[indexPath.row]
            let task = fetchedResultsController.object(at: indexPath)
            let moc = CoreDataStack.shared.mainContext
            moc.delete(task) // Remove from MOC
            taskController.deleteTaskFromServer(task)
            
            do {
                try moc.save() // Also remove it from PersistentStore and match the to MOC
            } catch {
                moc.reset() // If there will be an error just reset the MOC
                NSLog("Error saving deletation;\(error)")
            }
            
            // If you use NSFetchedResultsControllerDelegate function you don't need this. Because you will have two delete functions and it will crash the app
//            tableView.deleteRows(at: [indexPath], with: .fade) // Also update tableView
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
        
        return sectionInfo.name.capitalized
    }

 
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTaskDetail" {
            let destinationVC = segue.destination as! TaskDetailViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
//            destinationVC.task = tasks[indexPath.row]
            destinationVC.task = fetchedResultsController.object(at: indexPath)
            destinationVC.taskController = taskController
        } else if segue.identifier == "ShowCreateTask" {
            let destinationVC = segue.destination as! TaskDetailViewController
            destinationVC.taskController = taskController
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    // Tell the table view that we're going to update it
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    // Tell the table view that we're done updating it
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // How do we what to update the table view in response to a change on a Task?
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }

}
