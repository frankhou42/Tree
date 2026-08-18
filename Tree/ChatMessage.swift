//
//  ChatMessage.swift
//  Tree
//
//  Model for a single chat message.
//  isUser: true = user sent (right-aligned, no branch button)
//  isUser: false = AI response (left-aligned, branchable)
//
//  `text` is mutable so streamed tokens can be appended in place while the
//  local model generates, and `isStreaming` drives a live typing indicator.
//

import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    let isUser: Bool
    var isStreaming: Bool

    init(id: UUID = UUID(), text: String, isUser: Bool, isStreaming: Bool = false) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.isStreaming = isStreaming
    }

    private enum CodingKeys: String, CodingKey {
        case id, text, isUser, isStreaming
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        text = try values.decode(String.self, forKey: .text)
        isUser = try values.decode(Bool.self, forKey: .isUser)
        isStreaming = try values.decodeIfPresent(Bool.self, forKey: .isStreaming) ?? false
    }
}
