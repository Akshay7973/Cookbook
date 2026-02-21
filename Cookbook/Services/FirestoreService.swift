//
//  FirestoreService.swift
//  Cookbook
//
//  Created by Akshay Gandal on 21/02/26.
//

import Foundation
import FirebaseFirestore

/// Generic Firestore CRUD service
/// All methods are async/throws and run off the main actor
actor FirestoreService {

    private let db = Firestore.firestore()

    // MARK: - Fetch All

    func fetchAll<T: Codable>(from collection: String) async throws -> [T] {
        let snapshot = try await db.collection(collection).getDocuments()
        return try snapshot.documents.compactMap { document in
            do {
                return try document.data(as: T.self)
            } catch {
                print("❌ Decode error for document \(document.documentID): \(error)")
                return nil
            }
        }
    }

    // MARK: - Fetch by ID

    func fetch<T: Codable>(from collection: String, id: String) async throws -> T {
        let doc = try await db.collection(collection).document(id).getDocument()
        return try doc.data(as: T.self)
    }

    // MARK: - Save (create/update)

    @discardableResult
    func save<T: Codable & Identifiable>(
        _ item: T,
        to collection: String,
        id: String? = nil
    ) async throws -> String {
        let docRef: DocumentReference
        if let existingID = id {
            docRef = db.collection(collection).document(existingID)
        } else {
            docRef = db.collection(collection).document()
        }
        try docRef.setData(from: item)
        return docRef.documentID
    }

    // MARK: - Delete

    func delete(from collection: String, id: String) async throws {
        try await db.collection(collection).document(id).delete()
    }

    // MARK: - Real-time listener

    func listen<T: Codable>(
        to collection: String,
        onChange: @escaping @Sendable ([T]) -> Void
    ) -> ListenerRegistration {
        db.collection(collection).addSnapshotListener { snapshot, error in
            guard let snapshot else { return }
            let items: [T] = snapshot.documents.compactMap {
                try? $0.data(as: T.self)
            }
            onChange(items)
        }
    }
}
