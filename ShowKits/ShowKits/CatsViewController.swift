//
//  CatsViewController.swift
//  ShowKits
//
//  Created by Nikolay Shubenkov on 04/02/16.
//  Copyright © 2016 Nikolay Shubenkov. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage


/*    _locationManager = [[CLLocationManager alloc] init];
assert(self.locationManager);

self.locationManager.delegate = self; // tells the location manager to send updates to this object

// iOS 8 introduced a more powerful privacy model: <https://developer.apple.com/videos/wwdc/2014/?id=706>.
// We use -respondsToSelector: to only call the new authorization API on systems that support it.
//
if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
{
[self.locationManager requestAlwaysAuthorization];

// note: doing so will provide the blue status bar indicating iOS
// will be tracking your location, when this sample is backgrounded
}

// By default we use the best accuracy setting (kCLLocationAccuracyBest)
//
// You may instead want to use kCLLocationAccuracyBestForNavigation, which is the highest possible
// accuracy and combine it with additional sensor data.  Note that level of accuracy is intended
// for use in navigation applications that require precise position information at all times and
// are intended to be used only while the device is plugged in.
//
self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; //kCLLocationAccuracyBest;

// start tracking the user's location
[self.locationManager startUpdatingLocation];*/

class CatsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var apiClient = APIClient()
    var photos:[Photo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate  = self
        locationManager.requestWhenInUseAuthorization()
    }
    

    @IBAction func showMeTheCats(sender: AnyObject) {
        
        let radius:Double = 5
        apiClient.find("cat",
            longitude: mapView.centerCoordinate.longitude,
            latitude: mapView.centerCoordinate.latitude,
            radius: radius) { (success, failure) -> Void in
                
                self.photos = success
                self.updateMapView()
                
        }
    }
    
    func updateMapView(){
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        if self.photos != nil {
            self.mapView.addAnnotations(self.photos!)
        }
        
    }
    
}

extension CatsViewController:CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
            
        case .AuthorizedWhenInUse,
             .AuthorizedAlways:
            
            self.mapView.showsUserLocation = true
            
            
        default:
            print("User denied location")
        }
    }
}

extension CatsViewController:MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let photoToShow = annotation as? Photo else {
            return nil
        }
        
        var photoView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationIdentifier)
        
        if photoView == nil {
            photoView = MKPinAnnotationView(annotation: annotation,
                reuseIdentifier: Constants.AnnotationIdentifier)
        }
        
        let imageView = UIImageView(frame: Constants.imageViewFrame)
        imageView.contentMode = .ScaleAspectFill
        
        photoView?.leftCalloutAccessoryView  = imageView
        photoView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        
        //чтобы показались кнопка и картинка
        photoView?.canShowCallout = true
        
        return photoView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        guard let imageView   = view.leftCalloutAccessoryView as? UIImageView,
              let photoToShow = view.annotation as? Photo  else {
            return
        }
        
//        update(imageView, url: photoToShow.photoURL)
        
        imageView.updateImageWith(photoToShow)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier("Show Image Detailes", sender: view.annotation)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let detailedPhoto = segue.destinationViewController as? PhotoDetailedViewController,
            let photo = sender as? Photo else {
                return
        }
        detailedPhoto.photo = photo
    }
    
    
    func update(imageView:UIImageView, url:String){
        guard let url = NSURL(string: url) else {
                return
        }
        
        guard let data = NSData(contentsOfURL: url) else {
            return
        }
        
        let image = UIImage(data: data)
        
        imageView.image = image
        
    }
}



//MARK: - Constants

extension CatsViewController {
    private struct Constants {
        static let AnnotationIdentifier = "PhotoAnnotationView"
        static let imageViewFrame = CGRect(x: 0, y: 0, width: 50, height:50)
    }
}

//MARK: - UIImageView Extention 

extension UIImageView {
    private struct Constants {
        static let defaultIconWidth = 240
    }
    
    func updateImageWith(photo:Photo?) {
        guard let photoToApply = photo else {
            self.image = nil
            return
        }
        
        //image width
        let width = photoToApply.iconWidth > 0 ? photoToApply.iconWidth : Constants.defaultIconWidth
        
        let url   =  CGFloat(width) > frame.size.width ? photoToApply.iconURL : photoToApply.photoURL
        
        sd_setImageWithURL(NSURL(string: url),
            placeholderImage: nil,
            options: [ .ProgressiveDownload])
        
    }
}















