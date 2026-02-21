//
//  RecipeListViewModel.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class RecipeListViewModel {

    var recipes: [Recipe] = []
    var searchText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    private let service = RecipeService()

    var filteredRecipes: [Recipe] {
        guard !searchText.isEmpty else { return recipes }
        return recipes.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    func loadRecipes() async {
        isLoading = true
        defer { isLoading = false }
        do {
            recipes = try await service.fetchRecipes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteRecipe(_ recipe: Recipe) async {
        guard let id = recipe.id else { return }
        do {
            try await service.deleteRecipe(id: id)
            await loadRecipes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
