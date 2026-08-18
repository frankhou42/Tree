//
//  LLMService.swift
//  Tree
//
//  Minimal client for a local open-source LLM via Ollama.
//  Requires: Ollama running on http://localhost:11434
//

import Foundation

// Typed client for the local Ollama chat API.
struct OllamaClient {
    // Ollama listens on localhost by default.
    var baseURL: URL = URL(string: "http://localhost:11434")!
    var session: URLSession = .shared

    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    enum Role: String, Codable {
        case system, user, assistant
    }

    enum OllamaError: LocalizedError {
        case httpStatus(Int, responseBody: String?)

        var errorDescription: String? {
            switch self {
            case let .httpStatus(code, body):
                var message = "Ollama request failed (status \(code)). Is Ollama running?"
                if let body, !body.isEmpty { message += "\n\(body)" }
                return message
            }
        }
    }

    struct Message: Codable {
        let role: Role
        let content: String
    }

    struct ChatRequest: Codable {
        let model: String
        let messages: [Message]
        let stream: Bool
    }

    struct ChatResponse: Codable {
        struct ResponseMessage: Codable {
            let role: String
            let content: String
        }
        let message: ResponseMessage
    }

    // Send the complete active context and return one assistant response.
    func chat(model: String, messages: [Message]) async throws -> String {
        let response: ChatResponse = try await postJSON(
            path: "api/chat",
            body: ChatRequest(model: model, messages: messages, stream: false)
        )
        return response.message.content
    }

    // Encode a request body and decode a typed response.
    private func postJSON<Body: Encodable, Response: Decodable>(
        path: String,
        body: Body
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try Self.encoder.encode(body)

        let (data, response) = try await session.data(for: request)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw OllamaError.httpStatus(http.statusCode, responseBody: String(data: data, encoding: .utf8))
        }

        return try Self.decoder.decode(Response.self, from: data)
    }
}
