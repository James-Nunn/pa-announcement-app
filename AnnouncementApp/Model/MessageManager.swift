//
//  MessageManager.swift
//  IA3V2
//
//  Created by James Nunn on 30/5/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var isImportant: Bool
    var text: String
    var recipient: [String]
    var sender: String
    var dateSent: Date?
}

class MessageRepository: ObservableObject {
    private let path: String = "messages"
    private let store = Firestore.firestore()
    var userId = try? AuthenticationManager.shared.getAuthenticatedUser().uid
    
    @Published var messages: [Message] = []
    @Published var sentMessages: [Message] = []
    
    init() {
        get()
        getSent()
    }
    
    func get(){
        store.collection(path)
            .whereField("recipient", arrayContains: userId ?? "")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error getting messages: \(String(describing: error))")
                    return
                }
                
                self.messages = documents.compactMap { document -> Message? in
                    do {
                        return try document.data(as: Message.self)
                    } catch {
                        print(error)
                        return nil
                    }
                }
                self.messages.sort { $0.dateSent ?? Date.distantPast > $1.dateSent ?? Date.distantPast}
                Notify.send(message: "\(self.messages[0].text)", isImportant: self.messages[0].isImportant)
            }
    }
    func getSent(){
        store.collection(path)
            .whereField("sender", isEqualTo: userId ?? "")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error getting messages: \(String(describing: error))")
                    return
                }
                self.sentMessages = documents.compactMap { document -> Message? in
                    do {
                        return try document.data(as: Message.self)
                    } catch {
                        print(error)
                        return nil
                    }
                }
                self.sentMessages.sort { $0.dateSent ?? Date.distantPast > $1.dateSent ?? Date.distantPast }
            }
    }
    
    func add(_ message: Message) {
        do {
            try store.collection(path).document().setData(from: message)
        } catch {
            fatalError("Unable to add message: \(error.localizedDescription).")
        }
    }
    
    func remove(_ message: Message) {
        guard let messageID = message.id else { return }
        
        store.collection(path).document(messageID).delete { error in
            if let error = error {
                print("Unable to remove message: \(error.localizedDescription)")
            }
        }
    }
}
