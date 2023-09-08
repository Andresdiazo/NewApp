//
//  OutfitsSaved.swift
//  Outfiter
//
//  Created by Macky on 7/09/23.
//

import Foundation

struct OutfitsSaved: Codable, Identifiable {
    let name: String
    let clothings: [Clothing]
    let id: String
    
    struct Clothing: Codable, Identifiable {
        let name: String
        let color: Color
        let category: Category
        let id: String
        let image_url: String
    }
    
    struct Color: Codable {
        let color: String
        let id: String
    }
    
    struct Category: Codable {
        let category: String
        let id: String
    }
}
