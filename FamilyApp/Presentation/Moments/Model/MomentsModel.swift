//
//  MomentsModel.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/15.
//

import Foundation
import FirebaseFirestore

struct MomentsModel {
    let id: String           // 문서 ID (선택사항)
    let imageURL: String
    let content: String
    let timestamp: Date
    let userId: String
    let userName: String
    let familyId: String     // 소속 가족 ID
    let role: String  // ✅ 추가

    init(id: String = UUID().uuidString,
         imageURL: String,
         content: String,
         timestamp: Date,
         userId: String,
         userName: String,
         familyId: String,
         role: String ) {
        self.id = id
        self.imageURL = imageURL
        self.content = content
        self.timestamp = timestamp
        self.userId = userId
        self.userName = userName
        self.familyId = familyId
        self.role = role
        
    }

    static func from(dict: [String: Any], id: String = UUID().uuidString) -> MomentsModel? {
        guard
            let imageURL = dict["imageURL"] as? String,
            let content = dict["content"] as? String,
            let timestamp = dict["timestamp"] as? Timestamp,
            let userId = dict["userId"] as? String,
            let userName = dict["userName"] as? String,
            let familyId = dict["familyId"] as? String,
                let role = dict["role"] as? String
        else {
            return nil
        }

        return MomentsModel(
            id: id,
            imageURL: imageURL,
            content: content,
            timestamp: timestamp.dateValue(),
            userId: userId,
            userName: userName,
            familyId: familyId,
            role: role
        )
    }

    func toDictionary() -> [String: Any] {
        return [
            "imageURL": imageURL,
            "content": content,
            "timestamp": Timestamp(date: timestamp),
            "userId": userId,
            "userName": userName,
            "familyId": familyId,
            "role": role
        ]
    }
}
