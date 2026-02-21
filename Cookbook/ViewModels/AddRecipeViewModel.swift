//
//  AddRecipeViewModel.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import Foundation
import Observation

/// ViewModel for adding a new Recipe
@MainActor
@Observable
final class AddRecipeViewModel {

    // MARK: - Form State
    var name: String = ""
    var description: String = ""
    var instructions: String = ""       // Newline-separated steps
    var selectedIngredients: [RecipeIngredient] = []
    var imageURL: String = ""
    var videoURL: String = ""
    var isSaving: Bool = false
    var errorMessage: String?

    // MARK: - Dependencies
    private let service = RecipeService()

    // MARK: - Validation
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        !instructions.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Intent

    func save() async -> Bool {
        guard isValid else { return false }
        isSaving = true
        defer { isSaving = false }

        let steps = instructions
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let recipe = Recipe(
            name: name,
            description: description,
            ingredients: selectedIngredients,
            instructions: steps,
            imageURL: imageURL.isEmpty ? nil : imageURL,
            videoURL: videoURL.isEmpty ? nil : videoURL,
            createdAt: Date()                      // ← still pass Date(), just now optional type
        )
        do {
            try await service.addRecipe(recipe)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
