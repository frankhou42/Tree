//
//  ChatSidebar.swift
//  Tree
//
//  Refactored from ContentView.swift
//

import SwiftUI
import AppKit

extension ContentView {

    var chatSidebar : some View {
        HStack {
            VStack {
                chatHeader
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        //looping through indices in arr
                        ForEach(chats.indices, id: \.self) { index in
                            chatRowView(chat: chats[index], path: [index], depth: 0)
                        }
                    }
                }
                .scrollIndicators(.never) //fully hide scrollbar on sidebar
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
                let newChat = Chat(name: "New Chat", messages: [])
                chats.append(newChat)
                selectedChatIndex = chats.count - 1 //length of chat arr - 1
                selectedChatPath = [selectedChatIndex]
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

    // Recursive view to display chats and their branched chats using path
    //a function that renders one chat node and then calls itself to render each expanded child node, passing updated path and depth to preserve identity and indentation.
    func chatRowView(chat: Chat, path: [Int], depth: Int) -> AnyView {
        let isSelected = selectedChatPath == path
        let isRenaming = renameChatPath == path
        let pathKey = path.map { String($0) }.joined(separator: ",")
        let hasBranches = !chat.branchedChats.isEmpty
        let isExpanded = expandedChatPaths.contains(pathKey)

        return AnyView(
            VStack(alignment: .leading, spacing: 4) {
                if isRenaming {
                    TextField("Chat name", text: $newName, onCommit: {
                        if path.count == 1 {
                            chats[path[0]].name = newName.isEmpty ? chats[path[0]].name : newName
                        } else {
                            // Update nested chat name
                            updateNestedChatName(path: path, newName: newName.isEmpty ? chat.name : newName)
                        }
                        renameChatPath = nil
                    })
                    .textFieldStyle(.plain)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 6)
                    .padding(.leading, CGFloat(depth * 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                } else {
                    HStack(spacing: 4) {
                        // Expand/collapse button for chats with branches
                        if hasBranches {
                            Button(action: {
                                if isExpanded {
                                    expandedChatPaths.remove(pathKey)
                                } else {
                                    expandedChatPaths.insert(pathKey)
                                }
                            }) {
                                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                    .frame(width: 12)
                            }
                            .buttonStyle(.plain)
                        }

                        HStack(spacing: 8) {
                            // Indentation for nested chats
                            if depth > 0 {
                                Image(systemName: "arrow.turn.down.right")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                    .frame(width: 12)
                            }
                            Text(chat.name)
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(isSelected ? Color.blue.opacity(0.3) : Color.clear)
                        .cornerRadius(6)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedChatPath = path
                            selectedChatIndex = path[0]
                        }
                        .highPriorityGesture(
                            TapGesture(count: 2)
                                .onEnded {
                                    renameChatPath = path
                                    newName = chat.name
                                }
                        )
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteChat(at: path)
                            } label: {
                                Text("Delete")
                            }
                        }
                    }
                    .padding(.leading, CGFloat(depth * 16))
                }

                // Recursively display branched chats (only if expanded)
                if hasBranches && isExpanded {
                    ForEach(chat.branchedChats.indices, id: \.self) { branchIndex in
                        chatRowView(chat: chat.branchedChats[branchIndex], path: path + [branchIndex], depth: depth + 1)
                    }
                }
            }
        )
    }

    // Helper to update chat name in nested structure
    func updateNestedChatName(path: [Int], newName: String) {
        if path.count == 2 {
            chats[path[0]].branchedChats[path[1]].name = newName
        } else if path.count == 3 {
            chats[path[0]].branchedChats[path[1]].branchedChats[path[2]].name = newName
        } else if path.count == 4 {
            chats[path[0]].branchedChats[path[1]].branchedChats[path[2]].branchedChats[path[3]].name = newName
        } else {
            // For deeper nesting, use a helper function to update recursively
            updateNestedChatNameRecursive(path: path, newName: newName, in: &chats)
        }
    }

    // Recursive helper to update nested chat name
    func updateNestedChatNameRecursive(path: [Int], newName: String, in chats: inout [Chat]) {
        if path.count == 1 {
            chats[path[0]].name = newName
        } else {
            var updatedBranched = chats[path[0]].branchedChats
            updateNestedChatNameRecursive(path: Array(path[1...]), newName: newName, in: &updatedBranched)
            chats[path[0]].branchedChats = updatedBranched
        }
    }
}
