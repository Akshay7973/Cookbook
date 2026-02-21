//
//  RecipeDetailView.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                heroImage

                VStack(alignment: .leading, spacing: 20) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.name)
                            .font(.title.bold()).foregroundStyle(Color(hex: "#011993"))
                        Text(recipe.description)
                            .font(.body).foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Stats bar
                    HStack(spacing: 0) {
                        statBadge(value: "\(recipe.ingredients.count)", label: "Ingredients", icon: "leaf.fill")
                        Divider().frame(height: 36)
                        statBadge(value: "\(recipe.instructions.count)", label: "Steps", icon: "list.number")
                        if let v = recipe.videoURL, !v.isEmpty {
                            Divider().frame(height: 36)
                            statBadge(value: "Video", label: "Available", icon: "play.fill")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#011993").opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Ingredients
                    sectionCard(title: "Ingredients", icon: "leaf.fill") {
                        VStack(spacing: 10) {
                            ForEach(recipe.ingredients) { item in
                                HStack {
                                    Circle().fill(Color(hex: "#011993").opacity(0.15))
                                        .frame(width: 8, height: 8)
                                    Text(item.name).font(.subheadline.weight(.medium))
                                    Spacer()
                                    Text("\(item.quantity, specifier: "%.1f") \(item.unit)")
                                        .font(.subheadline).foregroundStyle(.secondary)
                                        .padding(.horizontal, 10).padding(.vertical, 4)
                                        .background(Color(.systemGray6)).clipShape(Capsule())
                                }
                            }
                        }
                    }

                    // Instructions
                    sectionCard(title: "Instructions", icon: "list.number") {
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 14) {
                                    Text("\(index + 1)")
                                        .font(.callout.bold()).foregroundStyle(.white)
                                        .frame(width: 30, height: 30)
                                        .background(Color(hex: "#011993")).clipShape(Circle())
                                    Text(step).font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                if index < recipe.instructions.count - 1 {
                                    Divider().padding(.leading, 44)
                                }
                            }
                        }
                    }

                    // Video button
                    if let videoURL = recipe.videoURL, !videoURL.isEmpty, let url = URL(string: videoURL) {
                        Link(destination: url) {
                            HStack {
                                Image(systemName: "play.circle.fill").font(.title2)
                                Text("Watch Recipe Video").font(.headline)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .foregroundStyle(.white)
                            .padding(16)
                            .background(Color(hex: "#011993"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
    }

    @ViewBuilder
    private var heroImage: some View {
        if let imageURL = recipe.imageURL, !imageURL.isEmpty, let url = URL(string: imageURL) {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: { placeholderHero }
            .frame(maxWidth: .infinity).frame(height: 260).clipped()
        } else {
            placeholderHero.frame(maxWidth: .infinity).frame(height: 160)
        }
    }

    private var placeholderHero: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#011993"), Color(hex: "#011993").opacity(0.5)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            Image(systemName: "fork.knife").font(.system(size: 56)).foregroundStyle(.white.opacity(0.3))
        }
    }

    private func statBadge(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.subheadline).foregroundStyle(Color(hex: "#011993"))
            Text(value).font(.headline)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func sectionCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundStyle(Color(hex: "#011993"))
                Text(title).font(.headline)
            }
            content()
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

//#Preview {
//    RecipeDetailView()
//}
