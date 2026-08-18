import Foundation

@main
struct TreeModelChecks {
    static func main() throws {
        try branchContextStopsAtForkPoint()
        try nestedGraphRoundTripsThroughJSON()
        try legacyChatWithoutInheritedContextStillLoads()
        try legacyMessageWithoutStreamingStateStillLoads()
        print("Tree model checks passed")
    }

    private static func branchContextStopsAtForkPoint() throws {
        let inherited = ChatMessage(text: "parent question", isUser: true)
        let forkPoint = ChatMessage(text: "first answer", isUser: false)
        let laterTurn = ChatMessage(text: "later turn", isUser: true)
        let chat = Chat(
            name: "branch",
            messages: [forkPoint, laterTurn],
            inheritedContext: [inherited],
            isBranched: true
        )

        try require(
            chat.contextPrefix(through: forkPoint.id) == [inherited, forkPoint],
            "a branch must inherit only the context through its fork point"
        )
        try require(
            !chat.contextPrefix(through: forkPoint.id).contains(laterTurn),
            "a branch must exclude turns that occurred after its fork point"
        )
    }

    private static func nestedGraphRoundTripsThroughJSON() throws {
        let source = ChatMessage(text: "compare two designs", isUser: true)
        let child = Chat(
            name: "Alternative",
            messages: [ChatMessage(text: "explore the second design", isUser: true)],
            inheritedContext: [source],
            isBranched: true,
            parentChatId: UUID(),
            branchFromMessageId: source.id
        )
        let root = Chat(name: "Architecture", messages: [source], branchedChats: [child])

        let data = try JSONEncoder().encode(root)
        let restored = try JSONDecoder().decode(Chat.self, from: data)

        try require(restored == root, "a nested graph must survive a JSON round trip")
        try require(
            restored.branchedChats.first?.modelContext.count == 2,
            "a restored branch must retain inherited and branch-local context"
        )
    }

    private static func legacyChatWithoutInheritedContextStillLoads() throws {
        let legacy = """
        {
          "id": "00000000-0000-0000-0000-000000000001",
          "name": "Legacy",
          "messages": [],
          "branchedChats": [],
          "isBranched": false
        }
        """.data(using: .utf8)!

        let restored = try JSONDecoder().decode(Chat.self, from: legacy)
        try require(
            restored.inheritedContext.isEmpty,
            "legacy chats must default to an empty inherited context"
        )
    }

    private static func legacyMessageWithoutStreamingStateStillLoads() throws {
        let legacy = """
        {
          "id": "00000000-0000-0000-0000-000000000002",
          "text": "saved before token streaming",
          "isUser": false
        }
        """.data(using: .utf8)!

        let restored = try JSONDecoder().decode(ChatMessage.self, from: legacy)
        try require(
            !restored.isStreaming,
            "legacy messages must default to a completed streaming state"
        )
    }

    private static func require(_ condition: @autoclosure () -> Bool, _ message: String) throws {
        guard condition() else {
            throw CheckFailure(message: message)
        }
    }

    private struct CheckFailure: Error, CustomStringConvertible {
        let message: String
        var description: String { message }
    }
}
