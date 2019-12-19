//
//  CollectionVC.swift
//  Hotaling_Project2
//
//  Created by Student on 11/21/19.
//  Copyright © 2019 Student. All rights reserved.
//

import UIKit

//load in UITextFieldDelegate for our custom search bar
class CollectionVC: UITableViewController, UITextFieldDelegate  {
    
    //MARK: - Variables
    //grab the textfield that we're using as a searchbar
    @IBOutlet weak var searchBar: UITextField!
    
    //var to store returned DepartmentResults
    var deptResults:DepartmentResults?
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if the user has already searched something, that's the placeholder in the searchbar
        searchBar.delegate = self
        searchBar.placeholder = UserDefaults.standard.string(forKey: "lastSearched")
        
        //make request for all the departments
        loadData()
    }

    // MARK: - Prepare Segue
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        //Segue to view the chosen collection's exhibits
        if segue.identifier == "showCollectionSegue" {
            let objVC = segue.destination.children[0] as! ObjectVC

            objVC.selectedDept =  deptResults?.departments?[tableView.indexPathForSelectedRow?.row ?? 0].departmentId ?? 1
            objVC.title =  deptResults?.departments?[tableView.indexPathForSelectedRow?.row ?? 0].displayName ?? "American Decorative Arts"
        }
        
        //Segue to show the returned results from a custom search
        if segue.identifier == "showSearchSegue" {
            let searchVC = segue.destination.children[0] as! SearchVC
            
            //Make sure there's no white space in the search term
            let search = searchBar.text ?? ""
            let fixedSearch = search.replacingOccurrences(of: " ", with: "%20")
            
            UserDefaults.standard.set(search, forKey: "lastSearched")

            searchVC.searchTerm = fixedSearch
            searchVC.title = search
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return deptResults?.departments?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectCell", for: indexPath)

        
        let s = deptResults?.departments?[indexPath.row].displayName ?? "No department found"
        cell.textLabel?.text = s
        
        return cell
    }
    
    // MARK: - Load Dept Data
    func loadData(){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        //request for all MET public collection departments
        let url = URL(string: "https://collectionapi.metmuseum.org/public/collection/v1/departments")
        
        // 1 - set up the dataTask and callback function
        let dataTask = session.dataTask(with: url! as URL, completionHandler:{
            (data:Data?, response:URLResponse?, error:Error?) -> Void in
            
            // 2 - is there an error? Bail out!
            guard error == nil else{
                print("error = \(String(describing: error))")
                return
            }
            
            // 3 - is there no data? Bail out!
            guard let data = data else{
                print("No data!")
                return
            }
        
            self.deptResults = try? JSONDecoder().decode(DepartmentResults.self, from: data)
            
            // callback to main thread
            // DispatchQueue.main.async(execute:)
            // we'll use "trailing closure syntax" below
            DispatchQueue.main.async { [weak self] in
                self?.tableView?.reloadData()
            }
            
        })
        
        // 7 - this actually starts the download
        dataTask.resume()
    }
}
