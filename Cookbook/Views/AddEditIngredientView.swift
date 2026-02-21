//
//  AddEditIngredientView.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import SwiftUI

struct AddEditIngredientView: View {

    let ingredient: Ingredient?
    let onSaved: () -> Void

    @State private var name: String
    @State private var unit: String
    @State private var imageURL: String
    @State private var isSaving = false
    @State private var errorMessage: String?

    @Environment(\.dismiss) private var dismiss
    private let service = IngredientService()
    private var isEditMode: Bool { ingredient != nil }

    private let commonUnits = ["grams", "kg", "ml", "liters", "cups", "tbsp", "tsp", "pcs", "cloves", "pinch"]

    init(ingredient: Ingredient?, onSaved: @escaping () -> Void) {
        self.ingredient = ingredient
        self.onSaved = onSaved
        _name = State(initialValue: ingredient?.name ?? "")
        _unit = State(initialValue: ingredient?.measurementUnit ?? "")
        _imageURL = State(initialValue: ingredient?.imageURL ?? "")
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !unit.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Ingredient Name", text: $name).font(.headline)
                } header: {
                    Label("Name", systemImage: "tag")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "#011993")).textCase(nil)
                }

                Section {
                    TextField("e.g. grams, ml, cups, pcs", text: $unit)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(commonUnits, id: \.self) { suggestion in
                                Button {
                                    unit = suggestion
                                } label: {
                                    Text(suggestion)
                                        .font(.caption.weight(.medium))
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(unit == suggestion ? Color(hex: "#011993") : Color(.systemGray5))
                                        .foregroundStyle(unit == suggestion ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                } header: {
                    Label("Measurement Unit", systemImage: "scalemass")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "#011993")).textCase(nil)
                } footer: {
                    Text("Tap a suggestion or type your own").font(.caption)
                }

                Section {
                    HStack {
                        Image(systemName: "photo").foregroundStyle(Color(hex: "#011993"))
                        TextField("Paste image URL (optional)", text: $imageURL)
                            .keyboardType(.URL).autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    if !imageURL.isEmpty, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFit()
                                .frame(maxHeight: 140)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } placeholder: {
                            HStack {
                                ProgressView()
                                Text("Loading preview...").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Label("Image", systemImage: "photo.on.rectangle")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(hex: "#011993")).textCase(nil)
                }
            }
            .navigationTitle(isEditMode ? "Edit Ingredient" : "New Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView().tint(Color(hex: "#011993"))
                    } else {
                        Button(isEditMode ? "Update" : "Save") {
                            Task { await save() }
                        }
                        .disabled(!isValid).fontWeight(.semibold)
                        .foregroundStyle(isValid ? Color(hex: "#011993") : .secondary)
                    }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        do {
            if isEditMode, let existing = ingredient {
                var updated = existing
                updated.name = name
                updated.measurementUnit = unit
                updated.imageURL = imageURL.isEmpty ? nil : imageURL
                try await service.updateIngredient(updated)
            } else {
                let newIngredient = Ingredient(
                    name: name,
                    measurementUnit: unit,
                    imageURL: imageURL.isEmpty ? nil : imageURL
                )
                try await service.addIngredient(newIngredient)
            }
            onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

//#Preview {
//    AddEditIngredientView()
//}
