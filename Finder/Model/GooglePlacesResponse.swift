//
//  Restaurants.swift
//  Finder
//
//  Created by Prashant Singh on 10/12/19.
//  Copyright © 2019 Prashant Singh. All rights reserved.
//

import Foundation

struct GooglePlacesResponse : Codable {
    let results : [PlaceDetails]
    enum CodingKeys : String, CodingKey {
        case results = "results"
    }
}

struct PlaceDetails : Codable {
    
    let geometry : Location
    let name : String
    let openingHours : OpenNow?
    let types : [String]
    let address : String
    let rating : Double
    let ratingTotal : Int
    let placeId: String
    
    enum CodingKeys : String, CodingKey {
        case geometry = "geometry"
        case name = "name"
        case openingHours = "opening_hours"
        case types = "types"
        case address = "vicinity"
        case rating = "rating"
        case ratingTotal = "user_ratings_total"
        case placeId = "place_id"
    }
    
    struct Location : Codable {
        
        let location : LatLong
        
        enum CodingKeys : String, CodingKey {
            case location = "location"
        }
        
        struct LatLong : Codable {
            
            let latitude : Double
            let longitude : Double
            
            enum CodingKeys : String, CodingKey {
                case latitude = "lat"
                case longitude = "lng"
            }
        }
    }
    
    struct OpenNow : Codable {
        
        let isOpen : Bool
        
        enum CodingKeys : String, CodingKey {
            case isOpen = "open_now"
        }
    }
}
