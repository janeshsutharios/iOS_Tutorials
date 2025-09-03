//
//  ViewController.swift
//  UITableView_Example_Swift

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var customTableView: UITableView!
    
    var programmingLanguagesArray = ["Swift", "Objective C", "Java", "Pyton", "C", "C++", "Visual Basic", "PHP", "SQL", "R", "Groovy", "Assembly language", "Pascal", "Basic", "Lisp", "COBOL"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUItableView()
    }
    
    // Setting UItableview
    func setUpUItableView() {
        customTableView.dataSource = self
        customTableView.delegate = self
        customTableView.estimatedRowHeight = 80// To make resizable cells
        customTableView.rowHeight = UITableView.automaticDimension
        //To register Fresh cell to the TableView
        customTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    // Return a list of item in array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return programmingLanguagesArray.count
    }
    
    // return a cell for specific row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        var content = cell.defaultContentConfiguration()
        content.text = programmingLanguagesArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Clicked on row -->", indexPath.row)
    }
}
