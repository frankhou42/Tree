//
//  Chat.swift
//  Tree
//
//  A single conversation. Each chat owns its own message history.
//

import Foundation //frame work that has basic types and utilities

struct Chat: Identifiable {
    //Privides an ID for any Chat instances
    let id = UUID()
    //name of the chat
    var name: String
    //messages stored in chat
    var messages: [ChatMessage]
}
