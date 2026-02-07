//
//  BranchPanel.swift
//  Tree
//
//  Refactored from ContentView.swift
//

import SwiftUI

extension ContentView {

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
}
