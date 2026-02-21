//
//  RecipeService.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import Foundation

/// Domain-specific service for Recipe operations
 actor RecipeService {

    private let firestore = FirestoreService()
    private let collection = "recipes"

     @MainActor func fetchRecipes() async throws -> [Recipe] {
        try await firestore.fetchAll(from: collection)
    }

     @MainActor func addRecipe(_ recipe: Recipe) async throws {
        try await firestore.save(recipe, to: collection)
    }

    func deleteRecipe(id: String) async throws {
        try await firestore.delete(from: collection, id: id)
    }

     @MainActor func updateRecipe(_ recipe: Recipe) async throws {
        let id = recipe.id
        guard let id else { return }
        try await firestore.save(recipe, to: collection, id: id)
    }
}

