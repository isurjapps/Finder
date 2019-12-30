//
//  getData.swift
//  Finder
//
//  Created by Prashant Singh on 10/12/19.
//  Copyright © 2019 Prashant Singh. All rights reserved.
//

import Foundation

class GetGoogleResponseData
{
    static let shared = GetGoogleResponseData()
    
    func getData(fromURL url: URL, completion: @escaping (GooglePlacesResponse?, Error?) -> Void)
    {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do
            {
                let response = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)
                completion(response, nil)
            } catch let error
            {
                completion(nil, error)
                print("Failed to Decode \(error)")
            }
        }
        task.resume()
    }
}
