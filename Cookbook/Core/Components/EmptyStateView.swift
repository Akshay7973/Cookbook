//
//  EmptyStateView.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import Foundation
import SwiftUI

/// Reusable empty state placeholder
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(subtitle)
        }
    }
}
