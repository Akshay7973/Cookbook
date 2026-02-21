//
//  MainTabView.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            RecipeListView()
                .tabItem {
                    Label("Recipes", systemImage: "book.closed")
                }

            IngredientListView()
                .tabItem {
                    Label("Ingredients", systemImage: "leaf")
                }

            CookView()
                .tabItem {
                    Label("Cook", systemImage: "flame")
                }
        }
        .tint(Color(hex: "#011993"))
    }
}
//
//#Preview {
//    MainTabView()
//}
