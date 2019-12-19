//
//  ObjectTableDetailVC.swift
//  Hotaling_Project2
//
//  Created by Student on 12/9/19.
//  Copyright © 2019 Student. All rights reserved.
//

import UIKit

class ObjectTableDetailVC: UITableViewController {
    //MARK: - Variables
    var artResults:ArtResults?
    
    //setup for detail table view
    let artCell = "artCell"
    let numSections = 5
    let rowsPerSection = 1
    enum MySection: Int {
        case title = 0, artistInfo, otherInfo, viewOnWeb, copyright
    }
    
    var objectID:Int?

    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        //request specific art pieces via ID
        loadArt()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return numSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rowsPerSection
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: artCell, for: indexPath)

        // Configure the art title row
        if indexPath.section == MySection.title.rawValue{
            cell.textLabel?.numberOfLines = 6
            cell.textLabel?.text = "\(String(describing: artResults?.title ?? "Title Unknown"))"
            cell.textLabel?.font = UIFont(name: "Didot", size: 26.0)
            cell.textLabel?.textAlignment = NSTextAlignment.center
            cell.isUserInteractionEnabled = false;
        }

        //configure the artist name row
        if indexPath.section == MySection.artistInfo.rawValue{
            cell.textLabel?.numberOfLines = 4
            cell.textLabel?.text = "\(String(describing: artResults?.artistDisplayName ?? "Artist Unknown"))"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18.0)
            cell.textLabel?.textAlignment = NSTextAlignment.center
            cell.textLabel?.textColor = UIColor.gray
            cell.isUserInteractionEnabled = false;
        }

        // Configure the medium/period/date row
        if indexPath.section == MySection.otherInfo.rawValue{
            cell.textLabel?.numberOfLines = 4
            cell.textLabel?.text = "\(String(describing: artResults?.objectDate ?? "Date Unknown")), \(String(describing: artResults?.period  ?? "Period Unknown")) \n\(String(describing: artResults?.medium  ?? "Medium Unknown"))"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18.0)
            cell.textLabel?.textAlignment = NSTextAlignment.center
            cell.isUserInteractionEnabled = false;
        }

        //configure the view on web row, this is the only one that's clickable
        if indexPath.section == MySection.viewOnWeb.rawValue{
            cell.textLabel?.text = "View Art Piece"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18.0)
            cell.textLabel?.textColor = view.tintColor
            cell.textLabel?.textAlignment = NSTextAlignment.center
        }

        //configure copyright row
        if indexPath.section == MySection.copyright.rawValue{
            cell.textLabel?.numberOfLines = 3
            cell.textLabel?.text = "\(String(describing: artResults?.rightsAndReproduction ?? "No Copyright Data"))"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
            cell.textLabel?.textAlignment = NSTextAlignment.center
            cell.textLabel?.textColor = UIColor.gray
            cell.isUserInteractionEnabled = false;
        }


        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == MySection.title.rawValue{
            return 150.0
        }
        
        if indexPath.section == MySection.artistInfo.rawValue{
            return 50.0
        }
        
        if indexPath.section == MySection.otherInfo.rawValue{
            return 120.0
        }
        
        if indexPath.section == MySection.viewOnWeb.rawValue{
            //if there's no objectURL provided, don't display the view on web row
            if(artResults?.objectURL != nil) {
                return 40.0
            } else {
                return 0.0
            }

        }
        
        return 40.0
    }
    
    //MARK: - Prepare Segue
    override func prepare(for segue:UIStoryboardSegue, sender: Any?) {
        //pass object URL to web view (or 404 page if for some reason the cell still displays but there's no URL)
          if segue.identifier == "showOnWebSegue" {
            if let webVC = segue.destination as? WebVC {
                webVC.artURL = artResults?.objectURL ?? "https://www.metmuseum.org/404"
            }
          }
      }
    
    //MARK: - Preform Segue
    //Doing this is didSelectRowAt due to rows being generated programatically
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showOnWebSegue", sender: self)
    }
    
    //MARK: - Storyboard Action Functions
    @IBAction func closeOut() {
         dismiss(animated: true, completion: nil)
     }
    
    // MARK: - Load Art Data
    func loadArt(){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        //Make a request for that single specific object by ID
        let url = URL(string: "https://collectionapi.metmuseum.org/public/collection/v1/objects/\(objectID ?? 1)")
    
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
            
            self.artResults = try? JSONDecoder().decode(ArtResults.self, from: data)


            // callback to main thread
            // we'll use "trailing closure syntax" below
            DispatchQueue.main.async { [weak self] in
                self?.tableView?.reloadData()
            }
            
        })
        
        // 7 - this actually starts the download
        dataTask.resume()
    }

}
