//
//  CreateMessageView.swift
//  IA3V2
//
//  Created by James Nunn on 30/5/2023.
//

import SwiftUI
import CoreData

struct CreateMessageView: View {
    let badWordList = BadWordClass()
    @ObservedObject var messagesViewModel:MessagesViewModel
    @EnvironmentObject var messageRepository: MessageRepository
    @State var recipientIDs = [String]()
    @State var isImportant = false
    @State var messageText = ""
    @State var showAlert = false
    @EnvironmentObject var userList:UserRepository
    @State var showRecipients = false
    @State var wasDraft = false
    @Environment(\.presentationMode) var presentationMode
    var originalDraft: Drafts?
    @State var alertTitle = ""
    @State var alertMessage =  ""
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: Drafts.entity(), sortDescriptors: [])
    var drafts: FetchedResults<Drafts>
    @FetchRequest(entity: Recipients.entity(), sortDescriptors: [])
    var recipients: FetchedResults<Recipients>
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                VStack {
                    Text("Message Preview").font(.title3)
                    HStack{
                        HStack{
                            if isImportant {
                                Image(systemName: "exclamationmark.bubble")
                                    .font(.system(size: 30))
                                    .foregroundColor(.red)
                            } else {
                                Image(systemName: "text.bubble")
                                    .font(.system(size: 30))
                            }
                            VStack(alignment: .leading){
                                Text("\(messageText)")
                                    .font(.headline)
                                    .foregroundColor(importantText())
                                Divider()
                                
                                if let user = messageRepository.userId{
                                    Text("From: \(asName(id: user))")
                                }
                            }
                            .font(.system(size:15))
                        }.frame(minHeight: 60)
                            .padding(5)
                            .background(Color.white)
                            .cornerRadius(16)
                        Spacer()
                        Button(action:{
                            if messageText.containsProfanity(){
                                alertTitle = "Message Blocked"
                                alertMessage = "Your message contains profanity - please remember caritas, edit it, and try again."
                                showAlert = true
                            } else {
                                addMessage()
                            }
                        }){
                            if recipientIDs.count<1 {
                                VStack{
                                    Image(systemName: "paperplane.circle.fill")
                                    Text("Send")
                                }
                                .padding()
                                .font(.headline)
                                .foregroundColor(changeSendButtonForeground())
                                .background(changeSendButtonBackground())
                                .cornerRadius(16)
                            }
                            else {
                                VStack{
                                    Image(systemName: "paperplane.circle")
                                    Text("Send")
                                }
                                .padding()
                                .font(.headline)
                                .foregroundColor(.white)
                                .background(changeSendButtonBackground())
                                .cornerRadius(16)
                            }
                            
                        }.disabled(recipientIDs.count<1)
                    }.frame(height: 80)
                }
                .frame(width: geo.size.width * 0.7)
                Form {
                    Section(header: Text("Recipients")) {
                        Button("Select Recipients") {
                            showRecipients = true
                        }
                    }
                    if !recipientIDs.isEmpty {
                        HStack {
                            ForEach(recipientIDs, id: \.self) { thisPerson in
                                HStack {
                                    if let personName = userList.users.first(where: { $0.id == thisPerson })?.name {
                                        Text(personName)
                                    } else if let personEmail = userList.users.first(where: { $0.id == thisPerson })?.email {
                                        Text(personEmail)
                                    } else {
                                        Text(thisPerson)
                                    }
                                    Image(systemName: "x.circle")
                                }
                                .padding(5)
                                .lineLimit(1)
                                .onTapGesture {
                                    let index = recipientIDs.firstIndex(of: thisPerson)!
                                    recipientIDs.remove(at: index)
                                }
                                Spacer()
                            }
                            .background(Color.white)
                            .cornerRadius(10)
                        }
                        .listRowBackground(Color(.systemGray6))
                    }
                    Section(header: Text("Message Text")) {
                        HStack {
                            if messageText == "" {
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            TextField("Message text", text: $messageText)
                        }
                    }
                    Section(header: Text("Priority Level")) {
                        Picker("Priority", selection: $isImportant) {
                            HStack {
                                Text("High")
                            }.tag(true)
                            HStack {
                                Text("Normal")
                            }.tag(false)
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .background(Color(.systemGray6))
            .sheet(isPresented: $showRecipients) {recipientListView(recipientIDs: $recipientIDs)
            }
            .navigationTitle("New Message")
            .toolbar{
                ToolbarItem{
                    Button("Draft"){
                        let newDraft = Drafts(context: viewContext)
                        newDraft.text = messageText
                        newDraft.isImportant = isImportant
                        newDraft.id = UUID()
                        var recipientList: [Recipients] = []
                        for person in recipientIDs {
                            let newRecipient = Recipients(context: viewContext)
                            newRecipient.name = person
                            newRecipient.id = UUID()
                            newRecipient.drafts = newDraft
                            recipientList.append(newRecipient)
                        }
                        newDraft.recipients = NSSet(array: recipientList)
                        do {
                            if wasDraft{
                                viewContext.delete(originalDraft!)
                            }
                            try viewContext.save()
                            presentationMode.wrappedValue.dismiss()
                            
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("Got it!"))
            )
        }
    }
    
    private func importantText() -> Color {
        if isImportant {
            return Color.red
        } else {
            return Color.black
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
    
    private func changeSendButtonForeground() -> Color {
        
        var mybackground = Color.blue
        if recipientIDs.count<1 {
            mybackground = Color.gray
        }
        return mybackground
        
    }
    private func changeSendButtonBackground() -> Color {
        
        var mybackground = Color.blue
        if recipientIDs.count<1 {
            mybackground = Color.white
        }
        return mybackground
        
    }
    
    private func addMessage(){
        if wasDraft{
            viewContext.delete(originalDraft!)
        }
        let message = Message(isImportant: isImportant, text: messageText, recipient: recipientIDs, sender: messagesViewModel.user!.id, dateSent: Date.now)
        messageRepository.add(message)
        isImportant = false
        messageText = ""
        recipientIDs = []
        alertTitle = "Message Sent"
        alertMessage = "Your message has been sent. Check your sent messages folder for actions such as to delete or edit."
        showAlert = true
    }
}

struct recipientListView:View {
    @Binding var recipientIDs:[String]
    @EnvironmentObject var userList:UserRepository
    @Environment(\.dismiss) var dismissMe
    @State var searchText = ""
    
    var body: some View{
        NavigationStack{
            VStack{
                HStack{
                    SearchBar(text: $searchText)
                    Text("\(userList.users.count) Users Found")
                }.padding()
                List{
                    ForEach(userList.users.filter({searchText.isEmpty ? true : $0.name!.contains(searchText) || $0.email!.contains(searchText)}), id:\.self){thisUser in
                        Button(action:{
                            if recipientIDs.contains(where: {$0 == thisUser.id}){
                                let index = recipientIDs.firstIndex(where: {$0 == thisUser.id})!
                                recipientIDs.remove(at: index)
                            } else {
                                recipientIDs.append(thisUser.id)
                            }
                        }){
                            if (recipientIDs.first(where: {$0 == thisUser.id}) != nil){
                                HStack{
                                    Image(systemName: "envelope.circle")
                                    if let userName = thisUser.name {
                                        Text(userName)
                                    } else if let userEmail = thisUser.email{
                                        Text(userEmail)
                                    } else {
                                        Text(thisUser.id)
                                    }
                                }.foregroundColor(.green)
                            } else {
                                HStack{
                                    Image(systemName: "circle")
                                    if let userName = thisUser.name {
                                        Text(userName)
                                    } else if let userEmail = thisUser.email{
                                        Text(userEmail)
                                    } else {
                                        Text(thisUser.id)
                                    }
                                }.foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Recipients")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action:{
                        dismissMe()
                    }){
                        Text("Done")
                            .font(.headline)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
}
