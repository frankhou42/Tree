//
//  ContentView.swift
//  Tree
//
//  Created by Frank Hou on 2/2/26.
//

import SwiftUI
// view == component
//ContentView -> screen component
//extends View rules, View type provides the entire UI
struct ContentView: View {
    //array of fake msgs
    let messages = [
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

    let branchMessages = [
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

    let chats = [
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
    @State private var showBranch = false

    //Tracks the type of branch the user chooses, determine UI behavior
    @State private var selectedBranchType: String = "Temporary"

    //user input in branch panel, each time user types the state re-renders to show
    //every single chracter user inputed
    @State private var branchMessage: String = ""

    //show the chats log
    @State private var showChats = true

    //which chat to rename
    @State private var renameChatIndex: Int = -1

    //new chat's name after renaming
    @State private var newName: String = ""

    //specific view type provide only a type of view
    var body: some View {
        HStack(spacing: 0) {
            if showChats {
                chatSidebar
            }
            mainChatColumn
            if showBranch {
                branchPanel
            }
        }
    }
}

//Subviews that ContentView can render
private extension ContentView {

    var chatSidebar : some View {
        VStack {
            chatHeader
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(chats, id: \.self) {
                        chat in Text(chat)
                            .foregroundColor(.black)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } 
                }
            }
        }
        .padding() //padding around VStack
        .frame(width: 220) //width of vstack
        .background(Color.white)
    }

    var chatHeader : some View {
        HStack {
            showChatsButton

            Spacer()

            Button(action: {
                print("New Chat")
            }){
                Image(systemName: "plus")
                    .foregroundColor(.black)
                Text("New Chat")
                    .foregroundColor(.black)
                    .padding()
            }
            .buttonStyle(.bordered)
            .tint(.black)
        }
    }

    var mainChatColumn : some View{
        //make the Stack in it scrollable
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                mainHeader

                //loop through each message in the array
                //id tells what we are iterating over
                //the item being looped is named as message
                ForEach(messages, id: \.self) { 
                    message in messageRow(msg: message)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            //expands to full width of screen and left align 
        }
    }

    
    var mainHeader: some View {
        HStack(spacing: 8) {
            if !showChats{
                showChatsButton
            }
            Image(systemName: "sparkles")
                .font(.title3)
            Text("Learning")
                .font(.headline)
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
        .transition(.move(edge: .trailing))
        //only defines a component's animation
        .buttonStyle(.bordered)
        .tint(.black)
    }


    func messageRow(msg: String) -> some View {
        HStack{
            //components in the stack (left to right ordered)
            //user messages
            Text(msg)
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

            Spacer()

            //the branching
            Button("Branch"){
                withAnimation{
                    showBranch = true
                }
            }
            .buttonStyle(.borderedProminent)
            .transition(.move(edge: .trailing))
        }
    }
    

    var branchPanel : some View { //some View is a description of UI
        VStack(spacing: 0){
            //renders a VStack in the BIG HStack
            branchHeader
            //space around a view

            // Scrollable branch messages
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if branchMessages.isEmpty {
                        // Empty state: centered placeholder
                        VStack(spacing: 12) {
                            Image(systemName: "arrow.branch")
                                .font(.system(size: 32))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("Ask a side question")
                                .font(.headline)
                                .foregroundColor(.black)
                            Text("Explore tangents without losing your main thread")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding()
                    } else {
                        ForEach(branchMessages, id: \.self) { msg in
                            branchMessageRow(msg)
                        }
                        .foregroundColor(.black)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }

            Spacer()

            // Message input at bottom
            branchInputBar
        }
        .frame(width: 300)
        .padding()
        .background(Color.white)
    }

    func branchMessageRow(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(message)
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var branchHeader: some View {
        VStack(spacing: 12){
            HStack {
                Text("Side Exploration")
                    //sets the color of the component
                    .foregroundColor(.black)

                Spacer()

                Button(action: {
                    withAnimation{
                        showBranch = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
                .transition(.move(edge: .trailing))
            }

            //choosing between temp or independent
            HStack(spacing: 12) {
                branchTypeButton(
                    title: "Temporary",
                    icon: "clock",
                    color: .blue,
                    isSelected: selectedBranchType == "Temporary"
                ) {
                    selectedBranchType = "Temporary"
                }
                

                branchTypeButton(
                    title: "Permanent",
                    icon: "sparkles",
                    color: .purple,
                    isSelected: selectedBranchType == "Permanent"
                ) {
                    selectedBranchType = "Permanent"
                }
            }
            //hint text for tips
            Text(selectedBranchType == "Temporary" ? "Deleted when closed" : "Saved and can be reopened")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    func branchTypeButton(
        title: String,
        icon: String,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void //
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .foregroundColor(isSelected ? .white : .black)
        }
        .background(isSelected ? color : Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    var branchInputBar: some View {
        HStack {
            TextField("Message", text: $branchMessage)
                .textFieldStyle(.plain)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.black)

            //action entails the code that run when the button is pressed
            Button(action: {
                print("Send: \(branchMessage)")
                branchMessage = ""
            }) {
                //how does the button look
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}

// tells xcode to show a live demo
#Preview {
    ContentView()
    .frame(width: 1000, height: 700)
    .previewLayout(.fixed(width: 1000, height: 700))
}

