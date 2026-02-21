//
//  Recipe.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//


import Foundation
import FirebaseFirestore

struct Recipe: Identifiable, Codable, Hashable, Sendable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var ingredients: [RecipeIngredient]
    var instructions: [String]
    var imageURL: String?
    var videoURL: String?
    var createdAt: Date?                   // ← Now optional, won't crash

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case ingredients
        case instructions
        case imageURL = "image_url"
        case videoURL = "video_url"
        case createdAt = "created_at"
    }
    
    func canBeMade(with ingredientIDs: Set<String>) -> Bool {
         let recipeIngredientIDs = Set(ingredients.map(\.id))
         return recipeIngredientIDs.isSubset(of: ingredientIDs)
     }
}
