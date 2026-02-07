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
}
