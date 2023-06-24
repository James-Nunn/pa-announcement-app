//
//  SettingsView.swift
//  IA3V2
//
//  Created by James Nunn on 30/5/2023.
//

import SwiftUI
import FirebaseAuth

@MainActor
final class SettingsViewModel:ObservableObject {
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    func resetPassword() async throws{
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else{
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    func updatePassword(newPassword:String) async throws{
        try await AuthenticationManager.shared.updatePassword(password: newPassword)
    }
    
    func deleteUser() async throws {
        try await AuthenticationManager.shared.deleteUser()
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView:Bool
    @State var showResetPasswordAlert = false
    @State var showPasswordUpdatedAlert = false
    @State var newPassword = ""
    @State var passwordErrorMessage = ""
    @State var showPasswordErrorMessage = false
    @StateObject var messagesViewModel:MessagesViewModel
    
    var body: some View {
        List{
            Section(header:
                        Text("Your Details").foregroundColor(Color.schoolRedColor)){
                if let user = messagesViewModel.user{
                    if let userEmail = user.email{
                        HStack{
                            Text("Email: ").bold()
                            Text(userEmail)
                        }
                    }
                    if let userName = user.name {
                        HStack{
                            Text("User name: ").bold()
                            Text(userName)
                        }
                    }
                    HStack{
                        Text("User Authorisation").bold()
                        Spacer()
                        Button {
                            messagesViewModel.toggleStaffStatus()
                        } label: {
                            if user.isStaff ?? false {
                                Text("STAFF USER")
                                    .bold()
                                    .font(.system(size: 10))
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.red)
                                    .cornerRadius(16)
                            } else {
                                Text("STUDENT USER")
                                    .bold()
                                    .font(.system(size: 10))
                                    .font(.headline)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.green)
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
            }
            Section(header:
                        Text("PASSWORD").foregroundColor(Color.schoolRedColor)){
                //                    Button("Reset Password"){
                //                        Task{
                //                            do {
                //                                try await viewModel.resetPassword()
                //                                showResetPasswordAlert = true
                //                                print("PASSWORD RESET")
                //                            } catch{
                //                                print(error)
                //                            }
                //                        }
                //                    }
                HStack{
                    SecureField("New Password", text: $newPassword)
                    Button("Update Password"){
                        Task{
                            do {
                                try await viewModel.updatePassword(newPassword:newPassword)
                                showPasswordUpdatedAlert = true
                                print("PASSWORD Updated")
                            } catch{
                                passwordErrorMessage = error.localizedDescription
                                showPasswordErrorMessage = true
                                print(error)
                            }
                        }
                    }
                }
            }
            Section{
                Button("Log Out"){
                    Task{
                        do {
                            try viewModel.signOut()
                            showSignInView = true
                        } catch{
                            print(error)
                        }
                    }
                }
                //                    Button(role: .destructive){
                //                        Task{
                //                            do {
                //                                try await viewModel.deleteUser()
                //                                showSignInView = true
                //                            } catch{
                //                                passwordErrorMessage = error.localizedDescription
                //                                showPasswordErrorMessage = true
                //                                print(error)
                //                            }
                //                        }
                //                    } label: {
                //                        Text("Delete Account")
                //                    }
            }
        }
        .navigationTitle("Settings")
        .alert(isPresented: $showResetPasswordAlert) {
            Alert(title: Text("Password Reset"), message: Text("Your password has been reset. Please check your email for instructions."), dismissButton: .default(Text("Got it!")))
        }
        .alert(isPresented: $showPasswordUpdatedAlert) {
            Alert(title: Text("Password Updated"), message: Text("Your password has been updated. Please use your new password from now on."), dismissButton: .default(Text("Got it!")))
        }
        .alert(isPresented: $showPasswordErrorMessage) {
            Alert(title: Text("Error"), message: Text(passwordErrorMessage), dismissButton: .default(Text("Got it!")))
        }
    }
}

