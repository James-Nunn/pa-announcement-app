//
//  SignInEmailView.swift
//  IA3V2
//
//  Created by James Nunn on 30/5/2023.
//

import SwiftUI

@MainActor
final class SignInEmailViewModel:ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws{
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signIn() async throws{
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}

struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView:Bool
    @State var showSignInError = false
    @State var signInErrorMessage = ""
    
    var body: some View {
        ZStack{
            ZStack{
                HStack{
                    Ellipse()
                        .fill(Color.white)
                        .frame(width: 1000, height: 800)
                        .rotationEffect(.degrees(-20))
                        .offset(x: -90, y: -240)
                    Spacer()
                }.padding(.bottom, 30)
                VStack{
                    Spacer()
                    Image("Image")
                        .resizable()
                        .scaledToFit()
                }
            }
            HStack{
                VStack{
                    Spacer()
                    Image("logoLarge")
                        .resizable()
                        .frame(width: 400, height: 300)
                        .padding(.bottom, 150)
                    Spacer()
                }.padding(.leading, 150)
                Spacer()
                VStack(alignment: .leading){
                    Text("Welcome,")
                        .foregroundColor(Color(red: 170/255, green: 33/255, blue: 65/255))
                        .font(.largeTitle)
                    Form{
                        VStack(alignment: .leading){
                            Text("Enter User Name").bold()
                            TextField("User Name", text: $viewModel.email)
                                .foregroundColor(Color.black)
                        }
                        VStack(alignment: .leading){
                            Text("Enter Password").bold()
                            SecureField("Password", text: $viewModel.password)
                                .foregroundColor(Color.black)
                        }
                        VStack(alignment: .leading){
                            Spacer()
                            Button{
                                Task{
                                    if viewModel.email.isValidEmail() {
                                        do {
                                            try await viewModel.signIn()
                                            showSignInView = false
                                            try await MessagesViewModel().loadCurrentUser()
                                            return
                                        } catch {
                                            signInErrorMessage = error.localizedDescription
                                            showSignInError = true
                                            print(error)
                                        }
                                    } else {
                                        signInErrorMessage = "Your Email format was Invalid"
                                        showSignInError = true
                                    }
                                }
                            } label: {
                                if viewModel.email==""||viewModel.password==""{
                                    Text("Sign In")
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("Sign In")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                }
                                
                            }
                            .background(buttonTextColour(u: viewModel.email, p: viewModel.password))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .buttonStyle(.bordered)
                            .disabled(viewModel.email==""||viewModel.password=="")
                        }
                        .alert(isPresented: $showSignInError) {
                            Alert(title: Text("Error"), message: Text(signInErrorMessage), dismissButton: .default(Text("Got it!")))
                        }
                    }
                    .scrollDisabled(true)
                    .frame(width: 300, height: 310)
                    .background(Color.white)
                    .scrollContentBackground(.hidden)
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .padding(.bottom, 40)
                }
                Spacer()
            }
        }.ignoresSafeArea()
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        
        
            .alert(isPresented: $showSignInError) {
                Alert(title: Text("Error"), message: Text(signInErrorMessage), dismissButton: .default(Text("Got it!")))
            }
        
    }
}

func buttonTextColour(u: String, p: String) -> Color{
    if p == "" || u == "" {
        return Color.secondary
    } else {
        return Color.blue
    }
}
