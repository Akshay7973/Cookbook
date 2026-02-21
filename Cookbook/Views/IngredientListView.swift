//
//  IngredientListView.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import SwiftUI

struct IngredientListView: View {

    @State private var viewModel = IngredientListViewModel()
    @State private var showingAdd = false
    @State private var ingredientToEdit: Ingredient?
    @State private var ingredientToDelete: Ingredient?
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        ProgressView().scaleEffect(1.4).tint(Color(hex: "#011993"))
                        Text("Loading Ingredients...").font(.subheadline).foregroundStyle(.secondary)
                    }
                } else if viewModel.filteredIngredients.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color(hex: "#011993").opacity(0.3))
                        Text("No Ingredients Yet").font(.title2.bold())
                        Text("Tap + to add your first ingredient")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Button {
                            showingAdd = true
                        } label: {
                            Label("Add Ingredient", systemImage: "plus")
                                .font(.headline).foregroundStyle(.white)
                                .padding(.horizontal, 24).padding(.vertical, 12)
                                .background(Color(hex: "#011993")).clipShape(Capsule())
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.filteredIngredients) { ingredient in
                                IngredientCardView(
                                    ingredient: ingredient,
                                    onEdit: { ingredientToEdit = ingredient },
                                    onDelete: {
                                        ingredientToDelete = ingredient
                                        showDeleteAlert = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal).padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Ingredients")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search ingredients...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2).foregroundStyle(Color(hex: "#011993"))
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditIngredientView(ingredient: nil) {
                    Task { await viewModel.loadIngredients() }
                }
            }
            .sheet(item: $ingredientToEdit) { ingredient in
                AddEditIngredientView(ingredient: ingredient) {
                    Task { await viewModel.loadIngredients() }
                }
            }
            .alert("Delete Ingredient", isPresented: $showDeleteAlert, presenting: ingredientToDelete) { ingredient in
                Button("Delete", role: .destructive) {
                    Task { await viewModel.deleteIngredient(ingredient) }
                }
                Button("Cancel", role: .cancel) {}
            } message: { ingredient in
                Text("Delete \"\(ingredient.name)\"? This cannot be undone.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task { await viewModel.loadIngredients() }
            .onAppear { Task { await viewModel.loadIngredients() } }
        }
    }
}

// MARK: - Ingredient Card

struct IngredientCardView: View {
    let ingredient: Ingredient
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {

            // Icon / Image
            Group {
                if let imageURL = ingredient.imageURL,
                   !imageURL.isEmpty,
                   let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: { ingredientIcon }
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ingredientIcon
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.name).font(.headline).foregroundStyle(.primary)
                Label(ingredient.measurementUnit, systemImage: "scalemass")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

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
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    private var ingredientIcon: some View {
        ZStack {
            Color(hex: "#011993").opacity(0.1)
            Image(systemName: "leaf.fill").font(.title3)
                .foregroundStyle(Color(hex: "#011993").opacity(0.6))
        }
    }
}

#Preview {
    IngredientListView()
}
