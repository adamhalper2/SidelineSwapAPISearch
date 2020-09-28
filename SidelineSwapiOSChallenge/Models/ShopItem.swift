//
//  ShopItem.swift
//  SidelineSwapiOSChallenge
//
//  Created by Adam Halper on 9/27/20.
//  Copyright © 2020 Adam Halper. All rights reserved.
//

import UIKit

struct ShopItem {
    
    var itemName: String
    var sellerName: String
    var price: Double
    var images: [ImageItem]?
    
    init(itemName: String, sellerName: String, price: Double) {
        self.itemName = itemName
        self.sellerName = sellerName
        self.price = price
        self.images = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case itemName = "name"
        case price = "price"
        case images
        case seller
    }
    
    enum SellerKeys: String, CodingKey {
        case username
    }
    
    enum ImageKeys: String, CodingKey {
        case imageUrl = "small_url"
    }
}

extension ShopItem: Decodable {
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        itemName = try values.decode(String.self, forKey: .itemName)
        price = try values.decode(Double.self, forKey: .price)
        images = try values.decode([ImageItem].self, forKey: .images)

        let sellerInfo = try values.nestedContainer(keyedBy: SellerKeys.self, forKey: .seller)
        sellerName = try sellerInfo.decode(String.self, forKey: .username)
    }

}

extension ShopItem {
    
    static func items(matching query: String, page: Int?, completion: @escaping ((NetworkResponse?) -> Void)) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.staging.sidelineswap.com"
        components.path = "/v1/facet_items"
        var queryItems = [URLQueryItem(name: "q", value: query)]
        if let pageNumber = page {
            let pageQuery = URLQueryItem(name: "page", value: "\(pageNumber)")
            queryItems.append(pageQuery)
        }
        components.queryItems = queryItems
        
        let searchURL = components.url!
        Networking.loadData(searchURL) { (response, success) in
            completion(response)
        }
    }
}
