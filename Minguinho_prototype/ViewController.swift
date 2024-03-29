//
//  ViewController.swift
//  Minguinho_prototype
//
//  Created by Eric Jeong on 06/06/2019.
//  Copyright © 2019 boychaboy. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let impact = UIImpactFeedbackGenerator()
    @IBOutlet weak var recentNotesTable: UITableView!
    
    @IBOutlet weak var addNote: MDCFloatingButton!
    
    @IBAction func addNotePressed(_ sender: Any) {
        impact.impactOccurred()
    }
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
    
    // Search Variables
    let searchController = UISearchController(searchResultsController: nil)
    var filteredNotes = [Note]()
    
//     Search functions
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredNotes = DataManager.shared.noteList.filter({( note : Note) -> Bool in
            return ((note.content?.lowercased().contains(searchText.lowercased()))!||(note.title?.lowercased().contains(searchText.lowercased()))!||(note.album?.lowercased().contains(searchText.lowercased()))!)
        })
        recentNotesTable.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredNotes.count
        }
        
        return DataManager.shared.noteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentNotes", for: indexPath)
        let target : Note
        if isFiltering() {
            target = filteredNotes[indexPath.row]
        }
        else{
            target = DataManager.shared.noteList[indexPath.row]
        }
        cell.textLabel?.text = target.title
        cell.detailTextLabel?.text = formatter.string(for: target.date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let target = DataManager.shared.noteList[indexPath.row]
            DataManager.shared.deleteNote(target)
            DataManager.shared.noteList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "loadNote") {
            guard let cell: UITableViewCell = sender as? UITableViewCell else {
                return
            }
            guard let index: IndexPath = self.recentNotesTable.indexPath(for: cell) else {
                return
            }
            guard let vc : DetailViewController = segue.destination as? DetailViewController else {
                return
            }
            let target : Note
            if isFiltering() {
                target = filteredNotes[index.row]
            } else {
                target = DataManager.shared.noteList[index.row]
            }
            vc.note = target
            vc.indexRow = index.row
//            print("note send to vc at row for \(index.row)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Setup the Searchbar
//        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
        recentNotesTable.delegate = self
        recentNotesTable.dataSource = self

        let plusImage = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
        addNote.setImage(plusImage, for: .normal)
        addNote.setElevation(ShadowElevation(rawValue: 6), for: .normal)
        addNote.setBackgroundColor(UIColor(red: 142/255, green: 250/255,  blue: 0/255, alpha: 1))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataManager.shared.fetchNote()
        deleteBlank()
        recentNotesTable.reloadData()
    }
    
    func deleteBlank(){
        if DataManager.shared.noteList.count > 0 {
            let target = DataManager.shared.noteList[0]
            if (target.title == "") && (target.album == "") && (target.content == "") {
                //print("no title!")
                DataManager.shared.deleteNote(target)
                DataManager.shared.noteList.remove(at: 0)
                //self.deleteRows(at: [indexPath], with: .fade)*/
            }
        }
    }
    
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

