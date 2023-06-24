//
//  EditDraftView.swift
//  IA3V2
//
//  Created by James Nunn on 30/5/2023.
//

import SwiftUI

struct EditDraftView: View {
    @ObservedObject var messagesViewModel:MessagesViewModel
    @ObservedObject var messageListViewModel:MessageListViewModel
    @State var recipientIDs = [String]()
    @State var isImportant = false
    @State var messageText = ""
    @State var showConfirmationMessage = false
    @EnvironmentObject var userList:UserRepository
    @State var showRecipients = false
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                VStack {
                    Text("Message Preview").font(.title3)
                    HStack{
                        HStack{
                            if isImportant {
                                Image(systemName: "exclamationmark.bubble")
                                    .foregroundColor(.red)
                            } else {
                                Image(systemName: "text.bubble")
                            }
                            
                            VStack(alignment: .leading){
                                Text("\(messageText)")
                                    .font(.headline)
                                Divider()
                                
                                if let user = messagesViewModel.user{
                                    if let userName = user.name {
                                        Text("From: \(userName)")
                                    } else if let userEmail = user.email{
                                        Text("From: \(userEmail)")
                                    }
                                }
                            }
                            .font(.system(size:15))
                        }
                        .padding()
                        Spacer()
                        Button(action:addMessage){
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
                    }.frame(height: 90)
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
            .sheet(isPresented: $showRecipients) {
                DraftRecipientListView(recipientIDs: $recipientIDs)
            }
            .navigationTitle("New Message")
        }
        .alert(isPresented: $showConfirmationMessage) {
            Alert(
                title: Text("Message Sent"),
                message: Text("Your message has been sent. Check your sent messages folder for actions such as to delete or edit."),
                dismissButton: .default(Text("Got it!"))
            )
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
        // 1
        let message = Message(isImportant: isImportant, text: messageText, recipient: recipientIDs, sender: messagesViewModel.user!.id)
        //2
        messageListViewModel.add(message)
        //3
        isImportant = false
        messageText = ""
        recipientIDs = []
        //4
        showConfirmationMessage = true
    }
}

struct DraftRecipientListView:View {
    
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
                    ForEach (userList.users.filter({searchText.isEmpty ? true : $0.name!.contains(searchText) || $0.email!.contains(searchText)}), id:\.self){thisUser in
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
                ToolbarItem{
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
