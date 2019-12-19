//
//  ArtResults.swift
//  Hotaling_Project2
//
//  Created by Student on 12/2/19.
//  Copyright © 2019 Student. All rights reserved.
//

import Foundation

//holds the detail information for each specific object/artpiece
class ArtResults: Codable {
    var title: String?
    var artistDisplayName: String?
    
    var objectDate: String?
    var period: String?
    var medium: String?
    
    var rightsAndReproduction: String?
    var objectURL: String?
}
