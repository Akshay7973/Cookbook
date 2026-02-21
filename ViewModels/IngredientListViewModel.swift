//
//  IngredientListViewModel.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class IngredientListViewModel {

    var ingredients: [Ingredient] = []
    var searchText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    private let service = IngredientService()

    var filteredIngredients: [Ingredient] {
        guard !searchText.isEmpty else { return ingredients }
        return ingredients.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    func loadIngredients() async {
        isLoading = true
        defer { isLoading = false }
        do {
            ingredients = try await service.fetchIngredients()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteIngredient(_ ingredient: Ingredient) async {
        guard let id = ingredient.id else { return }
        do {
            try await service.deleteIngredient(id: id)
            await loadIngredients()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
