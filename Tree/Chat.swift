//
//  Chat.swift
//  Tree
//
//  A single conversation. Each chat owns its own message history and any
//  saved ("Permanent") branches spun off from its AI responses.
//

import Foundation

// A recursively nestable conversation node with stable identity and provenance.
struct Chat: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var messages: [ChatMessage]
    // Read-only parent context inherited when this conversation was forked.
    var inheritedContext: [ChatMessage]
    var branchedChats: [Chat]
    var isBranched: Bool
    var parentChatId: UUID?
    var branchFromMessageId: UUID?

    init(
        name: String,
        messages: [ChatMessage] = [],
        inheritedContext: [ChatMessage] = [],
        branchedChats: [Chat] = [],
        isBranched: Bool = false,
        parentChatId: UUID? = nil,
        branchFromMessageId: UUID? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.messages = messages
        self.inheritedContext = inheritedContext
        self.branchedChats = branchedChats
        self.isBranched = isBranched
        self.parentChatId = parentChatId
        self.branchFromMessageId = branchFromMessageId
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, messages, inheritedContext, branchedChats, isBranched
        case parentChatId, branchFromMessageId
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try values.decode(String.self, forKey: .name)
        messages = try values.decodeIfPresent([ChatMessage].self, forKey: .messages) ?? []
        inheritedContext = try values.decodeIfPresent(
            [ChatMessage].self,
            forKey: .inheritedContext
        ) ?? []
        branchedChats = try values.decodeIfPresent([Chat].self, forKey: .branchedChats) ?? []
        isBranched = try values.decodeIfPresent(Bool.self, forKey: .isBranched) ?? false
        parentChatId = try values.decodeIfPresent(UUID.self, forKey: .parentChatId)
        branchFromMessageId = try values.decodeIfPresent(UUID.self, forKey: .branchFromMessageId)
    }

    var modelContext: [ChatMessage] {
        inheritedContext + messages
    }

    func contextPrefix(through messageId: UUID) -> [ChatMessage] {
        guard let index = messages.firstIndex(where: { $0.id == messageId }) else {
            return modelContext
        }
        return inheritedContext + Array(messages[...index])
    }
}

// MARK: - Minimal JSON persistence

enum ChatStore {
    private static var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Tree", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("chats.json")
    }

    static func load() -> [Chat]? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode([Chat].self, from: data)
    }

    static func save(_ chats: [Chat]) {
        guard let data = try? JSONEncoder().encode(chats) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
