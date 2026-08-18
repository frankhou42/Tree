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
                            if let source = branchContextMessages.last?.text {
                                Text("Forked from: \(source)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                    .padding(.top, 4)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding()
                    } else {
                        //reuse messageRow from MainChatColumn (no branch button in panel)
                        ForEach(branchMessages) { msg in
                            branchMessageRow(msg: msg)
                        }
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

    //reuse same user/AI styling as main chat but without branch button
    func branchMessageRow(msg: ChatMessage) -> some View {
        HStack {
            if msg.isUser {
                Spacer()
            }

            Text(msg.text.isEmpty && msg.isStreaming ? "…" : msg.text)
                .padding(12)
                .background(msg.isUser ? Color.blue : Color.gray.opacity(0.1))
                .foregroundColor(msg.isUser ? .white : .black)
                .cornerRadius(8)

            if !msg.isUser {
                Spacer()
            }
        }
    }

    var branchHeader: some View {
        VStack(spacing: 12){
            HStack {
                Text("Branched Exploration")
                    //sets the color of the component
                    .foregroundColor(.black)

                Spacer()

                Button(action: {
                    withAnimation{
                        closeBranchPanel()
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
                .disabled(isResponding)
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

            Label(
                "Fork carries \(branchContextMessages.count) parent messages",
                systemImage: "point.3.connected.trianglepath.dotted"
            )
            .font(.caption2)
            .foregroundColor(.secondary)
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
            placeholder: isResponding ? "Responding…" : "Message",
            text: $branchMessage,
            textColor: .black,
            onSend: {
                let text = branchMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty, !isResponding else { return }
                branchMessage = ""
                sendBranchMessage(text)
            }
        )
    }
}
