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
    // Local open-source LLM (Ollama)
    let llm = OllamaClient()
    @State var llmModel: String = "qwen3:0.6b"
    @State var llmSystemPrompt: String = "You are a helpful assistant to help student to study, explain everything simply and intuitively"
    @State var isMainThinking: Bool = false
    @State var isBranchThinking: Bool = false

    //each Chat holds its own messages, so switching chats swaps the message list
    //loads saved chats from disk, or starts with one empty chat on first launch
    @State var chats: [Chat] = ChatStore.load() ?? [
        Chat(name: "New Chat", messages: [])
    ]

    //index of the chat that is being selected in the sidebar
    @State var selectedChatIndex: Int = 0

    //path to selected chat (handles nested chats)
    @State var selectedChatPath: [Int] = [0]

    @State var branchMessages: [ChatMessage] = []
    @State var branchContextMessages: [ChatMessage] = []

    //whenever @State var's val is changed the UI re-renders automatically
    //private -> only accessible in content view struct
    @State var showBranch = false

    //Tracks which message the branch was created from
    @State var branchFromMessageId: UUID? = nil
    //Tracks which chat the branch was created from
    @State var branchFromChatId: UUID? = nil

    //Tracks the type of branch the user chooses, determine UI behavior
    @State var selectedBranchType: String = "Temporary"

    //user input in branch panel, each time user types the state re-renders to show
    //every single chracter user inputed
    @State var branchMessage: String = ""

    //show the chats log
    @State var showChats = true

    //user can pick which chat to rename (stores the path as a string for nested chats)
    @State var renameChatPath: [Int]? = nil

    //new chat's name after renaming
    @State var newName: String = ""

    // Track which chats are expanded (using Set of path strings for comparison)
    @State var expandedChatPaths: Set<String> = []

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
        //auto-save to disk whenever chats change (messages, renames, deletes, etc.)
        .onChange(of: chats) {
            ChatStore.save(chats)
        }
    }

    // Helper function to get the current chat based on selectedChatPath
    func getCurrentChat() -> Chat {
        var currentChat = chats[selectedChatPath[0]]
        for i in 1..<selectedChatPath.count {
            currentChat = currentChat.branchedChats[selectedChatPath[i]]
        }
        return currentChat
    }

    // Same as getCurrentChat(), but for an arbitrary path snapshot
    func getChat(at path: [Int]) -> Chat {
        var currentChat = chats[path[0]]
        if path.count > 1 {
            for i in 1..<path.count {
                currentChat = currentChat.branchedChats[path[i]]
            }
        }
        return currentChat
    }

    // Save branch as permanent chat (recursive helper)
    func addBranchToChat(parentChatId: UUID, messageId: UUID, branchName: String, in chats: inout [Chat]) -> Bool {
        for i in 0..<chats.count {
            if chats[i].id == parentChatId {
                let newBranch = Chat(
                    name: branchName,
                    messages: branchMessages,
                    inheritedContext: branchContextMessages,
                    branchedChats: [],
                    isBranched: true,
                    parentChatId: parentChatId,
                    branchFromMessageId: messageId
                )
                chats[i].branchedChats.append(newBranch)
                return true
            }
            if addBranchToChat(parentChatId: parentChatId, messageId: messageId, branchName: branchName, in: &chats[i].branchedChats) {
                return true
            }
        }
        return false
    }

    // Save branch as permanent chat
    func saveBranchAsPermanent() {
        guard let parentChatId = branchFromChatId,
              let messageId = branchFromMessageId,
              !branchMessages.isEmpty else {
            return
        }

        let parentChat = findChatById(parentChatId, in: chats)
        let branchName = "Branch from \(parentChat?.name ?? "Chat")"

        // Try to add to top-level chats first
        if let parentIndex = chats.firstIndex(where: { $0.id == parentChatId }) {
            let newBranch = Chat(
                name: branchName,
                messages: branchMessages,
                inheritedContext: branchContextMessages,
                branchedChats: [],
                isBranched: true,
                parentChatId: parentChatId,
                branchFromMessageId: messageId
            )
            chats[parentIndex].branchedChats.append(newBranch)
        } else {
            // Recursively search in branched chats
            _ = addBranchToChat(parentChatId: parentChatId, messageId: messageId, branchName: branchName, in: &chats)
        }
    }

    // Helper function to find a chat by ID (recursive)
    func findChatById(_ id: UUID, in chats: [Chat]) -> Chat? {
        for chat in chats {
            if chat.id == id {
                return chat
            }
            if let found = findChatById(id, in: chat.branchedChats) {
                return found
            }
        }
        return nil
    }

    // Handle closing branch panel
    func closeBranchPanel() {
        if selectedBranchType == "Permanent" && !branchMessages.isEmpty {
            saveBranchAsPermanent()
        }
        // For temporary, just clear the messages (they're already not saved)
        branchMessages = []
        branchContextMessages = []
        branchFromMessageId = nil
        branchFromChatId = nil
        showBranch = false
    }

    // Update messages in nested chat
    func updateChatMessages(path: [Int], message: ChatMessage) {
        if path.count == 1 {
            chats[path[0]].messages.append(message)
        } else if path.count == 2 {
            chats[path[0]].branchedChats[path[1]].messages.append(message)
        } else if path.count == 3 {
            chats[path[0]].branchedChats[path[1]].branchedChats[path[2]].messages.append(message)
        } else {
            // For deeper nesting, use recursive helper
            updateChatMessagesRecursive(path: path, message: message, in: &chats)
        }
    }

    // Recursive helper to update messages in nested chat
    func updateChatMessagesRecursive(path: [Int], message: ChatMessage, in chats: inout [Chat]) {
        if path.count == 1 {
            chats[path[0]].messages.append(message)
        } else {
            var updatedBranched = chats[path[0]].branchedChats
            updateChatMessagesRecursive(path: Array(path[1...]), message: message, in: &updatedBranched)
            chats[path[0]].branchedChats = updatedBranched
        }
    }

    // MARK: - Delete chats (top-level + branched)

    func pathKey(for path: [Int]) -> String {
        path.map(String.init).joined(separator: ",")
    }

    func isPrefixPath(_ prefix: [Int], of path: [Int]) -> Bool {
        guard prefix.count <= path.count else { return false }
        return zip(prefix, path).allSatisfy { $0 == $1 }
    }

    func isValidPath(_ path: [Int]) -> Bool {
        guard !path.isEmpty else { return false }
        guard chats.indices.contains(path[0]) else { return false }

        var current = chats[path[0]]
        if path.count == 1 { return true }

        for i in 1..<path.count {
            let idx = path[i]
            guard current.branchedChats.indices.contains(idx) else { return false }
            current = current.branchedChats[idx]
        }
        return true
    }

    func deleteChat(at path: [Int]) {
        guard !path.isEmpty else { return }

        // Delete from data model
        if path.count == 1 {
            guard chats.indices.contains(path[0]) else { return }
            chats.remove(at: path[0])
        } else {
            deleteNestedChat(path: path, in: &chats)
        }

        // Clean up UI state that references deleted subtree
        let deletedKey = pathKey(for: path)
        expandedChatPaths = expandedChatPaths.filter { key in
            key != deletedKey && !key.hasPrefix(deletedKey + ",")
        }

        if let renamePath = renameChatPath, isPrefixPath(path, of: renamePath) {
            renameChatPath = nil
        }

        if isPrefixPath(path, of: selectedChatPath) {
            // If we deleted the selected chat (or its ancestor), move selection to parent
            var fallback = Array(path.dropLast())
            while !fallback.isEmpty && !isValidPath(fallback) {
                fallback = Array(fallback.dropLast())
            }
            if fallback.isEmpty {
                if chats.isEmpty {
                    chats.append(Chat(name: "New Chat", messages: [], branchedChats: []))
                    selectedChatPath = [0]
                } else {
                    selectedChatPath = [min(path[0], chats.count - 1)]
                }
            } else {
                selectedChatPath = fallback
            }
        } else if !isValidPath(selectedChatPath) {
            // Generic safety net
            if chats.isEmpty {
                chats.append(Chat(name: "New Chat", messages: [], branchedChats: []))
                selectedChatPath = [0]
            } else {
                selectedChatPath = [0]
            }
        }

        // Keep legacy index in sync
        selectedChatIndex = selectedChatPath.first ?? 0
    }

    func deleteNestedChat(path: [Int], in chats: inout [Chat]) {
        guard let first = path.first, chats.indices.contains(first) else { return }
        if path.count == 2 {
            let childIdx = path[1]
            guard chats[first].branchedChats.indices.contains(childIdx) else { return }
            chats[first].branchedChats.remove(at: childIdx)
            return
        }

        var updatedChildren = chats[first].branchedChats
        deleteNestedChat(path: Array(path.dropFirst()), in: &updatedChildren)
        chats[first].branchedChats = updatedChildren
    }
}

// tells xcode to show a live demo
#Preview {
    ContentView()
    .frame(width: 1000, height: 700)
    .previewLayout(.fixed(width: 1000, height: 700))
}
