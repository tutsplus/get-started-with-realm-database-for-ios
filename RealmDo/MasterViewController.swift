//
//  MasterViewController.swift
//  RealmDo
//
//  Created by Doron Katz on 6/8/17.
//  Copyright © 2017 Doron Katz. All rights reserved.
//

import UIKit
import RealmSwift

class MasterViewController: UITableViewController {

    var realm : Realm!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var remindersList: Results<Reminder> {     //we are lazy-calling Reminder objects
        get {
            return try! Realm().objects(Reminder.self)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
            realm = try! Realm()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remindersList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let item = remindersList[indexPath.row]
        
        cell.textLabel!.text = item.name
        cell.textLabel!.textColor = item.done == false ? UIColor.black : UIColor.lightGray
        
        return cell
    }

    override func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        let item = remindersList[indexPath.row]
        try! self.realm.write({
            item.done = !item.done
        })
        
        //refresh rows
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }
    // [1]
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // [2]
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete){
            let item = remindersList[indexPath.row]
            try! self.realm.write({
                self.realm.delete(item)
            })
            
            tableView.deleteRows(at:[indexPath], with: .automatic)
            
        }
        
    }
 
}

extension MasterViewController{
    @IBAction func addReminder(_ sender: Any) {
        
        let alertVC : UIAlertController = UIAlertController(title: "New Reminder", message: "What do you want to remember?", preferredStyle: .alert)
        
        alertVC.addTextField { (UITextField) in
            
        }
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil)
        
        alertVC.addAction(cancelAction)
        
        //Alert action closure
        let addAction = UIAlertAction.init(title: "Add", style: .default) { (UIAlertAction) -> Void in
            
            let textFieldReminder = (alertVC.textFields?.first)! as UITextField
            
            let reminderItem = Reminder()
            reminderItem.name = textFieldReminder.text!
            reminderItem.done = false
            
            // We are adding the reminder to our database
            try! self.realm.write({
                self.realm.add(reminderItem)
                
                self.tableView.insertRows(at: [IndexPath.init(row: self.remindersList.count-1, section: 0)], with: .automatic)
            })
            
        }
        
        alertVC.addAction(addAction)
        
        present(alertVC, animated: true, completion: nil)
        
    }
}

