//
//  UserManager.swift
//  IA3V2
//
//  Created by James Nunn on 30/5/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

struct DBUser: Codable, Identifiable, Hashable {
    var id:String
    let name:String?
    let email:String?
    let dateCreated:Date?
    var isStaff:Bool?
    
    init(auth:AuthDataResultModel){
        self.id = auth.uid
        self.name = nil
        self.email = auth.email
        self.dateCreated = Date()
        self.isStaff = false
    }
    
    init(
        userID:String,
        name:String? = nil,
        email:String? = nil,
        dateCreated:Date? = nil,
        isStaff:Bool? = nil
    ){
        self.id = userID
        self.name = name
        self.email = email
        self.dateCreated = dateCreated
        self.isStaff = isStaff
    }
    
    mutating func toggleStaffStatus() {
        let currentValue = isStaff ?? false
        isStaff = !currentValue
    }
}

final class UserManager{
    static let shared = UserManager()
    
    private init(){}
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userID:String) -> DocumentReference {
        userCollection.document(userID)
    }
    
    func createNewUser(user:DBUser) async throws{
        try userDocument(userID: user.id).setData(from: user, merge: false)
    }
    
    func getUser(userID:String) async throws -> DBUser {
        try await userDocument(userID: userID).getDocument(as: DBUser.self)
    }
    
    func updateUser(user:DBUser) async throws{
        try userDocument(userID: user.id).setData(from: user, merge: true)
    }
    
}
//MARK: User Repository
class UserRepository: ObservableObject {
    private let path: String = "users"
    private let store = Firestore.firestore()
    @Published var users: [DBUser] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.get()
    }
    
    func get() {
        store.collection(path)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error getting users: \(String(describing: error))")
                    return
                }
                self.users = documents.compactMap { document -> DBUser? in
                    print(document.data())
                    return try? document.data(as: DBUser.self)
                }
            }
    }
}
