//
//  TasksTableViewController.swift
//  Masks
//
//  Created by Ilgar Ilyasov on 2/11/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class TasksTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var tasks: [Mask] {
        /// What do we want to fetch from the PersistentStore
        let fetchRequest: NSFetchRequest<Mask> = Mask.fetchRequest()
        
        /// We could say what kind of tasks we want to fetched
        let moc = CoreDataStack.shared.mainContext
        
        do {
            let tasks = try moc.fetch(fetchRequest)
            return tasks
        } catch {
            NSLog("Error fetching tasks from PersistentStore")
            return []
        }
    }
    
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
    }

 
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTaskDetail" {
            let destinationVC = segue.destination as! TaskDetailViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            destinationVC.task = tasks[indexPath.row]
        }
    }

}
