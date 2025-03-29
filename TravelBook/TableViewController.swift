//
//  TableViewController.swift
//  TravelBook
//
//  Created by Punhan Shahmurov on 29.03.25.
//

import UIKit
import CoreData

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var choosenTitle: String?
    var choosenSubtitle: String?
    var choosenId: UUID?
    
    var titleArray = [String]()
    var idArray = [UUID]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))

        tableView.dataSource = self
        tableView.delegate = self
        
        
        getData()
    }
    
    func getData(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let result = try context.fetch(fetchRequest)
            
            if result.count > 0 {
                
                self.titleArray.removeAll(keepingCapacity: false)
                self.idArray.removeAll(keepingCapacity: false)
                
                for item in result as! [NSManagedObject] {
                    if let title = item.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    
                    if let id = item.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    
                }
            }
            
            
        } catch {
            print("error")
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenTitle = titleArray[indexPath.row]
        choosenId = idArray[indexPath.row]
        
        performSegue(withIdentifier: "toAddPlace", sender: nil)
    }
     
    
    @objc func addButtonTapped() {
        choosenTitle = ""
        performSegue(withIdentifier: "toAddPlace", sender: nil)
    }
     
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddPlace" {
            let destinationVC = segue.destination as! ViewController
             
            destinationVC.choosenId = choosenId
            destinationVC.choosenTitle = choosenTitle
        }
    }
}
