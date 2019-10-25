//
//  ViewController.swift
//  Finder
//
//  Created by Prashant Singh on 7/10/19.
//  Copyright © 2019 Prashant Singh. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate
{
    @IBOutlet weak var mainView: UIView!
    
    let locationManager = CLLocationManager()
    
    var mapView: GMSMapView?

    var markerPositionLat = [Double]()
    var markerPositionLong = [Double]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        self.displayMap()
        self.locationManager.stopUpdatingLocation()
    }

    func displayMap()
    {
        
        
        let zoomLevel:Float = 15
        
        let camera = GMSCameraPosition.camera(withLatitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!, zoom: zoomLevel)

        mapView = GMSMapView(frame: mainView.bounds, camera: camera)
        
        mapView?.settings.myLocationButton = true
        mapView?.isMyLocationEnabled = true
        mapView?.camera = camera
        
        mapView?.mapType = .normal
        
        mainView.addSubview(mapView!)
        
        self.loadMarkers()
            
        
        
        
    }
    
    func getRestaurantsData(completionHandler:@escaping (GooglePlacesResponse?, Error?) -> Void)
    {
        let placeToSearchAround = "\(self.locationManager.location!.coordinate.latitude),\(self.locationManager.location!.coordinate.longitude)"
        let requestString =  "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(placeToSearchAround)&radius=5000&type=restaurant&key=AIzaSyA-Q7RsPXg51TahufwX4zUVtmuLwXWh134"
        print(requestString)
        guard let url = URL(string: requestString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error
            {
                print("Failed To Fetch Data", error)
                return
            }

            DispatchQueue.main.async
                {
                    do
                    {
                        let response = try JSONDecoder().decode(GooglePlacesResponse.self, from: data!)
                        completionHandler(response, nil)
                    } catch let error
                    {
                        completionHandler(nil, error)
                        print("Failed to Decode \(error)")
                    }
                }
            /*
            do
            {
 
                let response = try JSONDecoder().decode(GooglePlacesResponse.self, from: data!)
                completionHandler(response, nil)
            } catch let error
            {
                completionHandler(nil, error)
                print("Failed to Decode \(error)")
            }
*/
        }.resume()
    }
    
    func loadMarkers()
    {
        self.getRestaurantsData { (restaurantData, error) in
            if restaurantData != nil
            {
                for data in restaurantData!.results
                {
                    self.markerPositionLat.append(data.geometry.location.latitude ?? 0.0)
                    self.markerPositionLong.append(data.geometry.location.longitude ?? 0.0)
                    
                }
                
                for i in 0..<self.markerPositionLat.count
                {
                    let location = CLLocationCoordinate2D(latitude: self.markerPositionLat[i], longitude: self.markerPositionLong[i])
                    let marker = GMSMarker()
                    marker.position = location
                    marker.map = self.mapView
                }
            }
        }
    }
}

