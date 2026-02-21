//
//  CookView.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import SwiftUI

struct CookView: View {

    @State private var viewModel = CookViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        ProgressView().scaleEffect(1.4).tint(Color(hex: "#011993"))
                        Text("Loading...").font(.subheadline).foregroundStyle(.secondary)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {

                            // Banner
                            HStack(spacing: 12) {
                                Image(systemName: "flame.fill")
                                    .font(.title2).foregroundStyle(Color(hex: "#011993"))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("What can I cook?").font(.headline)
                                    Text("Select the ingredients you have available")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(14)
                            .background(Color(hex: "#011993").opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal)

                            // Ingredients
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Your Ingredients").font(.headline)
                                    Spacer()
                                    if !viewModel.selectedIngredientIDs.isEmpty {
                                        Button("Clear All") {
                                            viewModel.selectedIngredientIDs.removeAll()
                                        }
                                        .font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.horizontal)

                                LazyVStack(spacing: 8) {
                                    ForEach(viewModel.allIngredients) { ingredient in
                                        HStack(spacing: 14) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(
                                                        viewModel.isSelected(ingredient) ? Color(hex: "#011993") : Color(.systemGray4),
                                                        lineWidth: viewModel.isSelected(ingredient) ? 2 : 1
                                                    )
                                                    .frame(width: 26, height: 26)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .fill(viewModel.isSelected(ingredient) ? Color(hex: "#011993") : Color.clear)
                                                    )
                                                if viewModel.isSelected(ingredient) {
                                                    Image(systemName: "checkmark")
                                                        .font(.caption.bold()).foregroundStyle(.white)
                                                }
                                            }
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(ingredient.name).font(.subheadline.weight(.medium))
                                                Text(ingredient.measurementUnit).font(.caption).foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                        }
                                        .padding(12)
                                        .background(
                                            viewModel.isSelected(ingredient)
                                            ? Color(hex: "#011993").opacity(0.06)
                                            : Color(.secondarySystemGroupedBackground)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(viewModel.isSelected(ingredient) ? Color(hex: "#011993").opacity(0.3) : Color.clear, lineWidth: 1)
                                        )
                                        .animation(.easeInOut(duration: 0.15), value: viewModel.isSelected(ingredient))
                                        .contentShape(Rectangle())
                                        .onTapGesture { viewModel.toggleIngredient(ingredient) }
                                    }
                                }
                                .padding(.horizontal)
                            }

                            // Matching Recipes
                            if !viewModel.selectedIngredientIDs.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text("Recipes You Can Make").font(.headline)
                                        Spacer()
                                        Text("\(viewModel.matchingRecipes.count)")
                                            .font(.caption.bold()).foregroundStyle(.white)
                                            .padding(.horizontal, 10).padding(.vertical, 4)
                                            .background(Color(hex: "#011993")).clipShape(Capsule())
                                    }
                                    .padding(.horizontal)

                                    if viewModel.matchingRecipes.isEmpty {
                                        VStack(spacing: 10) {
                                            Image(systemName: "magnifyingglass")
                                                .font(.largeTitle).foregroundStyle(Color(hex: "#011993").opacity(0.3))
                                            Text("No matching recipes").font(.subheadline).foregroundStyle(.secondary)
                                            Text("Try selecting more ingredients").font(.caption).foregroundStyle(.tertiary)
                                        }
                                        .frame(maxWidth: .infinity).padding(.vertical, 30)
                                    } else {
                                        LazyVStack(spacing: 10) {
                                            ForEach(viewModel.matchingRecipes) { recipe in
                                                NavigationLink(value: recipe) {
                                                    HStack(spacing: 14) {
                                                        ZStack {
                                                            Color(hex: "#011993").opacity(0.1)
                                                            Image(systemName: "fork.knife").foregroundStyle(Color(hex: "#011993"))
                                                        }
                                                        .frame(width: 52, height: 52)
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))

                                                        VStack(alignment: .leading, spacing: 4) {
                                                            Text(recipe.name).font(.headline).foregroundStyle(.primary)
                                                            Text(recipe.description).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                                                            Label("\(recipe.ingredients.count) ingredients", systemImage: "leaf.fill")
                                                                .font(.caption2).foregroundStyle(Color(hex: "#011993"))
                                                        }
                                                        Spacer()
                                                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                                                    }
                                                    .padding(14)
                                                    .background(Color(.secondarySystemGroupedBackground))
                                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Cook")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task { await viewModel.loadData() }
            .onAppear { Task { await viewModel.loadData() } }
        }
    }
}

#Preview {
    CookView()
}
