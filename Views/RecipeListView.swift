//
//  RecipeListView.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import SwiftUI

struct RecipeListView: View {

    @State private var viewModel = RecipeListViewModel()
    @State private var showingAddRecipe = false
    @State private var recipeToEdit: Recipe?
    @State private var recipeToDelete: Recipe?
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        ProgressView().scaleEffect(1.4).tint(Color(hex: "#011993"))
                        Text("Loading Recipes...").font(.subheadline).foregroundStyle(.secondary)
                    }
                } else if viewModel.filteredRecipes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color(hex: "#011993").opacity(0.3))
                        Text("No Recipes Yet").font(.title2.bold())
                        Text("Tap + to add your first recipe")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Button {
                            showingAddRecipe = true
                        } label: {
                            Label("Add Recipe", systemImage: "plus")
                                .font(.headline).foregroundStyle(.white)
                                .padding(.horizontal, 24).padding(.vertical, 12)
                                .background(Color(hex: "#011993")).clipShape(Capsule())
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredRecipes) { recipe in
                                NavigationLink(value: recipe) {
                                    RecipeCardView(
                                        recipe: recipe,
                                        onEdit: { recipeToEdit = recipe },
                                        onDelete: {
                                            recipeToDelete = recipe
                                            showDeleteAlert = true
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search recipes...")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddRecipe = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2).foregroundStyle(Color(hex: "#011993"))
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddEditRecipeView(recipe: nil) {
                    Task { await viewModel.loadRecipes() }
                }
            }
            .sheet(item: $recipeToEdit) { recipe in
                AddEditRecipeView(recipe: recipe) {
                    Task { await viewModel.loadRecipes() }
                }
            }
            .alert("Delete Recipe", isPresented: $showDeleteAlert, presenting: recipeToDelete) { recipe in
                Button("Delete", role: .destructive) {
                    Task { await viewModel.deleteRecipe(recipe) }
                }
                Button("Cancel", role: .cancel) {}
            } message: { recipe in
                Text("Delete \"\(recipe.name)\"? This cannot be undone.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task { await viewModel.loadRecipes() }
            .onAppear { Task { await viewModel.loadRecipes() } }
        }
    }
}

// MARK: - Recipe Card

struct RecipeCardView: View {
    let recipe: Recipe
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Image
            if let imageURL = recipe.imageURL, !imageURL.isEmpty, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: { placeholderImage }
                .frame(maxWidth: .infinity).frame(height: 130).clipped()
            } else {
                placeholderImage.frame(maxWidth: .infinity).frame(height: 80)
            }

            // Content row
            HStack(alignment: .top, spacing: 10) {

                // Info
                VStack(alignment: .leading, spacing: 5) {
                    Text(recipe.name).font(.headline).foregroundStyle(.primary)
                    Text(recipe.description)
                        .font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                    HStack(spacing: 12) {
                        Label("\(recipe.ingredients.count) ingredients", systemImage: "leaf.fill")
                            .font(.caption).foregroundStyle(Color(hex: "#011993"))
                        Label("\(recipe.instructions.count) steps", systemImage: "list.number")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Horizontal icon buttons
                HStack(spacing: 4) {
                    Button {
                        onEdit()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color(hex: "#011993"))
                            .frame(width: 36, height: 36)
                            .background(Color(hex: "#011993").opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)

                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.red)
                            .frame(width: 36, height: 36)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private var placeholderImage: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#011993").opacity(0.15), Color(hex: "#011993").opacity(0.05)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            Image(systemName: "fork.knife")
                .font(.system(size: 28))
                .foregroundStyle(Color(hex: "#011993").opacity(0.3))
        }
    }
}
#Preview {
    RecipeListView()
}
