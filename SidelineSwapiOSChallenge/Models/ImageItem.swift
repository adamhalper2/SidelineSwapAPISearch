//
//  ImageItem.swift
//  SidelineSwapiOSChallenge
//
//  Created by Adam Halper on 9/27/20.
//  Copyright © 2020 Adam Halper. All rights reserved.
//

import Foundation

struct ImageItem: Decodable {
    let smallUrl : String
    
    enum CodingKeys: String, CodingKey {
        case smallUrl = "small_url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        smallUrl = try values.decode(String.self, forKey: .smallUrl)
    }
}


