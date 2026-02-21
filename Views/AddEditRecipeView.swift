//
//  AddEditRecipeView.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import SwiftUI

// MARK: - AddEditRecipeView

struct AddEditRecipeView: View {

    let recipe: Recipe?
    let onSaved: () -> Void

    @State private var viewModel: AddEditRecipeViewModel
    @State private var showIngredientPicker = false
    @State private var allIngredients: [Ingredient] = []
    @State private var isLoadingIngredients = false
    @Environment(\.dismiss) private var dismiss

    init(recipe: Recipe?, onSaved: @escaping () -> Void) {
        self.recipe = recipe
        self.onSaved = onSaved
        _viewModel = State(initialValue: AddEditRecipeViewModel(recipe: recipe))
    }

    var isEditMode: Bool { recipe != nil }

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Basic Info
                Section {
                    TextField("Recipe Name", text: $viewModel.name)
                        .font(.headline)
                    TextField("Description", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Label("Basic Info", systemImage: "info.circle")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "#011993"))
                        .textCase(nil)
                }

                // MARK: Instructions
                Section {
                    TextField(
                        "Enter each step on a new line...",
                        text: $viewModel.instructions,
                        axis: .vertical
                    )
                    .lineLimit(5...15)
                    .font(.subheadline)
                } header: {
                    Label("Instructions", systemImage: "list.number")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "#011993"))
                        .textCase(nil)
                } footer: {
                    Text("Each new line becomes a separate step")
                        .font(.caption)
                }

                // MARK: Ingredients
                Section {
                    if viewModel.selectedIngredients.isEmpty {
                        Text("No ingredients added yet")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(viewModel.selectedIngredients) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.subheadline.weight(.medium))
                                    Text("\(item.quantity, specifier: "%.1f") \(item.unit)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button {
                                    viewModel.selectedIngredients.removeAll { $0.id == item.id }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red.opacity(0.8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Add Ingredient button
                    Button {
                        if !allIngredients.isEmpty {
                            showIngredientPicker = true
                        }
                    } label: {
                        HStack {
                            if isLoadingIngredients {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(Color(hex: "#011993"))
                                Text("Loading ingredients...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } else {
                                Label("Add Ingredient", systemImage: "plus.circle.fill")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(
                                        allIngredients.isEmpty
                                        ? Color(.systemGray3)
                                        : Color(hex: "#011993")
                                    )
                            }
                        }
                    }
                    .disabled(allIngredients.isEmpty || isLoadingIngredients)

                } header: {
                    Label("Ingredients", systemImage: "leaf")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "#011993"))
                        .textCase(nil)
                } footer: {
                    if allIngredients.isEmpty && !isLoadingIngredients {
                        Text("⚠️ No ingredients found. Add ingredients in the Ingredients tab first.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                // MARK: Media
                Section {
                    HStack {
                        Image(systemName: "photo")
                            .foregroundStyle(Color(hex: "#011993"))
                            .frame(width: 28)
                        TextField("Image URL (optional)", text: $viewModel.imageURL)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    HStack {
                        Image(systemName: "play.rectangle")
                            .foregroundStyle(Color(hex: "#011993"))
                            .frame(width: 28)
                        TextField("Video URL (optional)", text: $viewModel.videoURL)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                } header: {
                    Label("Media", systemImage: "photo.on.rectangle")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "#011993"))
                        .textCase(nil)
                }
            }
            .navigationTitle(isEditMode ? "Edit Recipe" : "New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView().tint(Color(hex: "#011993"))
                    } else {
                        Button(isEditMode ? "Update" : "Save") {
                            Task {
                                let saved = await viewModel.save()
                                if saved { onSaved(); dismiss() }
                            }
                        }
                        .disabled(!viewModel.isValid)
                        .fontWeight(.semibold)
                        .foregroundStyle(viewModel.isValid ? Color(hex: "#011993") : .secondary)
                    }
                }
            }
            // Ingredient picker sheet
            .sheet(isPresented: $showIngredientPicker) {
                IngredientPickerSheet(
                    ingredients: allIngredients
                ) { ingredient, quantity in
                    let item = RecipeIngredient(
                        id: ingredient.id ?? UUID().uuidString,
                        name: ingredient.name,
                        quantity: quantity,
                        unit: ingredient.measurementUnit
                    )
                    if !viewModel.selectedIngredients.contains(where: { $0.id == item.id }) {
                        viewModel.selectedIngredients.append(item)
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            // Load ingredients on appear
            .task {
                await loadIngredients()
            }
        }
    }

    // MARK: - Load Ingredients

    private func loadIngredients() async {
        isLoadingIngredients = true
        do {
            let service = IngredientService()
            allIngredients = try await service.fetchIngredients()
            print("✅ Loaded \(allIngredients.count) ingredients")
        } catch {
            print("❌ Failed to load ingredients: \(error)")
            allIngredients = []
        }
        isLoadingIngredients = false
    }
}

// MARK: - Ingredient Picker Sheet

struct IngredientPickerSheet: View {
    let ingredients: [Ingredient]
    let onPick: (Ingredient, Double) -> Void

    @State private var selectedIngredient: Ingredient?
    @State private var quantityText: String = ""
    @Environment(\.dismiss) private var dismiss

    private var canAdd: Bool {
        selectedIngredient != nil &&
        !quantityText.isEmpty &&
        Double(quantityText) != nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: Full ingredient list — tap to select
                List {
                    Section {
                        ForEach(ingredients) { ingredient in
                            HStack(spacing: 12) {

                                // Icon
                                ZStack {
                                    Color(hex: "#011993").opacity(0.1)
                                    Image(systemName: "leaf.fill")
                                        .font(.caption)
                                        .foregroundStyle(Color(hex: "#011993").opacity(0.8))
                                }
                                .frame(width: 32, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                                // Name
                                Text(ingredient.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)

                                Spacer()

                                // Unit badge
                                Text(ingredient.measurementUnit)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(
                                        selectedIngredient?.id == ingredient.id
                                        ? Color(hex: "#011993")
                                        : .secondary
                                    )
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        selectedIngredient?.id == ingredient.id
                                        ? Color(hex: "#011993").opacity(0.12)
                                        : Color(.systemGray6)
                                    )
                                    .clipShape(Capsule())

                                // Checkmark
                                Image(
                                    systemName: selectedIngredient?.id == ingredient.id
                                    ? "checkmark.circle.fill"
                                    : "circle"
                                )
                                .font(.title3)
                                .foregroundStyle(
                                    selectedIngredient?.id == ingredient.id
                                    ? Color(hex: "#011993")
                                    : Color(.systemGray4)
                                )
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedIngredient = ingredient
                                    quantityText = ""
                                }
                            }
                            .listRowBackground(
                                selectedIngredient?.id == ingredient.id
                                ? Color(hex: "#011993").opacity(0.06)
                                : Color(.secondarySystemGroupedBackground)
                            )
                        }
                    } header: {
                        Text("Available Ingredients (\(ingredients.count))")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(hex: "#011993"))
                    }
                }
                .listStyle(.insetGrouped)

                // MARK: Quantity input — appears after selecting
                VStack(spacing: 0) {
                    Divider()

                    VStack(spacing: 12) {
                        // Selected summary
                        if let selected = selectedIngredient {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Selected")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(selected.name)
                                        .font(.headline)
                                        .foregroundStyle(Color(hex: "#011993"))
                                }
                                Spacer()
                                Text(selected.measurementUnit)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "#011993"))
                                    .clipShape(Capsule())
                            }
                        } else {
                            Text("Tap an ingredient above to select it")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Quantity row
                        HStack(spacing: 10) {
                            TextField(
                                selectedIngredient == nil ? "Select ingredient first" : "Enter quantity",
                                text: $quantityText
                            )
                            .keyboardType(.decimalPad)
                            .disabled(selectedIngredient == nil)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            if let selected = selectedIngredient {
                                Text(selected.measurementUnit)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "#011993"))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            Button {
                                if let ing = selectedIngredient, let qty = Double(quantityText) {
                                    onPick(ing, qty)
                                    dismiss()
                                }
                            } label: {
                                Text("Add")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(canAdd ? Color(hex: "#011993") : Color(.systemGray4))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .disabled(!canAdd)
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
    }
}
//#Preview {
//    AddEditRecipeView()
//}
