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
                    //loop through each message in the selected chat
                    ForEach(getCurrentChat().messages) { message in
                        messageRow(msg: message)
                    }

                    if isMainThinking {
                        HStack(spacing: 8) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Thinking…")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
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
                    let text = mainMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    guard !isMainThinking else { return }

                    let pathSnapshot = selectedChatPath

                    // 1) append user message
                    updateChatMessages(path: pathSnapshot, message: ChatMessage(text: text, isUser: true))
                    mainMessage = ""

                    // 2) call local LLM and append assistant reply
                    Task {
                        await MainActor.run { isMainThinking = true }
                        defer { Task { await MainActor.run { isMainThinking = false } } }

                        let activeChat = getChat(at: pathSnapshot)
                        let history = activeChat.modelContext
                        let ollamaMessages: [OllamaClient.Message] =
                            [OllamaClient.Message(role: .system, content: llmSystemPrompt)] +
                            history.map { msg in
                                OllamaClient.Message(
                                    role: OllamaClient.Role(rawValue: msg.isUser ? "user" : "assistant") ?? .assistant,
                                    content: msg.text
                                )
                            }

                        do {
                            let reply = try await llm.chat(model: llmModel, messages: ollamaMessages)
                            await MainActor.run {
                                updateChatMessages(path: pathSnapshot, message: ChatMessage(text: reply, isUser: false))
                            }
                        } catch {
                            await MainActor.run {
                                updateChatMessages(
                                    path: pathSnapshot,
                                    message: ChatMessage(text: "LLM error: \(error.localizedDescription)", isUser: false)
                                )
                            }
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
            Label("Local \(llmModel)", systemImage: "lock.shield")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.green.opacity(0.1))
                .clipShape(Capsule())
                .padding(.top, 10)
                .padding(.trailing, 12)
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
                    .padding(10)
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
                        // Track which message and chat this branch was created from
                        branchFromMessageId = msg.id
                        let currentChat = getCurrentChat()
                        branchFromChatId = currentChat.id
                        branchContextMessages = currentChat.contextPrefix(through: msg.id)
                        branchMessages = []
                        selectedBranchType = "Temporary"
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
