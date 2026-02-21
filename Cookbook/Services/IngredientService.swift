//
//  IngredientService.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import Foundation

/// Domain-specific service for Ingredient operations
import Foundation

final class IngredientService: Sendable {

    private let firestore = FirestoreService()
    private let collection = "ingredients"

    func fetchIngredients() async throws -> [Ingredient] {
        try await firestore.fetchAll(from: collection)
    }

    func addIngredient(_ ingredient: Ingredient) async throws {
        try await firestore.save(ingredient, to: collection)
    }

    func updateIngredient(_ ingredient: Ingredient) async throws {
        guard let id = ingredient.id else { return }
        try await firestore.save(ingredient, to: collection, id: id)
    }

    func deleteIngredient(id: String) async throws {
        try await firestore.delete(from: collection, id: id)
    }
}

