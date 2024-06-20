//
//  FCollectionReference.swift
//  TodoList
//
//  Created by KhoaLA8 on 17/6/24.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Task
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
