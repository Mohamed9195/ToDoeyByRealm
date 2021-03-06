//
//  secoundTableViewController.swift
//  ToDoeyByRealm
//
//  Created by mohamed hashem on 11/1/18.
//  Copyright © 2018 mohamed hashem. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class secoundTableViewController: SwipeViewController {

    var pathToInfo = 0
    
    let realm = try! Realm()
    
    var  todoItems: Results<Item>?
    
    var selectedCategory: Category? {
        didSet{
            
           loadItems()
        }
    }
    
 
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.tableView.reloadData()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(self.editCell))
        tableView.addGestureRecognizer(longpress)

        tableView.rowHeight = 65.0
        
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        
        guard let colourHex = selectedCategory?.colour else { fatalError() }
        
        updateNavBar(withHexCode: colourHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "1D9BF6")
        
    }
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colourHexCode: String){
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        guard let navBarColour = UIColor(hexString: colourHexCode) else { fatalError()}
        
        navBar.barTintColor = navBarColour
        
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
        
        searchBar.barTintColor = navBarColour
        
    }
    
    
    @IBAction func additem(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todey Item", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            
           
          if let currentCategory = self.selectedCategory {
            if textField.text! != "" {
                do{
                        try  self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                       }
                   }catch{
                    print("Error Saving New Item \(error)")
                }
                
            }
             }

            self.tableView.reloadData()
        }))
        
        alert.addTextField { (alertTextField) in alertTextField.placeholder = "Creat new item"; textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    //MARK: - TableView DataSourc Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let Cell = super.tableView(tableView, cellForRowAt: indexPath)
       // let Cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
        
        Cell.textLabel?.text =  item.title
            if let colour =  UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
             Cell.backgroundColor = colour
             
                Cell.textLabel?.textColor = (UIColor(contrastingBlackOrWhiteColorOn:colour, isFlat:true))
            }
           
        
        Cell.accessoryType  = item.done ?  .checkmark : .none
        }else {
            Cell.textLabel?.text = "No Item Add Yet"
        }
        return Cell
    }
    
    
    
    
    
    
    
    
    //MARK: - TableView Delegate Methods
    override   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            
            do{
                try realm.write {
                    item.done = !item.done
                    
                }
                
            }catch{
                print("Error Savinge done status\(error)")
            }
            tableView.reloadData()
           
            
            
        }
 
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
    }
    
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
////            if let item = todoItems?[indexPath.row] {
////
////                do{
////                    try realm.write {
////                        realm.delete(item)
////                                            }
////
////                }catch{
////                    print("Error Savinge done status\(error)")
////                }
////
////            }
////
////            tableView.reloadData()
//        }
//    }
    
    

    
    //MARK: - read data
    func loadItems() {
    
        // data in selectedCategory segua
        
       todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        //all data in realm item table
      //  todoItems = realm.objects(Item.self)
        

        self.tableView.reloadData()
    }

    
    
    
    
    
    
    //MARK: - edite cell when long press
    @objc func editCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .ended{
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                var textField = UITextField()
                
                let alert = UIAlertController(title: "Edit item", message: "", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
                    
                    if textField.text! != "" {
                        if let item = self.todoItems?[indexPath.row] {
                                do{
                                    try self.realm.write {
                                        item.title = textField.text!
                                        item.dateCreated = Date()
                                    }
                                }catch{
                                    print("Error Savinge done status\(error)")
                                }
                            }
                       
                    }
                    self.tableView.reloadData()
                }))
                
                alert.addTextField { (alertTextField) in alertTextField.placeholder = self.todoItems?[indexPath.row].title ?? "no  item to edite" ; textField = alertTextField
                }
                
                present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    
    override func DeletModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            
            do{
                try realm.write {
                    realm.delete(item)
                }
                
            }catch{
                print("Error Savinge done status\(error)")
            }
            
        }

    }
    
    override func infoModel(at indexPath: IndexPath) {
        pathToInfo = indexPath.row
        performSegue(withIdentifier: "goToInfo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       let destinationVC = segue.destination as! InfoViewController
        destinationVC.Information = todoItems?[pathToInfo]
        
    }
    
}



//MARK: - Search function

extension secoundTableViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        self.tableView.reloadData()
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
    
}



