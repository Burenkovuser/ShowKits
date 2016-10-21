//
//  APIClient.swift
//  ShowKits
//
//  Created by Nikolay Shubenkov on 04/02/16.
//  Copyright © 2016 Nikolay Shubenkov. All rights reserved.
//

import UIKit
import Alamofire

/*
parameters[@"tags"] = @"cats";
parameters[@"bbox"] = @"bbox";
parameters[@"lat"]  = @(self.mapView.centerCoordinate.latitude);
parameters[@"lon"]  = @(self.mapView.centerCoordinate.longitude);
parameters[@"radius"] = @"5";
parameters[@"extras"] = @"url_l,geo,date_taken,owner_name";
parameters[@"format"] = @"json";


parameters[@"content_type"] = @1;
parameters[@"nojsoncallback"] = @1;

parameters[@"method"] = @"flickr.photos.search";

parameters[@"api_key"] = @"2b2c9f8abc28afe8d7749aee246d951c";
*/

class APIClient: NSObject {
    
    static let apiURL = "https://api.flickr.com/services/rest/"
    
    func find(searchName:String,
               longitude:Double,
                latitude:Double,
                 radius:Double,
              completion:(success:[Photo]?,failure:NSError?)->Void
        ){
            var params = [String:AnyObject]()
            
            params["tags"] = searchName
            params["bbox"] = "bbox"
            params["lat"]  = latitude
            params["lon"]  = longitude
            params["radius"] = radius
            params["extras"] = "url_l,geo,date_taken,owner_name,url_s,description"
            params["per_page"] = 100
            params["format"] = "json"
            params["content_type"]   = 1
            params["nojsoncallback"] = 1
            
            params["method"] = "flickr.photos.search"
            params["api_key"] = "2b2c9f8abc28afe8d7749aee246d951c"
            
            
            Alamofire.request(.GET,
                APIClient.apiURL,
                parameters: params,
                encoding: .URL,
                headers: nil)
            .responseJSON { response -> Void in
                
                if response.result.error != nil {
                    completion(success: nil, failure: response.result.error!)
                    return
                }
                
                
                let results = self.parsePhotosFrom(response.result.value as! [String:AnyObject])
                
                completion(success: results, failure: nil)
            }
    }
    
    func parsePhotosFrom(info:[String:AnyObject])->[Photo] {
        
        //photos
        //photo
        guard let photos = info["photos"] as? [String : AnyObject],
               let photo = photos["photo"] as? [ [String : AnyObject] ]
            else {
                return [Photo]()
        }
        
        var parsedPhotos = [Photo]()
        
        for info in photo {
            parsedPhotos.append(Photo(info: info))
        }
        
        return parsedPhotos
    }
}










