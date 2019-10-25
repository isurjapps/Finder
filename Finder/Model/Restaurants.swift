//
//  Restaurants.swift
//  Finder
//
//  Created by Prashant Singh on 12/10/19.
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
    let photos : [Photos]
    let types : [String]
    let address : String
    
    enum CodingKeys : String, CodingKey {
        case geometry = "geometry"
        case name = "name"
        case openingHours = "opening_hours"
        case photos = "photos"
        case types = "types"
        case address = "vicinity"
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
    
    struct Photos : Codable {
        
        let height : Int
        let width : Int
        let photoReference : String
        
        enum CodingKeys : String, CodingKey {
            case height = "height"
            case width = "width"
            case photoReference = "photo_reference"
        }
    }
}
