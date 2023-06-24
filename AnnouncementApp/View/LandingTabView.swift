//
//  LandingTabView.swift
//  IA3V2
//
//  Created by James Nunn on 30/5/2023.
//

import SwiftUI

struct LandingTabView: View {
    @Binding var showSignInView:Bool
    @StateObject var messagesViewModel = MessagesViewModel()
    @StateObject var messageRepository = MessageRepository()
    @State var isRotating = 0.0
    
    var body: some View {
        VStack{
            if messagesViewModel.user != nil{
                MessagesView(messagesViewModel: messagesViewModel, showSignInView: $showSignInView)
            }else{
                VStack{
                    Image(systemName: "line.3.crossed.swirl.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(isRotating))
                        .onAppear{
                            withAnimation(.linear(duration:1.0).speed(0.9).repeatForever(autoreverses: false)){
                                isRotating = 360
                            }
                        }
                    Text("Loading - Please be patient")
                }
            }
        }
        .task{
            try? await messagesViewModel.loadCurrentUser()
        }
        .environmentObject(messageRepository)
    }
}
