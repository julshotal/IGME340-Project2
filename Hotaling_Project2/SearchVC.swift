//
//  SearchVC.swift
//  Hotaling_Project2
//
//  Created by Student on 12/11/19.
//  Copyright © 2019 Student. All rights reserved.
//

import UIKit

class SearchVC: UITableViewController {
    
    //MARK: - Variables
    var searchResults:ObjectResults?
    var searchTerm : String?
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        //request objects for that search query
        loadSearch()
    }
    
    //MARK: - Prepare Segue
      override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "showSearchPieceSegue" {
            if let objDetailVC = segue.destination.children[0] as? ObjectTableDetailVC {
                objDetailVC.objectID =  searchResults?.objectIDs?[tableView.indexPathForSelectedRow?.row ?? 0] ?? 0
                objDetailVC.title =  "Exhibit \(searchResults?.objectIDs?[tableView.indexPathForSelectedRow?.row ?? 0] ?? 0)"
            }
           }
       }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResults?.objectIDs?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)

        let s = searchResults?.objectIDs?[indexPath.row] ?? 0
        cell.textLabel?.text = "Exhibit \(String(describing: s))"

        return cell
    }
    
    //MARK: - Storyboard Action Functions
    @IBAction func closeOut() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Load Search Data
    func loadSearch(){
          let config = URLSessionConfiguration.default
          let session = URLSession(configuration: config)
          let url = URL(string: "https://collectionapi.metmuseum.org/public/collection/v1/search?q=\(searchTerm ?? "")")
      
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
            
              self.searchResults = try? JSONDecoder().decode(ObjectResults.self, from: data)
            
              //Reduce array to ~100 items IF there were objects returned
              //https://stackoverflow.com/questions/38797663/how-can-i-perform-an-array-slice-in-swift
            
             //Check to make sure more than 0 objects were returned
               if self.searchResults?.total ?? 0 > 0 {
                     if self.searchResults!.objectIDs!.count >= 100 {
                        self.searchResults!.objectIDs = Array((self.searchResults?.objectIDs?[0 ..< 100])!)
                     } else {
                        self.searchResults!.objectIDs = (self.searchResults?.objectIDs)!
                     }
                }

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
