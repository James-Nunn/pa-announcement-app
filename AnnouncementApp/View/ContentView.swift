//
//  ContentView.swift
//  IA3V2
//
//  Created by James Nunn on 30/5/2023.
//

//jameses.user@henryr.com
//123456

import SwiftUI
import UserNotifications
import FirebaseAuth

struct ContentView: View {
    @State var showSignInView = false
    @ObservedObject var userList = UserRepository()
    
    var body: some View {
        LandingTabView(showSignInView: $showSignInView)
            .onAppear{
                let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
                self.showSignInView = authUser == nil
            }
            .fullScreenCover(isPresented: $showSignInView){
                SignInEmailView(showSignInView: $showSignInView)
            }
            .environmentObject(userList)
    }
}
