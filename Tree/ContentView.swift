//
//  ContentView.swift
//  Tree
//
//  Created by Frank Hou on 2/2/26.
//

import SwiftUI
// view == component
//ContentView -> screen component
//extends View rules
struct ContentView: View {
    //array of fake msgs
    let messages = [
        "what is recursion?",
        "create 10 billion dollar app",
        "simpler"
    ]

    //whenever this var's val is changed the UI re-renders automatically
    //private -> only accessible in content view struct
    @State private var showBranch = false

    //Tracks the type of branch the user chooses, determine UI behavior
    @State private var selectedBranchType: String = "Temporary"

    //user input in branch panel, each time user types the state re-renders to show
    //every single chracter user inputed
    @State private var branchMessage: String = ""

    var body: some View {
        HStack(spacing: 0) {
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
    var mainChatColumn : some View{
        VStack(alignment: .leading, spacing: 16) {
            mainHeader

            //loop through each message in the array
            //id tells what we are iterating over
            //the item being looped is named as message
            ForEach(messages, id: \.self) { message in
                messageRow(message)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    var mainHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.title3)
            Text("Learning")
                .font(.headline)
        }
        .padding(.bottom, 8)
    }

    func messageRow(_ message: String) -> some View {
        HStack{
            //components in the stack (left to right ordered)
            //user messages
            Text(message)
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

            Spacer()

            //the branching
            Button("Branch"){
                showBranch = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    var branchPanel : some View {
        VStack(spacing: 0){
            //renders a VStack in the BIG HStack
            branchHeader
            //space around a view

            Spacer()

            // Message input at bottom
            branchInputBar
        }
        .frame(width: 300)
        .padding()
        .background(Color.white)
        //animation when rendering this componenet relates withAnimation
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
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(isSelected ? color : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(8)
        }
    }
    var branchInputBar: some View {
        HStack {
            TextField("Message", text: $branchMessage)
                .textFieldStyle(.plain)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.black)

            Button(action: {
                print("Send: \(branchMessage)")
                branchMessage = ""
            }) {
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
}
