//
//  MessagesListView.swift
//  IA3V2
//
//  Created by James Nunn on 30/5/2023.
//

import SwiftUI
import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class MessagesViewModel:ObservableObject{
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws{
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userID: authDataResult.uid)
    }
    
    func toggleStaffStatus(){
        guard var user else {return}
        user.toggleStaffStatus()
        Task{
            try await UserManager.shared.updateUser(user: user)
            self.user = try await UserManager.shared.getUser(userID: user.id)
        }
    }
}

struct MessagesView: View {
    @State var searchText = ""
    @ObservedObject var messagesViewModel:MessagesViewModel
    @EnvironmentObject var messageRepository: MessageRepository
    @Binding var showSignInView:Bool
    @State var deleteFromList = false
    @State var showSettings = false
    @State var showNewMessage = false
    @State var showSentMessages = false
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: DeletedMessages.entity(), sortDescriptors: [])
    var deletedMessages: FetchedResults<DeletedMessages>
    @FetchRequest(entity: Drafts.entity(), sortDescriptors: [])
    var drafts: FetchedResults<Drafts>
    @EnvironmentObject var userList:UserRepository
    
    var body: some View {
        NavigationView{
            VStack{
                HStack {
                    SearchBar(text: $searchText)
                        .padding(.top)
                }
                Spacer()
                List{
                    Section(header: Text("Your Announcements").foregroundColor(Color.schoolRedColor)){
                        if messageRepository.messages.isEmpty{
                            Text("You have No Announcements to View")
                        } else {
                            ForEach(messageRepository.messages){ messageViewModel in
                                if checkDeletedMessages(text: messageViewModel.id!) {
                                    NewMessageListItemView(
                                        messageViewModel: messageViewModel,
                                        deleteFromList: $deleteFromList, iconSize: 30, isSender: false).foregroundColor(Color.black)
                                }
                            }
                        }
                    }
                }.listStyle(.insetGrouped)
            }
            ZStack(alignment: .bottom){
                VStack{
                    List{
                        Section(header: Text("Latest Announcement").foregroundColor(Color.schoolRedColor).font(.largeTitle)){
                            if messageRepository.messages.isEmpty{
                                Text("You have No Announcements to View")
                            } else {
                                NewMessageListItemView(
                                    messageViewModel: messageRepository.messages[0],
                                    deleteFromList: $deleteFromList, iconSize: 30, isSender: false).foregroundColor(Color.black)
                                
                            }
                        }
                        if let user = messagesViewModel.user {
                            if user.isStaff ?? false {
                                Section{
                                    Picker("Priority", selection: $showSentMessages){
                                        HStack {
                                            Text("Sent Announcements ")
                                        }.tag(true)
                                        HStack {
                                            Text("Drafted Announcements")
                                        }.tag(false)
                                    }
                                    .pickerStyle(.segmented)
                                }
                                if showSentMessages{
                                    Section(header: Text("Sent Announcements").font(.largeTitle).foregroundColor(Color.schoolRedColor)){
                                        if messageRepository.sentMessages.isEmpty {
                                            Text("You Have No Sent Announcements")
                                        } else {
                                            ForEach(messageRepository.sentMessages){ messageViewModel in
                                                NewMessageListItemView(
                                                    messageViewModel: messageViewModel,
                                                    deleteFromList: $deleteFromList, isSender: true).foregroundColor(Color.black)
                                            }
                                        }
                                    }
                                } else {
                                    Section(header: Text("Drafted Announcements").font(.largeTitle).foregroundColor(Color.schoolRedColor)){
                                        if drafts.count != 0{
                                            ForEach(drafts){ draft in
                                                NavigationLink(destination: {CreateMessageView(
                                                    messagesViewModel: messagesViewModel, recipientIDs: draft.recipientsArray, isImportant: draft.isImportant, messageText: draft.text!, wasDraft: true, originalDraft: draft)}){
                                                        DraftListItemView(deleteFromList: $deleteFromList, draft: draft)
                                                    }
                                            }.onDelete(perform: deleteItems)
                                        } else {
                                            Text("You Have No Saved Drafts")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .toolbar{
                        if let user = messagesViewModel.user{
                            if user.isStaff ?? false {
                                ToolbarItem{
                                    NavigationLink(destination: CreateMessageView(messagesViewModel: messagesViewModel), label: {Label("New Message", systemImage: "envelope.arrow.triangle.branch")})
                                }
                            }
                        }
                        ToolbarItem{
                            NavigationLink(destination: SettingsView(showSignInView: $showSignInView, messagesViewModel: messagesViewModel)){Label("New Message", systemImage: "gearshape").foregroundColor(.gray)}
                        }
                        ToolbarItem{
                            Button(action: {deleteFromList.toggle()}, label: {
                                Image(systemName: "trash.circle")
                                    .foregroundColor(Color.red)
                            })
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("Welcome \(getName())")
                    Spacer(minLength: 120)
                        .background(Color(.systemGray6))
                }
                Image("Image")
                    .resizable()
                    .scaledToFit()
                    .background(Color(.systemGray6))
            }.ignoresSafeArea(edges: .bottom)
        }
    }
    func asName(id: String) -> String{
        if let name = userList.users.first(where:{$0.id == id})!.name {
            return name
        } else if let email = userList.users.first(where:{$0.id == id})!.email {
            return email
        } else {
            return id
        }
    }
    func getName() -> String {
        if let user = messagesViewModel.user{
            if let userName = user.name {
                return "\(userName)"
            } else {
                if let userEmail = user.email{
                    return "\(userEmail)"
                }
            }
        }
        return "User"
    }
    
    func checkDeletedMessages(text: String) -> Bool {
        for data in deletedMessages {
            if data.text == text {
                return false
            }
        }
        return true
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { drafts[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct DraftListItemView:View{
    @EnvironmentObject var userList:UserRepository
    @State var showBinMessage = false
    @Binding var deleteFromList:Bool
    @Environment(\.managedObjectContext) var viewContext
    var draft: Drafts
    var body: some View{
        HStack{
            HStack(alignment: .top){
                if deleteFromList == false {
                    if draft.isImportant{
                        Image(systemName: "exclamationmark.bubble")
                            .foregroundColor(.red).font(.system(size: 40))
                    } else {
                        Image(systemName: "text.bubble").font(.system(size: 40))
                    }
                }
                VStack(alignment: .leading){
                    Text(draft.text ?? "")
                        .foregroundColor(importantText())
                        .font(.headline)
                        .lineLimit(2)
                    HStack(spacing: 0){
                        Text("To: ")
                        ForEach(getRecipients(list: draft.recipientsArray, users: userList), id: \.self){ data in
                            Text(data)
                        }
                    }
                }.font(.system(size: 12))
            }
            Spacer()
            if deleteFromList{
                Image(systemName: "trash.circle").foregroundColor(.red).font(.system(size: 30)).onTapGesture {
                    showBinMessage = true
                }
                .alert(isPresented: $showBinMessage) {
                    Alert(
                        title: Text("Are you Sure?"),
                        message: Text("This will Delete this Message and All Records Of It"),
                        primaryButton: .default(
                            Text("Yes, Delete"),
                            action: {
                                deleteFromList = false
                                viewContext.delete(draft)
                            }
                        ),
                        secondaryButton: .destructive(
                            Text("Cancel"),
                            action: {deleteFromList = false}
                        )
                    )
                }
            }
        }
        .padding(5)
    }
    private func importantText() -> Color {
        if draft.isImportant {
            return Color.red
        } else {
            return Color.black
        }
    }
}

struct NewMessageListItemView:View{
    var messageViewModel: Message
    @EnvironmentObject var userList:UserRepository
    @State var showBinMessage = false
    @Binding var deleteFromList:Bool
    @State var iconSize = 40
    @State var isSender: Bool
    @EnvironmentObject var messageRepository: MessageRepository
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: DeletedMessages.entity(), sortDescriptors: [])
    var deletedMessages: FetchedResults<DeletedMessages>
    
    var body: some View{
        HStack{
            HStack(alignment: .top){
                if deleteFromList == false {
                    if messageViewModel.isImportant{
                        Image(systemName: "exclamationmark.bubble")
                            .foregroundColor(.red).font(.system(size: CGFloat(iconSize)))
                    } else {
                        Image(systemName: "text.bubble").font(.system(size: CGFloat(iconSize)))
                    }
                }
                VStack(alignment: .leading){
                    Text(messageViewModel.text)
                        .foregroundColor(importantText())
                        .font(.headline)
                        .lineLimit(2)
                    HStack(spacing: 0){
                        if isSender {
                            Text("To: ")
                            ForEach(getRecipients(list: messageViewModel.recipient, users: userList), id: \.self){ data in
                                Text("\(data)")
                            }
                        } else {
                            if let personName = userList.users.first(where:{$0.id == messageViewModel.sender})!.name {
                                Text("From: \(personName)")
                            } else if let personEmail = userList.users.first(where:{$0.id == messageViewModel.sender})!.email {
                                Text("From: \(personEmail)")
                            } else {
                                Text(messageViewModel.sender)
                            }
                        }
                    }
                }.font(.system(size: 12))
            }
            Spacer()
            if deleteFromList{
                Image(systemName: "trash.circle").foregroundColor(.red).font(.system(size: CGFloat(iconSize))).onTapGesture {
                    showBinMessage = true
                }
                .alert(isPresented: $showBinMessage) {
                    Alert(
                        title: Text("Are you Sure?"),
                        message: Text("This will Delete this Message and All Records Of It"),
                        primaryButton: .default(
                            Text("Yes, Delete"),
                            action: {
                                
                                if isSender{
                                    withAnimation{
                                        messageRepository.remove(messageViewModel)
                                    }
                                } else {
                                    withAnimation{
                                        let message = DeletedMessages(context: viewContext)
                                        message.text = messageViewModel.id
                                    }
                                }
                                deleteFromList = false
                                do {
                                    try viewContext.save()
                                } catch {
                                    let nsError = error as NSError
                                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                }
                            }
                        ),
                        secondaryButton: .destructive(
                            Text("Cancel"),
                            action: {deleteFromList = false}
                        )
                    )
                }
            }
        }
        .padding(5)
    }
    private func importantText() -> Color {
        if messageViewModel.isImportant {
            return Color.red
        } else {
            return Color.black
        }
    }
}

func getRecipients(list: [String], users: UserRepository) -> [String] {
    var people = [String]()
    
    for thisPerson in list {
        if let personName = users.users.first(where:{$0.id == thisPerson})!.name {
            people.append("\(personName)")
        } else if let personEmail = users.users.first(where:{$0.id == thisPerson})!.email {
            people.append("\(personEmail)")
        } else {
            people.append("\(thisPerson)")
        }
    }
    var index = people.count
    var newPeople = [String]()
    if index > 1 {
        for person in people {
            newPeople.append(person)
            if index > 2 {
                newPeople.append(", ")
                index -= 1
            } else if index == 2 {
                newPeople.append(" and ")
                index -= 1
            }
        }
    } else {
        newPeople = people
    }
    return newPeople
}
