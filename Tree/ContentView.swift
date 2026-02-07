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
    //array of fake msgs
    @State private var messages: [String] = [
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

    @State private var branchMessages = [
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

    @State private var chats = [
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

    //user can pick which chat to rename
    @State private var renameChatIndex: Int = -1

    //new chat's name after renaming
    @State private var newName: String = ""

    //adjust width of chat side bar
    @State private var chatSidebarWidth: CGFloat = 220

    //main messsage input bar
    @State private var mainMessage: String = ""


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

//Subviews that ContentView can render
private extension ContentView {

    var chatSidebar : some View {
        HStack {
            VStack {
                chatHeader
                ScrollView {
                    VStack(alignment: .leading) {
                        //looping through indices in arr
                        ForEach(chats.indices, id: \.self) { index in
                            if renameChatIndex == index {
                                // on commit entails what happens when we click enter
                                TextField("Chat name", text: $newName, onCommit: {
                                    //if no new text just revert bnack to original name
                                    chats[index] = newName.isEmpty ? chats[index] : newName
                                    renameChatIndex = -1
                                })
                                .textFieldStyle(.plain)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                            } else {
                                Text(chats[index])
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .onTapGesture { //when clicked the text we change the renameChatIndex to that index
                                        renameChatIndex = index
                                        newName = chats[index] //and we also initialize newName as the current text
                                    }
                            }
                        }
                    }
                }
            }
            .padding() //padding around VStack
            .frame(width: chatSidebarWidth) //width of vstack
            .background(Color.gray.opacity(0.1))

            // drag handle added to the right （HStack）
            Capsule()
                .fill(Color.gray.opacity(0.45))
                .frame(width: 8)
                .overlay(
                    VStack(spacing: 4) {
                        Circle().fill(Color.white.opacity(0.8)).frame(width: 3, height: 3)
                        Circle().fill(Color.white.opacity(0.8)).frame(width: 3, height: 3)
                        Circle().fill(Color.white.opacity(0.8)).frame(width: 3, height: 3)
                    }
                )
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                .onHover { hovering in
                    if hovering {
                        NSCursor.resizeLeftRight.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                .gesture(
                    DragGesture()
                        //when dragging
                        .onChanged { value in
                            let newWidth = chatSidebarWidth + value.translation.width //newWidth created once, nvr reassigned
                            chatSidebarWidth = min(max(newWidth, 180), 360) //160 is minimum width 360 is max width
                        }
                )

        }
    }

    var chatHeader : some View {
        HStack {
            showChatsButton

            Spacer()

            Button(action: {
                print("New Chat")
            }){
                Image(systemName: "plus")
                    .foregroundColor(.white)
                Text("New Chat")
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(.bordered)
            .tint(.white)
        }
    }

    var mainChatColumn : some View{
        //make the Stack in it scrollable
        VStack(spacing: 0) {
            mainHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
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

            chatInputBar(
                placeholder: "Message",
                text: $mainMessage,
                onSend: {
                    if !mainMessage.isEmpty {
                        messages.append(mainMessage)
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
            if !showBranch {
                Button{
                    withAnimation{
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
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.borderedProminent)
                .opacity(showBranch ? 0 : 1)
                .disabled(showBranch)
                .animation(.easeInOut(duration: 0.2), value: showBranch)
            }
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
                            branchMessageRow(message: msg)
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

    func branchMessageRow(message: String) -> some View {
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
        action: @escaping () -> Void //action is whatever is inside the button's content
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
        chatInputBar(
            placeholder: "Message", //text that appears when there is no input, branchMessage = ""
            text: $branchMessage,
            onSend: {
                if !branchMessage.isEmpty {
                    branchMessages.append(branchMessage)
                    DispatchQueue.main.async {
                            branchMessage = ""
                    }
                }
            }
        )
        
    }

    func chatInputBar(
        placeholder: String,
        text: Binding<String>,
        onSend: @escaping() -> Void //The content of chatInputBar runs only when clicked
    ) -> some View {
        HStack {
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
            
            Button(action: onSend) {
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

