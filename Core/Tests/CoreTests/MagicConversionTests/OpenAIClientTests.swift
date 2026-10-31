@testable import Core
import Foundation
import Testing

@Test func testRequestIncludesStructuredOutputByDefault() {
    let request = OpenAIRequest(prompt: "文脈", target: "りんご", modelName: "test-model")
    let body = request.toJSON()

    #expect(body["model"] as? String == "test-model")
    #expect(body["response_format"] != nil)
}

@Test func testRequestCanOmitStructuredOutputForCompatibleEndpoints() throws {
    let request = OpenAIRequest(prompt: "文脈", target: "りんご", modelName: "test-model")
    let body = request.toJSON(includeResponseFormat: false)

    #expect(body["response_format"] == nil)
    let messages = try #require(body["messages"] as? [[String: String]])
    let userMessage = try #require(messages.last?["content"])
    #expect(userMessage.contains("{\"predictions\""))
}

@Test func testPredictionParsingAcceptsPlainJSON() {
    let predictions = OpenAIClient.parsePredictions(from: #"{"predictions": ["赤い", "甘い"]}"#)
    #expect(predictions == ["赤い", "甘い"])
}

@Test func testPredictionParsingAcceptsMarkdownFence() {
    let content = """
    ```json
    {"predictions": ["赤い", "甘い"]}
    ```
    """
    #expect(OpenAIClient.parsePredictions(from: content) == ["赤い", "甘い"])
}

@Test func testPredictionParsingFallsBackToLines() {
    let content = """
    - 赤い
    - 甘い
    Productive
    """
    #expect(OpenAIClient.parsePredictions(from: content) == ["赤い", "甘い", "Productive"])
}

@Test func testTextTransformParsingAcceptsJSONAndPlainText() {
    #expect(OpenAIClient.parseTextTransformContent(#"{"result": "変換後"}"#) == "変換後")
    #expect(OpenAIClient.parseTextTransformContent("変換後") == "変換後")
}
