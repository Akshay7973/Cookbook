//
//  CookViewModel.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import Foundation
import Observation

/// ViewModel for the Cook screen — find recipes by selected ingredients
@MainActor
@Observable
final class CookViewModel {

    var allIngredients: [Ingredient] = []
    var allRecipes: [Recipe] = []
    var selectedIngredientIDs: Set<String> = []
    var isLoading: Bool = false
    var errorMessage: String?

    private let ingredientService = IngredientService()
    private let recipeService = RecipeService()

    /// Recipes that can be made with selected ingredients
    var matchingRecipes: [Recipe] {
        guard !selectedIngredientIDs.isEmpty else { return [] }
        return allRecipes.filter { $0.canBeMade(with: selectedIngredientIDs) }
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        async let ingredients = ingredientService.fetchIngredients()
        async let recipes = recipeService.fetchRecipes()
        do {
            (allIngredients, allRecipes) = try await (ingredients, recipes)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleIngredient(_ ingredient: Ingredient) {
        guard let id = ingredient.id else { return }
        if selectedIngredientIDs.contains(id) {
            selectedIngredientIDs.remove(id)
        } else {
            selectedIngredientIDs.insert(id)
        }
    }

    func isSelected(_ ingredient: Ingredient) -> Bool {
        guard let id = ingredient.id else { return false }
        return selectedIngredientIDs.contains(id)
    }
}
