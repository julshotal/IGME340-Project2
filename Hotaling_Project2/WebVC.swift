//
//  WebVC.swift
//  Hotaling_Project2
//
//  Created by Student on 12/9/19.
//  Copyright © 2019 Student. All rights reserved.
//

import UIKit
import WebKit

class WebVC: UIViewController, WKUIDelegate {

    //Grab the web view from the view controller
    @IBOutlet weak var webView: WKWebView!
    var artURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //pass the URL given by the previous controller
        //Again, the 404 error is passed just in case a URL wasn't given
        let reqURL = URL(string: artURL ?? "https://www.metmuseum.org/404")
        let request = URLRequest(url: reqURL!)
        
        //load request into webView
        webView.load(request)
    }
}
