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
    
    lazy var fetchedResultsController: NSFetchedResultsController<Mask> = {
        let fetchRequest: NSFetchRequest<Mask> = Mask.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let prioritySortDescriptor = NSSortDescriptor(key: "priority", ascending: true)
        fetchRequest.sortDescriptors = [nameSortDescriptor, prioritySortDescriptor]
        
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: moc,
                                             sectionNameKeyPath: "priority", cacheName: nil)
        frc.delegate = self
        try! frc.performFetch() // If it's going to fail it's better to crash
        
        return frc
    }()
    
    
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
            
            do {
                try moc.save() // Also remove it from PersistentStore and match the to MOC
            } catch {
                moc.reset() // If there will be an error just reset the MOC
                NSLog("Error saving deletation;\(error)")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade) // Also update tableView
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
    }

 
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTaskDetail" {
            let destinationVC = segue.destination as! TaskDetailViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
//            destinationVC.task = tasks[indexPath.row]
            destinationVC.task = fetchedResultsController.object(at: indexPath)
            
        }
    }

}
