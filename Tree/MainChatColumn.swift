//
//  MainChatColumn.swift
//  Tree
//
//  Refactored from ContentView.swift
//

import SwiftUI

extension ContentView {

    var mainChatColumn : some View{
        //make the Stack in it scrollable
        VStack(spacing: 0) {
            mainHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    //loop through each message in the array
                    ForEach(messages, id: \.text) { message in
                        messageRow(msg: message)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                //expands to full width of screen and left align 
            }

            chatInputBar(
                placeholder: "Message",
                text: $mainMessage,
                onSend: {
                    if !mainMessage.isEmpty {
                        //user message is always isUser: true
                        messages.append(ChatMessage(text: mainMessage, isUser: true))
                        DispatchQueue.main.async {
                            mainMessage = ""
                        }
                    }
                }
            )
        }
    }

    var mainHeader: some View {
        HStack(spacing: 8) {
            if !showChats{
                showChatsButton
                    .padding(.top, 10)
                    .padding(.leading, 12)
            }
            Image(systemName: "tree")
                .font(.title3)
                .padding(.top, 10)
                .padding(.leading, showChats ? 12 : 4)
            Text("Tree")
                .font(.headline)
                .padding(.top, 10)
            Spacer()
        }
        .padding(.bottom, 8)
    }

    var showChatsButton: some View{
        Button(action: {
            withAnimation{
                if showChats == true{
                    showChats = false
                } else {
                    showChats = true
                }
            }
        }){
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.black)
        }
        .buttonStyle(.bordered)
        .tint(.black)
    }

    func messageRow(msg: ChatMessage) -> some View {
        VStack(alignment: msg.isUser ? .trailing : .leading, spacing: 6) {//tells the alignment of all componetns inside
            HStack {
                //user message: push to the right
                if msg.isUser {
                    Spacer()
                }

                Text(msg.text)
                    .padding(12)
                    .background(msg.isUser ? Color.blue : Color.gray.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    //these are called view modifiers

                //AI message: push to the left
                if !msg.isUser {
                    Spacer()
                }
            }

            //branch button underneath AI messages only
            if !msg.isUser {
                Button {
                    withAnimation {
                        showBranch = true
                    }
                } label : {
                    HStack(spacing: 6) { //spacing determines the space betweenb components in stack
                        Image(systemName: "arrow.branch")
                        Text("Branch")
                    }
                    .font(.subheadline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.blue.opacity(0.15))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .opacity(showBranch ? 0 : 1)
                .disabled(showBranch)
            }
        }
    }
}
