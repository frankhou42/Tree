//
//  ContentView.swift
//  Tree
//
//  Created by Frank Hou on 2/2/26.
//

import SwiftUI

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

    //Tracks the type of branch the user chooses
    @State private var selectedBranchType: String = "Temporary"

    //variable name : return type is of some kind of display
    var body: some View {
        //horizontal container
        //children stacks are arranged left to right
        //spacing means no gap between children
        //holds the main chat and the branch panel
        HStack(spacing: 0){
            // align item to the left edge
            //children arranged top to bottom with 16 pts spacing
            //stack of branchable convo
            VStack(alignment: .leading, spacing: 16) {
                //loop through each message in the array
                //id tells what we are iterating over
                //the item being looped is named as message
                ForEach(messages, id: \.self) { message in
                    //each message has a horizontal stack
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
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            //VStack takes all available space
        
            //right panel is conditional when showBranch is true
            if showBranch {
                //renders a VStack in the BIG HStack
                VStack {
                    Text("Side Exploration")

                    Button("Close") {
                        withAnimation {
                            showBranch = false
                        }
                    }
                    .buttonStyle
                }
                .frame(width: 300)
                .padding()
                .transition(.move(edge: .trailing))
                //animation when rendering this componenet relates withAnimation


            }
        }
    }
}

// tells xcode to show a live demo
#Preview {
    ContentView()
}
