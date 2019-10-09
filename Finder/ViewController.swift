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
    
    var mapTypeNormal = true
    
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

        configureSatelliteButton()
        
        configureSegmentedControl()
    }
    
    func configureSatelliteButton()
    {
        let image = UIImage(named: "SatelliteIcon") as UIImage?
        
        let satelliteButtonHeight: CGFloat = mainView.bounds.height/20
        let satelliteButtonWidth: CGFloat = satelliteButtonHeight
        
        let satelliteButtonPosX: CGFloat = mainView.frame.maxX - satelliteButtonWidth - 10
        let satelliteButtonPosY: CGFloat = mainView.frame.minY + 150
        
        let satelliteButton = UIButton(frame: CGRect(x: satelliteButtonPosX, y: satelliteButtonPosY, width: satelliteButtonWidth, height: satelliteButtonHeight))
        
        satelliteButton.setImage(image, for: .normal)
        
        satelliteButton.addTarget(self, action: #selector(toggleMapType), for: .touchUpInside)
        
        mainView.addSubview(satelliteButton)
    }

    @objc func toggleMapType()
    {
        if mapTypeNormal == true
        {
            mapTypeNormal = false
            mapView?.mapType = .satellite
        } else
        {
            mapTypeNormal = true
            mapView?.mapType = .normal
        }
    }
    
    func configureSegmentedControl()
    {
        let itemsToDisplay = ["Show on Map", "Show as List"]
        
        let segControlWidth = mainView.bounds.width / 2
        let segControlPosX = mainView.frame.midX - (segControlWidth / 2)
        let segControlPosY = mainView.frame.minY + 50
        
        let segmentedControl = UISegmentedControl(items: itemsToDisplay)
        segmentedControl.frame = CGRect(x: segControlPosX, y: segControlPosY, width: segControlWidth, height: 30)
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.layer.cornerRadius = 5
        segmentedControl.backgroundColor = UIColor.gray
        
        mainView.addSubview(segmentedControl)
    }
}

