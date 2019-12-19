//
//  ObjectVC.swift
//  Hotaling_Project2
//
//  Created by Student on 12/2/19.
//  Copyright © 2019 Student. All rights reserved.
//

import UIKit

class ObjectVC: UITableViewController {

    //MARK: - Variables
    var objResults:ObjectResults?
    var reducedObjs = [Int]()
    
    //Incoming via segue from CollectionVC
    var selectedDept:Int?
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Request all objects per department
        loadObjects()
    }
    
    //MARK: - Prepare Segue
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        //send the objectID to the next controller to show the details of the exhibit
       if segue.identifier == "showPieceSegue" {
            if let objDetailVC = segue.destination.children[0] as? ObjectTableDetailVC {
                objDetailVC.objectID =  objResults?.objectIDs?[tableView.indexPathForSelectedRow?.row ?? 0] ?? 0
                objDetailVC.title =  "Exhibit \(objResults?.objectIDs?[tableView.indexPathForSelectedRow?.row ?? 0] ?? 0)"
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
        return objResults?.objectIDs?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "objCell", for: indexPath)

        let s = objResults?.objectIDs?[indexPath.row] ?? 0
        cell.textLabel?.text = "Exhibit \(s)"
        
        return cell
    }
    
    //MARK: - Storyboard Action Functions
    @IBAction func closeOut() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Load Obj Data
    func loadObjects(){
       let config = URLSessionConfiguration.default
       let session = URLSession(configuration: config)
        //Makes a request for all objects within the selected department
        let url = URL(string: "https://collectionapi.metmuseum.org/public/collection/v1/objects?departmentIds=\(String(describing: selectedDept))")
   
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
           
           self.objResults = try? JSONDecoder().decode(ObjectResults.self, from: data)
           
           //Reduce array to ~100 items instead of 36k+ IF there were objects returned
           //https://stackoverflow.com/questions/38797663/how-can-i-perform-an-array-slice-in-swift
        
           //Check to make sure more than 0 objects were returned
           if self.objResults?.total ?? 0 > 0 {
                if self.objResults!.objectIDs!.count >= 100 {
                   self.objResults!.objectIDs = Array((self.objResults?.objectIDs?[0 ..< 100])!)
                } else {
                   self.objResults!.objectIDs = (self.objResults?.objectIDs)!
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
