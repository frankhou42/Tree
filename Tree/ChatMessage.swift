//
//  ChatMessage.swift
//  Tree
//
//  Model for a single chat message
//  isUser: true = user sent (right-aligned, no branch button)
//  isUser: false = AI response (left-aligned, branchable)
//

import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let isUser: Bool

    init(text: String, isUser: Bool) {
        self.id = UUID()
        self.text = text
        self.isUser = isUser
    }
}
