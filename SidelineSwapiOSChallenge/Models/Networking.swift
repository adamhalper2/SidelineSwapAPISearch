//
//  Networking.swift
//  SidelineSwapiOSChallenge
//
//  Created by Adam Halper on 9/27/20.
//  Copyright © 2020 Adam Halper. All rights reserved.
//

import Foundation

enum NetworkError: Error {
  case dateParseError
  case invalidPath
  case parseError
  case requestError
}

class Networking {
    
    static func loadData(_ url: URL, completionHandler: @escaping (NetworkResponse?, Bool?) -> Void) {
        Networking.loadJSON(url: url, completionHandler: { (response, error) in
            completionHandler(response, true)
        })
    }

    static func loadJSON(url: URL, completionHandler: @escaping (NetworkResponse?, NetworkError?) -> Void) {

        let request = URLRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200
            if statusCode != 200 {
                completionHandler(nil, .requestError)
                return
            }
            if let jsonData = data, let networkResponse = parseJsonData(jsonData) {
                DispatchQueue.main.async {
                    completionHandler(networkResponse, nil)
                }
            }
        }
        dataTask.resume()
    }
    
    static func parseJsonData(_ data: Data) -> NetworkResponse? {
        let decoder = JSONDecoder()
        do {
            let networkResponse = try decoder.decode(NetworkResponse.self, from: data)
            return networkResponse
        } catch {
            print("error: \(error)")
            return nil
        }
    }
}

