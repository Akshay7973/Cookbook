//
//  AddEditRecipeViewModel.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class AddEditRecipeViewModel {

    var name: String = ""
    var description: String = ""
    var instructions: String = ""
    var selectedIngredients: [RecipeIngredient] = []
    var imageURL: String = ""
    var videoURL: String = ""
    var isSaving: Bool = false
    var errorMessage: String?

    private let recipe: Recipe?
    private let service = RecipeService()

    init(recipe: Recipe?) {
        self.recipe = recipe
        if let recipe {
            name = recipe.name
            description = recipe.description
            instructions = recipe.instructions.joined(separator: "\n")
            selectedIngredients = recipe.ingredients
            imageURL = recipe.imageURL ?? ""
            videoURL = recipe.videoURL ?? ""
        }
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        !instructions.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func save() async -> Bool {
        guard isValid else { return false }
        isSaving = true
        defer { isSaving = false }

        let steps = instructions
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        do {
            if let existing = recipe {
                var updated = existing
                updated.name = name
                updated.description = description
                updated.ingredients = selectedIngredients
                updated.instructions = steps
                updated.imageURL = imageURL.isEmpty ? nil : imageURL
                updated.videoURL = videoURL.isEmpty ? nil : videoURL
                try await service.updateRecipe(updated)
            } else {
                let newRecipe = Recipe(
                    name: name,
                    description: description,
                    ingredients: selectedIngredients,
                    instructions: steps,
                    imageURL: imageURL.isEmpty ? nil : imageURL,
                    videoURL: videoURL.isEmpty ? nil : videoURL,
                    createdAt: Date()
                )
                try await service.addRecipe(newRecipe)
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
