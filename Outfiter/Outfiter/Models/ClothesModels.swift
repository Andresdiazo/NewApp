//
//  Models.swift
//  Outfiter
//
//  Created by Macky on 7/09/23.
//

import Foundation

struct Clothes: Codable, Identifiable {
    let id: String?
    let name: String?
    let category: Category?
    let color: Color?
    let imgURL: String?
    var clothings: [Clothing]?
    var isSelected: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, name, imgURL
        case category = "category"
        case color = "color"
    }
}

struct Category: Codable {
    let id: String?
    let category: String?
    let image_url: String?
}

struct Color: Codable {
    let id: String?
    let color: String?
}

struct Clothing: Codable, Identifiable {
    let id: String?
    let name: String?
    let category: Category?
    let color: Color?
    let imageUrl: String?
}
