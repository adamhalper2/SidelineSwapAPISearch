//
//  NetworkResponse.swift
//  SidelineSwapiOSChallenge
//
//  Created by Adam Halper on 9/27/20.
//  Copyright © 2020 Adam Halper. All rights reserved.
//

import Foundation

struct NetworkResponse {
    
    let items : [ShopItem]
    let pageNumber : Int
    let hasNextPage: Bool
    let totalItemCount : Int
    
    enum CodingKeys: String, CodingKey {
        case items = "data"
        case meta
    }
    
    enum MetaKeys: String, CodingKey {
        case paging
    }
    
    enum PagingKeys: String, CodingKey {
        case hasNextPage = "has_next_page"
        case page
        case totalItemCount = "total_count"
    }
}

extension NetworkResponse: Decodable {
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        items = try values.decode([ShopItem].self, forKey: .items)
        
        let metaInfo = try values.nestedContainer(keyedBy: MetaKeys.self, forKey: .meta)
        let pagingInfo = try metaInfo.nestedContainer(keyedBy: PagingKeys.self, forKey: .paging)
        
        pageNumber = try pagingInfo.decode(Int.self, forKey: .page)
        hasNextPage = try pagingInfo.decode(Bool.self, forKey: .hasNextPage)
        totalItemCount = try pagingInfo.decode(Int.self, forKey: .totalItemCount)
    }
}


