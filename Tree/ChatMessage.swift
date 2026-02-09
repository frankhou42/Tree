//
//  ChatMessage.swift
//  Tree
//
//  Model for a single chat message
//  isUser: true = user sent (right-aligned, no branch button)
//  isUser: false = AI response (left-aligned, branchable)
//

import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}
