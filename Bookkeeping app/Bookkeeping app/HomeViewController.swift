//
//  ViewController.swift
//  Bookkeeping app
//
//  Created by kustar on 12/9/20.
//  Copyright © 2020 kustar. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var books: [Book]?
    var isAdding: Bool?
    var selectedBook: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "BookTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "BookTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        reloadTableData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadTableData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAddBook" {
            let destVC = segue.destination as! DetailsViewController
            
            if isAdding! {
                destVC.isAdding = true
            }
            else {
                destVC.isAdding = false
                destVC.selectedBook = selectedBook
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookTableViewCell", for: indexPath) as! BookTableViewCell
        let book = books![indexPath.row]
        
        cell.nameLabel.text = book.name
        cell.isbnLabel.text = book.isbn
        cell.bookImageView.image = UIImage(data: book.image!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isAdding = false
        selectedBook = indexPath.row
        performSegue(withIdentifier: "toAddBook", sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") {_,_,_ in
            self.deleteBook(bookToBeDeleted: indexPath.row)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func reloadTableData() {
        DispatchQueue.main.async {
            self.books = self.fetchBooks()
            self.tableView.reloadData()
        }
    }
    
    func deleteBook(bookToBeDeleted: Int) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let bookToDelete = books![bookToBeDeleted]
        context.delete(bookToDelete)
        do {
            try context.save()
        }
        catch {
            
        }
        reloadTableData()
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        isAdding = true
        performSegue(withIdentifier: "toAddBook", sender: self)
    }
    
    @IBAction func unwindToHome( _ seg: UIStoryboardSegue) {
    }
    
}

extension UIViewController {
    
    func fetchBooks() -> [Book]{
        var books = [Book]()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = Book.fetchRequest() as NSFetchRequest<Book>
        
        do{
            try books = context.fetch(request)
        }
        catch {
            
        }
        
        return books
    }
}
