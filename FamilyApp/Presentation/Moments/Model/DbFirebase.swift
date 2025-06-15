//
//  DbFirebase.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/15.
//

import Foundation
import FirebaseFirestore
// 따로 import Database 필요 없음 (같은 모듈이면 자동 인식)

class DbFirebase: Database {

    private var reference: CollectionReference
    private var existQuery: ListenerRegistration?
    var parentNotification: (([String: Any]?, DbAction?) -> Void)?
    
    required init(parentNotification: (([String : Any]?, DbAction?) -> Void)?) {
        self.parentNotification = parentNotification
        self.reference = Firestore.firestore().collection("moments")
    }

    func setQuery(from: Any, to: Any) {
        if let existQuery = existQuery {
            existQuery.remove()
        }
        let query = reference
            .whereField("id", isGreaterThanOrEqualTo: from)
            .whereField("id", isLessThanOrEqualTo: to)

        existQuery = query.addSnapshotListener(onChangingData)
    }

    func saveChange(key: String, object: [String: Any], action: DbAction) {
        switch action {
        case .delete:
            reference.document(key).delete()
        case .add, .modify:
            reference.document(key).setData(object)
        }
    }

    private func onChangingData(querySnapshot: QuerySnapshot?, error: Error?) {
        guard let querySnapshot = querySnapshot else { return }

        for documentChange in querySnapshot.documentChanges {
            let dict = documentChange.document.data()
            var action: DbAction?

            switch documentChange.type {
            case .added: action = .add
            case .modified: action = .modify
            case .removed: action = .delete
            @unknown default: break
            }

            parentNotification?(dict, action)
        }
    }
}
