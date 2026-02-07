//
//  ContentView.swift
//  Tree
//
//  Created by Frank Hou on 1/5/26.
//

import SwiftUI
import AppKit
// view == component
//ContentView -> screen component
//extends View rules, View type provides the entire UI
struct ContentView: View {
    //array of chat messages
    //isUser: true = right-aligned, no branch button
    //isUser: false = left-aligned, branchable
    @State var messages: [ChatMessage] = [
        ChatMessage(text: "what is recursion?", isUser: true),
        ChatMessage(text: "Recursion is when a function calls itself.", isUser: false),
        ChatMessage(text: "simpler", isUser: true),
        ChatMessage(text: "It's a loop that calls itself instead of repeating.", isUser: false),
    ]

    @State var branchMessages: [String] = [
        "what is recursion?",
        "create 10 billion dollar app",
        "simpler",
        "scroll",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test",
        "test"
    ]

    @State var chats: [String] = [
        "Chat 1",
        "Chat 2",
        "Chat 3",
        "Chat 1",
        "Chat 2",
        "Chat 3",
        "Chat 1",
        "Chat 2",
        "Chat 3",
        "Chat 1",
        "Chat 2",
        "Chat 3",
        "Chat 1",
        "Chat 2",
        "Chat 3",
        "Chat 1",
        "Chat 2",
        "Chat 3"
    ]

    //whenever @State var's val is changed the UI re-renders automatically
    //private -> only accessible in content view struct
    @State var showBranch = false

    //Tracks the type of branch the user chooses, determine UI behavior
    @State var selectedBranchType: String = "Temporary"

    //user input in branch panel, each time user types the state re-renders to show
    //every single chracter user inputed
    @State var branchMessage: String = ""

    //show the chats log
    @State var showChats = true

    //user can pick which chat to rename
    @State var renameChatIndex: Int = -1

    //new chat's name after renaming
    @State var newName: String = ""

    //adjust width of chat side bar
    @State var chatSidebarWidth: CGFloat = 220

    //main messsage input bar
    @State var mainMessage: String = ""


    //specific view type provide only a type of view
    var body: some View {
        HStack {
            if showChats {
                chatSidebar
                .transition(.move(edge: .leading)) //View property
            }
            mainChatColumn
            if showBranch {
                branchPanel
                .transition(.move(edge: .trailing))
            }
        }
    }
}

// tells xcode to show a live demo
#Preview {
    ContentView()
    .frame(width: 1000, height: 700)
    .previewLayout(.fixed(width: 1000, height: 700))
}

