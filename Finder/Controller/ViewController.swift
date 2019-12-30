//
//  ViewController.swift
//  Finder
//
//  Created by Prashant Singh on 14/12/19.
//  Copyright © 2019 Prashant Singh. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate
{
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var restaurantSummaryView: UIView!
    @IBOutlet weak var summaryImageScrollView: UIScrollView!
    @IBOutlet weak var summaryRestName: UILabel!
    @IBOutlet weak var summaryRating: UILabel!
    @IBOutlet weak var summaryNumberRatings: UILabel!

    @IBOutlet weak var ratingStarImage1: UIImageView!
    @IBOutlet weak var ratingStarImage2: UIImageView!
    @IBOutlet weak var ratingStarImage3: UIImageView!
    @IBOutlet weak var ratingStarImage4: UIImageView!
    @IBOutlet weak var ratingStarImage5: UIImageView!
    
    @IBOutlet weak var openHours: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var webSite: UILabel!
    @IBOutlet weak var websiteImage: UIImageView!
    @IBOutlet weak var addressImage: UIImageView!
    @IBOutlet weak var phoneImage: UIImageView!
    @IBOutlet weak var listViewButton: UIButton!
    @IBOutlet weak var restaurantTableView: UITableView!
    @IBOutlet weak var backgroundForTableView: UIView!
    @IBOutlet weak var closeTableView: UIButton!
    
    
    var screenMaxLength: CGFloat = 0.0
    var screenMaxWidth: CGFloat = 0.0
    var mapView: GMSMapView?
    let locationManager = CLLocationManager()
    lazy var placesSummaryDic = [[String:Any]]()
    var placesDictionary = [[String:Any]]()
    
    let cellID = "RestaurantTableViewCell"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        let screenBounds: CGRect = self.view.bounds
        screenMaxLength = screenBounds.maxY
        screenMaxWidth = screenBounds.maxX
    
        let summaryViewGesture = UIPanGestureRecognizer(target: self, action: #selector(viewDragged(gestureRecognizer:)))
        restaurantSummaryView.addGestureRecognizer(summaryViewGesture)
        restaurantSummaryView.isUserInteractionEnabled = true
        
        restaurantTableView.register(UINib.init(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        restaurantTableView.rowHeight = 320
        restaurantTableView.estimatedRowHeight = UITableView.automaticDimension
        restaurantTableView.delegate = self
        restaurantTableView.dataSource = self
    }
    
    func getRestaurantsData()
    {
        let placeToSearchAround = "\(self.locationManager.location!.coordinate.latitude),\(self.locationManager.location!.coordinate.longitude)"
        
        let requestString =  "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(placeToSearchAround)&radius=5000&type=restaurant&key=AIzaSyA-Q7RsPXg51TahufwX4zUVtmuLwXWh134"
        
        guard let url = URL(string: requestString) else { return }
        
        placesSummaryDic.removeAll()
        
        GetGoogleResponseData.shared.getData(fromURL: url) { (response, error) in
            if error != nil
            {
                return
            }
            for data in response!.results
            {
                let name = data.name
                let rating = data.rating
                let ratingTotal = data.ratingTotal
                let lat = data.geometry.location.latitude
                let long = data.geometry.location.longitude
                let placeId = data.placeId
                
                let item = ["name": name, "rating": rating, "ratingTotal": ratingTotal, "lat": lat, "long": long, "placeId": placeId] as [String : Any]

                self.placesSummaryDic.append(item)
                DispatchQueue.main.async
                {
                    self.loadMarkers(placesDictionary: self.placesSummaryDic)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        self.displayMap()
        self.locationManager.stopUpdatingLocation()
    }
    
    @objc func viewDragged(gestureRecognizer: UIPanGestureRecognizer)
    {
        let translation = gestureRecognizer.translation(in: self.view)
        
        if translation.y > 0
        {
            UIView.animate(withDuration: 1.0)
            {
                self.restaurantSummaryView.frame.origin.y = self.screenMaxLength + 5000.0
                self.listViewButton.isHidden = false
            }
        }
        gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @IBAction func listViewTappoed(_ sender: Any)
    {
        UIView.animate(withDuration: 1.0)
        {
            self.restaurantTableView.reloadData()
            self.listViewButton.isHidden = true
            self.restaurantTableView.isHidden = false
            self.backgroundForTableView.isHidden = false
            self.closeTableView.isHidden = false
        }
    }
    
    @IBAction func closeTableViewTapped(_ sender: Any)
    {
        UIView.animate(withDuration: 1.0)
        {
            self.listViewButton.isHidden = false
            self.restaurantTableView.isHidden = true
            self.backgroundForTableView.isHidden = true
            self.closeTableView.isHidden = true
        }
    }
    
    
    func displayMap()
    {
        let zoomLevel:Float = 15
        
        let camera = GMSCameraPosition.camera(withLatitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!, zoom: zoomLevel)

        mapView = GMSMapView(frame: self.view.bounds, camera: camera)
        self.mapView?.delegate = self
        mapView?.settings.myLocationButton = true
        mapView?.isMyLocationEnabled = true
        mapView?.camera = camera
        
        mapView?.mapType = .normal

        mainView.addSubview(mapView!)
        mainView.addSubview(restaurantSummaryView)
        mainView.addSubview(listViewButton)
        mainView.addSubview(backgroundForTableView)
        backgroundForTableView.addSubview(restaurantTableView)

    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D)
    {
        UIView.animate(withDuration: 1.0)
        {
            self.restaurantSummaryView.frame.origin.y = 5000
            self.listViewButton.isHidden = false
        }
    }
    
    func loadMarkers(placesDictionary: [[String:Any]])
    {
        for i in 0..<placesDictionary.count
        {
            let name = placesDictionary[i]["name"] as? String ?? ""
            let lat  = placesDictionary[i]["lat"] as? Double ?? 0.0
            let long = placesDictionary[i]["long"] as? Double ?? 0.0
                       
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let marker = GMSMarker()
            marker.position = location
            marker.map = self.mapView
            marker.snippet = name
        }
    }
}


extension ViewController: GMSMapViewDelegate
{
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView)
    {
        self.getRestaurantsData()
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker)
    {
        listViewButton.isHidden = true
        UIView.animate(withDuration: 1.0)
        {
            self.restaurantSummaryView.frame.origin.y = self.view.bounds.maxY - (self.restaurantSummaryView.frame.maxY - self.restaurantSummaryView.frame.minY)
        }
        for places in placesSummaryDic
        {
            if  (places["lat"] as! Double == marker.position.latitude) &&
                (places["long"] as! Double == marker.position.longitude)
            {
                summaryRestName.text = places["name"] as! String
                summaryRating.text = String(format: "%.1f", (places["rating"] as! Double))
                summaryNumberRatings.text = String(places["ratingTotal"] as! Int)
                
                guard let restaurantRating: Double = places["rating"] as! Double else { return }
                
                ratingStarsImages(restRating: restaurantRating, imageComponents: [ratingStarImage1, ratingStarImage2, ratingStarImage3, ratingStarImage4, ratingStarImage5])
                
                let imagePosX = self.summaryImageScrollView.frame.minX
                let imagePosY = self.summaryImageScrollView.frame.minY
                let imageWidth = self.summaryImageScrollView.frame.width/1.5
                
                var imageService: GoogleImageService? = GoogleImageService()
                imageService!.fetchPhotos(placeID: places["placeId"] as! String, scrollViewName: self.summaryImageScrollView, imgPosX: imagePosX, imgPosY: imagePosY, imgWidth: imageWidth)
                imageService = nil
                
                var additionalDetailsService: GoogleAdditionalService? = GoogleAdditionalService()
                additionalDetailsService?.fetchPlaceAdditinalDetails(placeID: places["placeId"] as! String, labelName1: openHours, labelName2: phoneNumber, labelName3: address, labelName4: webSite)
                additionalDetailsService = nil
            }
        }
    }

    func ratingStarsImages(restRating: Double, imageComponents: [UIImageView])
    {
        for (starNumber, starImageView) in imageComponents.enumerated()
        {
            starImageView.image = getRatingStarImage(starNumber: Double(starNumber) + 1, restaurantRating: restRating)
        }
    }
    
    func getRatingStarImage(starNumber: Double, restaurantRating: Double) -> UIImage
    {
        let fullStarImage: UIImage = UIImage(named: "Fullstar.png")!
        let halfStarImage: UIImage = UIImage(named: "Halfstar.png")!
        let noStarImage: UIImage = UIImage(named: "Nostar.png")!
        
        if restaurantRating >= starNumber
        {
            return fullStarImage
        } else if restaurantRating + 0.9 >= starNumber
        {
            return halfStarImage
        } else
        {
            return noStarImage
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return placesSummaryDic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! RestaurantTableViewCell
        cell.selectionStyle = .none
        
        let dataToLoad = placesSummaryDic[indexPath.row]
        cell.cellRestName.text = dataToLoad["name"] as! String
        cell.cellRestRating.text = String(format: "%.1f", (dataToLoad["rating"] as! Double))
        cell.cellTotalRating.text = String(dataToLoad["ratingTotal"] as! Int)
        
        let restaurantRating: Double = dataToLoad["rating"] as! Double
            
        ratingStarsImages(restRating: restaurantRating, imageComponents: [cell.cellRatingStar1, cell.cellRatingStar2, cell.cellRatingStar3, cell.cellRatingStar4, cell.cellRatingStar5])
        
        let imagePosX = cell.cellScrollView.frame.minX
        let imagePosY = cell.cellScrollView.frame.minY
        let imageWidth = cell.cellScrollView.frame.width/1.5
        
        var imageService: GoogleImageService? = GoogleImageService()
        imageService!.fetchPhotos(placeID: dataToLoad["placeId"] as! String, scrollViewName: cell.cellScrollView, imgPosX: imagePosX, imgPosY: imagePosY, imgWidth: imageWidth)
        imageService = nil
        
        var additionalDetailsService: GoogleAdditionalService? = GoogleAdditionalService()
        additionalDetailsService?.fetchPlaceAdditinalDetails(placeID: dataToLoad["placeId"] as! String, labelName1: cell.cellOpenHours, labelName2: nil, labelName3: nil, labelName4: nil)
       
        additionalDetailsService = nil
    
        return cell
    }
}

class GoogleImageService: NSObject
{
    func fetchPhotos(placeID: String, scrollViewName: UIScrollView, imgPosX: CGFloat, imgPosY: CGFloat, imgWidth: CGFloat)
    {
        //MARK: - Load Photos - Start
        let placesClient = GMSPlacesClient.shared()
    
        placesClient.lookUpPhotos(forPlaceID: placeID, callback: { [weak scrollViewName] (photos, error) -> Void in
        
        if let error = error{
          print("Error retrieving photos: \(error.localizedDescription)")
          return
        } else
        {
            if photos == nil
            {
                return
            }
            
            var imagePosX = imgPosX
            let imagePosY = imgPosY
            let imageWidth = imgWidth
            
            var x = 1
            let seperator: CGFloat = 5.0
            
           for photoMetaData in photos!.results
           {
                 placesClient.loadPlacePhoto(photoMetaData, callback: { [weak scrollViewName] (photo, error) -> Void in
                 if let error = error {
                   print("Error loading photo metadata: \(error.localizedDescription)")
                   return
                 } else
                 {
                    let restImageView = UIImageView()
                    restImageView.image = photo
                    restImageView.frame = CGRect(x: imagePosX, y: imagePosY, width: imageWidth, height: scrollViewName!.frame.height)
                    scrollViewName!.contentSize.width = imageWidth  * CGFloat(x-1)
                    scrollViewName!.addSubview(restImageView)
                    
                    imagePosX = imagePosX + imageWidth + seperator
                 }
               })
                x = x + 1
            }
            }})
    }
}

class GoogleAdditionalService: NSObject
{
    func fetchPlaceAdditinalDetails(placeID: String, labelName1: UILabel, labelName2: UILabel?, labelName3: UILabel?, labelName4: UILabel?)
       {
           //MARK: - Get Open Hours, Phone Number, Address and Website
           let placesClient = GMSPlacesClient.shared()
           let date = Date()
           let calendar = Calendar.current
           let weekDay = calendar.component(.weekday, from: date)
           _ = calendar.component(.minute, from: date)
           var openingHoursStr = ""
        
           placesClient.lookUpPlaceID(placeID, callback: { [weak labelName1] (place, error) -> Void in
           if let error = error {
             print("Lookup place id query error: \(error.localizedDescription)")
             return
           }
               
           if let place = place
           {
                if labelName2 != nil
                {
                    labelName2?.text = place.phoneNumber
                }
            
                if labelName3 != nil
                {
                    labelName3?.text = place.formattedAddress
                }
                
                if labelName4 != nil
                {
                    do
                    {
                         let webLink = try place.website?.absoluteString
                        labelName4?.text = webLink
                    } catch let error
                    {
                        labelName4?.text = ""
                         print("Failed to Convert \(error)")
                    }
                }

               if place.openingHours?.periods == nil
               {
                   return
               }
               for periods in (place.openingHours?.periods)!
               {
                   if periods.self.openEvent.day == GMSDayOfWeek(rawValue: GMSDayOfWeek.RawValue(weekDay))!
                   {
                       let fromHH = periods.openEvent.time.hour
                       let fromMM = periods.openEvent.time.minute
                       var padding = ""
                       
                       if fromMM == 0
                       {
                           padding = "0"
                       } else
                       {
                           padding = ""
                       }
                       
                       let fromHours = String(fromHH) + ":" + String(fromMM) + padding

                       let toHH = periods.closeEvent?.time.hour ?? 0
                       let toMM = periods.closeEvent?.time.minute ?? 0
                       
                       if toMM == 0
                       {
                           padding = "0"
                       } else
                       {
                           padding = ""
                       }
                       
                       let toHours = String(toHH) + ":" + String(toMM) + padding
                       openingHoursStr = "Opening Hours: " + fromHours + " - " + toHours
                       labelName1!.text = openingHoursStr
                   }
               }
               
             } else {
               print("No place details")
             }
           })
       }
}
