//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 04.10.2021.
//

import UIKit
import CoreData

enum ActionsWithTasks {
    case save
    case edit
}

protocol TaskViewControllerDelegate {
    func reloadData()
}

class TaskListViewController: UITableViewController {
    private let context = StorageManager.shared.persistentContainer.viewContext
    private let cellID = "task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(CustomCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        taskList = fetchData()
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?", action: .save)
    }
    
    private func fetchData() -> [Task] {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let taskList = try context.fetch(fetchRequest)
            return taskList
        } catch let error {
            print("Failed to fetch data", error)
            return []
        }
    }
    
    private func showAlert(with title: String, and message: String, action: ActionsWithTasks, at: IndexPath = [0,0]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cell = tableView.cellForRow(at: at) as? CustomCell
        switch action {
        case .save:
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                self.save(task)
            }
            
            alert.addAction(saveAction)
            alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
        case .edit:
            let editAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let newTaskTitle = alert.textFields?.first?.text, !newTaskTitle.isEmpty else { return }
                self.edit(by: at, newValue: newTaskTitle)
            }
            
            alert.addAction(editAction)
            alert.addTextField { textField in
                textField.text = cell?.taskLabel.text ?? ""
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            cell?.isSelected = false
        }
        alert.addAction(cancelAction)
        
        
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        task.title = taskName
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    private func edit(by: IndexPath, newValue: String) {
        
        let taskList = fetchData()
        taskList[by.row].title = newValue
        self.taskList[by.row].title = newValue
        let cell = tableView.cellForRow(at: by) as! CustomCell
        cell.taskLabel.text = newValue
        
        do {
            try context.save()
            cell.isSelected = false
        } catch let error {
            print("Failed to edit data", error)
            cell.isSelected = false
        }
        
    }
    
    private func delete(by: IndexPath) {
        let task = taskList[by.row]
        context.delete(task)
        taskList.remove(at: by.row)
        tableView.deleteRows(at: [by], with: .fade)

        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! CustomCell
        let task = taskList[indexPath.row]
        cell.taskLabel.text = task.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(with: "Edit Task", and: "What do you want to do?", action: .edit, at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(by: indexPath)
        }
    }
}

// MARK: - TaskViewControllerDelegate
//extension TaskListViewController: TaskViewControllerDelegate {
//    func reloadData() {
//        fetchData()
//        tableView.reloadData()
//    }
//}
