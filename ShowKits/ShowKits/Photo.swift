//
//  Photo.swift
//  ShowKits
//
//  Created by Nikolay Shubenkov on 04/02/16.
//  Copyright © 2016 Nikolay Shubenkov. All rights reserved.
//

import UIKit
import MapKit

class Photo: NSObject, MKAnnotation  {
    var name:String?
    var coordinate:CLLocationCoordinate2D
    var photoURL = ""
    var iconURL  = ""
    var iconWidth = 0
    var photoDescription = ""
    var ownerID = ""
    var title: String? {
        return name
    }
    
    init(info:[String:AnyObject]){
        if let parsedName = info["title"] as? String {
            name = parsedName
        }
        
        if let ownerIdValue = info["owner"] as? String {
            ownerID = ownerIdValue
        }
        
        guard let long = info["longitude"] as? String,
            let lat  = info["latitude"] as? String else {
                coordinate = CLLocationCoordinate2D(latitude: -500, longitude: -500)
                super.init()
                return
        }
        
        coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
        
        if let url = info["url_l"] as? String {
            photoURL = url
        }
        
        if let iconURLValue = info["url_s"] as? String {
            iconURL = iconURLValue
        }
        
        if let description = info["description"] as? [String:String],
           let descriptionContent = description["_content"] {
            photoDescription  = descriptionContent
        }
        if photoDescription.isEmpty {
            print("not found description")
        }

        if let iconWidthValue = info["width_s"] as? Int {
            iconWidth = iconWidthValue
        }
        
        super.init()
     }
}
