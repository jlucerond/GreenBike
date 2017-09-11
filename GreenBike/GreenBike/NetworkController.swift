//
//  NetworkController.swift
//  GreenBike
//
//  Created by Joe Lucero on 9/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import Foundation

class NetworkController {
   let shared = NetworkController()
   
   private let baseURL = "https://api.citybik.es/v2/networks/greenbikeslc"
   
   /// returns info from web with all green bike info. if successful, use the key "stations" to get JSON data of an array of GreenBike stations and their info
   func getBikeInfoFromWeb(completion: @escaping (_ success: Bool, [String : Any]) -> Void) {
      guard let fullURL = URL(string: baseURL) else { completion(false, [:]); return }
      
      var request = URLRequest(url: fullURL)
      request.httpMethod = "GET"
      request.httpBody = nil
      
      let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
         if let error = error { print("Error: \(error.localizedDescription)")
                                 completion(false, [:])
                                 return
         }
         
         guard let data = data else { completion(false, [:]); return }
         
         do {
            let anyData = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            guard let jsonData = anyData as? [String:Any] else { completion(false, [:]); return }
            
            completion(true, jsonData)
            
         } catch {
            // FIXME: Error Handling needs to happen in here
            completion(false, [:]); return
         }
         
         fatalError("coding error: reached end of function without calling completion handler")
      }
      dataTask.resume()
   }
}
