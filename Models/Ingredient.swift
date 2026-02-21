//
//  Ingredient.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import Foundation
import FirebaseFirestore

struct Ingredient: Identifiable, Codable, Hashable, Sendable {
    @DocumentID var id: String?
    var name: String
    var measurementUnit: String
    var imageURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case measurementUnit = "measurement_unit"
        case imageURL        = "image_url"
    }
}

struct RecipeIngredient: Codable, Hashable, Identifiable, Sendable {
    var id: String
    var name: String
    var quantity: Double
    var unit: String
}
