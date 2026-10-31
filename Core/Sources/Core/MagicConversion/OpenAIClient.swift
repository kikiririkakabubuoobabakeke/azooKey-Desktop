import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct Prompt {
    static let dictionary: [String: String] = [
        // 文章補完プロンプト（デフォルト）
        "": """
        Generate 3-5 natural sentence completions for the given fragment.
        Return them as a simple array of strings.

        Example:
        Input: "りんごは"
        Output: ["赤いです。", "甘いです。", "美味しいです。", "1個200円です。", "果物です。"]
        """,

        // 絵文字変換プロンプト
        "えもじ": """
        Generate 3-5 emoji options that best represent the meaning of the text.
        Return them as a simple array of strings.

        Example:
        Input: "嬉しいです<えもじ>"
        Output: ["😊", "🥰", "😄", "💖", "✨"]
        """,

        // 顔文字変換プロンプト
        "かおもじ": """
        Generate 3-5 kaomoji (Japanese emoticon) options that best express the emotion or meaning of the text.
        Return them as a simple array of strings.

        Example:
        Input: "嬉しいです<かおもじ>"
        Output: ["(≧▽≦)", "(^_^)", "(o^▽^o)", "(｡♥‿♥｡)"]
        """,

        // 記号変換プロンプト
        "きごう": """
        Propose 3-5 symbol options to represent the given context.
        Return them as a simple array of strings.

        Example:
        Input: "総和<きごう>"
        Output: ["Σ", "+", "⊕"]
        """,

        // 類義語変換プロンプト
        "るいぎご": """
        Generate 3-5 synonymous word options for the given text.
        Return them as a simple array of Japanese strings.

        Example:
        Input: "楽しい<るいぎご>"
        Output: ["愉快", "面白い", "嬉しい", "快活", "ワクワクする"]
        """,

        // 対義語変換プロンプト
        "たいぎご": """
        Generate 3-5 antonymous word options for the given text.
        Return them as a simple array of Japanese strings.

        Example:
        Input: "楽しい<たいぎご>"
        Output: ["悲しい", "つまらない", "不愉快", "退屈", "憂鬱"]
        """,

        // TeXコマンド変換プロンプト
        "てふ": """
        Generate 3-5 TeX command options for the given mathematical content.
        Return them as a simple array of strings.

        Example:
        Input: "二次方程式<てふ>"
        Output: ["$x^2$", "$\\alpha$", "$\\frac{1}{2}$"]

        Input: "積分<てふ>"
        Output: ["$\\int$", "$\\oint$", "$\\sum$"]

        Input: "平方根<てふ>"
        Output: ["$\\sqrt{x}$", "$\\sqrt[n]{x}$", "$x^{1/2}$"]
        """,

        // 説明プロンプト
        "せつめい": """
        Provide 3-5 explanation to represent the given context.
        Return them as a simple array of Japanese strings.
        """,

        // つづきプロンプト
        "つづき": """
        Generate 2-5 short continuation options for the given context.
        Return them as a simple array of strings.

        Example:
        Input: "吾輩は猫である。<つづき>"
        Output: ["名前はまだない。", "名前はまだ無い。"]

        Example:
        Input: "10個の飴を5人に配る場合を考えます。<つづき>"
        Output: ["一人あたり10÷5=2個の飴を貰えます。", "1人2個の飴を貰えます。", "計算してみましょう"]

        Example:
        Input: "<つづき>"
        Output: ["👍"]
        """
    ]

    static let sharedText = """
    Return 3-5 options as a simple array of strings, ordered from:
    - Most standard/common to more specific/creative
    - Most formal to more casual (where applicable)
    - Most direct to more nuanced interpretations
    """

    static let defaultPrompt = """
    If the text in <> is a language name (e.g., <えいご>, <ふらんすご>, <すぺいんご>, <ちゅうごくご>, <かんこくご>, etc.),
    translate the preceding text into that language with 3-5 different variations.
    Otherwise, generate 3-5 alternative expressions of the text in <> that maintain its core meaning, following the sentence preceding <>.
    considering:
    - Different word choices
    - Varying formality levels
    - Alternative phrases or expressions
    - Different rhetorical approaches
    Return results as a simple array of strings.

    Example:
    Input: "おはようございます。今日も<てんき>"
    Output: ["いい天気", "雨", "晴れ", "快晴" , "曇り"]

    Input: "先日は失礼しました。<ごめん>"
    Output: ["すいません。", "ごめんなさい", "申し訳ありません"]

    Input: "すぐに戻ります<まってて>"
    Output: ["ただいま戻ります", "少々お待ちください", "すぐ参ります", "まもなく戻ります", "しばらくお待ちを"]

    Input: "遅刻してすいません。<いいわけ>"
    Output: ["電車の遅延", "寝坊", "道に迷って"]

    Input: "こんにちは<ふらんすご>"
    Output: ["Bonjour", "Salut", "Bon après-midi", "Coucou", "Allô"]

    Input: "ありがとう<すぺいんご>"
    Output: ["Gracias", "Muchas gracias", "Te lo agradezco", "Mil gracias", "Gracias mil"]
    """

    public static func getPromptText(for target: String) -> String {
        let basePrompt = if let prompt = dictionary[target] {
            prompt
        } else if target.hasSuffix("えもじ") {
            """
            Generate 3-5 emoji options that best represent the meaning of "<\(target)>" in the context.
            Return them as a simple array of strings.
            Example:
            Input: "嬉しいです<はーとのえもじ>"
            Output: ["💖", "💕", "💓", "❤️", "💝"]
            Example:
            Input: "怒るよ<こわいえもじ>"
            Output: ["🔪", "👿", "👺", "💢", "😡"]
            """
        } else if target.hasSuffix("きごう") {
            """
            Generate 3-5 emoji options that best represent the meaning of "<\(target)>" in the context.
            Return them as a simple array of strings.
            Example:
            Input: "えー<びっくりきごう>"
            Output: ["！", "❗️", "❕"]
            Example:
            Input: "公式は<せきぶんきごう>"
            Output: ["∫", "∬", "∭", "∮"]
            """
        } else {
            defaultPrompt
        }
        return basePrompt + "\n\n" + sharedText
    }
}

// OpenAI APIに送信するリクエスト構造体。
//
// - properties:
//    - prompt: 変換対象の前のテキスト
//    - target: 変換対象のテキスト
//    - modelName: モデル名
//
// - methods:
//    - toJSON(): リクエストをOpenAI APIに適したJSON形式に変換する。
public struct OpenAIRequest {
    public init(prompt: String, target: String, modelName: String) {
        self.prompt = prompt
        self.target = target
        self.modelName = modelName
    }

    let prompt: String
    let target: String
    let modelName: String

    private static let jsonInstruction = """
    Return only a JSON object in the following format:
    {"predictions": ["candidate 1", "candidate 2", ...]}
    Do not include markdown code fences or any other text.
    """

    // リクエストをJSON形式に変換する関数
    func toJSON(includeResponseFormat: Bool = true) -> [String: Any] {
        var body: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "system", "content": "You are an assistant that predicts the continuation of short text."],
                ["role": "user", "content": """
                    \(Prompt.getPromptText(for: target))

                    `\(prompt)<\(target)>`
                    \(includeResponseFormat ? "" : Self.jsonInstruction)
                    """]
            ]
        ]
        if includeResponseFormat {
            body["response_format"] = [
                "type": "json_schema",
                "json_schema": [
                    "name": "prediction_response",
                    "strict": true,
                    "schema": [
                        "type": "object",
                        "properties": [
                            "predictions": [
                                "type": "array",
                                "items": [
                                    "type": "string"
                                ],
                                "description": "Array of prediction strings"
                            ]
                        ],
                        "required": ["predictions"],
                        "additionalProperties": false
                    ] as [String: Any]
                ] as [String: Any]
            ] as [String: Any]
        }
        return body
    }
}

public enum OpenAIError: LocalizedError, @unchecked Sendable {
    case invalidURL
    case noServerResponse
    case invalidResponseStatus(code: Int, body: String)
    case parseError(String)
    case invalidResponseStructure(Any)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not connect to OpenAI service. Please check your internet connection."
        case .noServerResponse:
            return "OpenAI service is not responding. Please try again later."
        case .invalidResponseStatus(let code, _):
            switch code {
            case 401:
                return "OpenAI API key is invalid. Please check your API key in preferences."
            case 403:
                return "Access denied by OpenAI. Please check your API key permissions."
            case 429:
                return "OpenAI rate limit exceeded. Please wait a moment and try again."
            case 500...599:
                return "OpenAI service is temporarily unavailable. Please try again later."
            default:
                return "OpenAI request failed. Please try again later."
            }
        case .parseError:
            return "Could not understand OpenAI response. Please try again."
        case .invalidResponseStructure:
            return "Received unexpected response from OpenAI. Please try again."
        }
    }
}

// OpenAI APIクライアント
public enum OpenAIClient {
    private static let openCodeSessionID = UUID().uuidString

    // APIリクエストを送信する静的メソッド
    public static func sendRequest(_ request: OpenAIRequest, apiKey: String, apiEndpoint: String, logger: ((String) -> Void)? = nil) async throws -> [String] {
        let includeResponseFormat = self.prefersStructuredOutput(for: apiEndpoint)
        do {
            return try await self.performRequest(
                request,
                apiKey: apiKey,
                apiEndpoint: apiEndpoint,
                includeResponseFormat: includeResponseFormat,
                logger: logger
            )
        } catch let error as OpenAIError {
            guard self.shouldRetryWithAlternateResponseFormat(error) else {
                throw error
            }
            logger?("Retrying with alternate response_format after error: \(error.localizedDescription)")
            return try await self.performRequest(
                request,
                apiKey: apiKey,
                apiEndpoint: apiEndpoint,
                includeResponseFormat: !includeResponseFormat,
                logger: logger
            )
        }
    }

    private static func performRequest(
        _ request: OpenAIRequest,
        apiKey: String,
        apiEndpoint: String,
        includeResponseFormat: Bool,
        logger: ((String) -> Void)?
    ) async throws -> [String] {
        let urlRequest = try self.makeURLRequest(
            body: request.toJSON(includeResponseFormat: includeResponseFormat),
            apiKey: apiKey,
            apiEndpoint: apiEndpoint
        )

        // 非同期でリクエストを送信
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        // レスポンスの検証
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.noServerResponse
        }

        guard httpResponse.statusCode == 200 else {
            let responseBody = String(bytes: data, encoding: .utf8) ?? "Body is not encoded in UTF-8"
            throw OpenAIError.invalidResponseStatus(code: httpResponse.statusCode, body: responseBody)
        }

        // レスポンスデータの解析
        return try self.parseResponseData(data, logger: logger)
    }

    private static func makeURLRequest(body: [String: Any], apiKey: String, apiEndpoint: String) throws -> URLRequest {
        guard let url = URL(string: apiEndpoint) else {
            throw OpenAIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("azooKeyMac/1.0 (macOS input method)", forHTTPHeaderField: "User-Agent")
        if url.host?.lowercased().hasSuffix("opencode.ai") == true {
            urlRequest.setValue(Self.openCodeSessionID, forHTTPHeaderField: "x-opencode-session")
        }
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        return urlRequest
    }

    private static func prefersStructuredOutput(for apiEndpoint: String) -> Bool {
        guard let host = URL(string: apiEndpoint)?.host?.lowercased() else {
            return true
        }
        // OpenCode Goはresponse_format非対応の場合があるため、JSON指示のみで試す
        return !host.hasSuffix("opencode.ai")
    }

    private static func shouldRetryWithAlternateResponseFormat(_ error: OpenAIError) -> Bool {
        switch error {
        case .invalidResponseStatus(let code, _):
            return code == 400 || code == 422
        case .parseError, .invalidResponseStructure:
            return true
        case .invalidURL, .noServerResponse:
            return false
        }
    }

    // レスポンスデータのパースを行う静的メソッド
    private static func parseResponseData(_ data: Data, logger: ((String) -> Void)? = nil) throws -> [String] {
        logger?("Received JSON response")

        let jsonObject: Any
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data)
        } catch {
            logger?("Failed to parse JSON response")
            throw OpenAIError.parseError("Failed to parse response")
        }

        guard let jsonDict = jsonObject as? [String: Any],
              let choices = jsonDict["choices"] as? [[String: Any]] else {
            throw OpenAIError.invalidResponseStructure(jsonObject)
        }

        var allPredictions: [String] = []
        var foundContent = false
        for choice in choices {
            guard let message = choice["message"] as? [String: Any] else {
                continue
            }
            for contentString in self.contentStrings(from: message) {
                foundContent = true
                logger?("Raw content string: \(contentString)")
                let predictions = self.parsePredictions(from: contentString)
                if predictions.isEmpty {
                    logger?("Failed to parse `content`: \(contentString)")
                }
                logger?("Parsed predictions: \(predictions)")
                allPredictions.append(contentsOf: predictions)
            }
        }

        guard !allPredictions.isEmpty else {
            if foundContent {
                throw OpenAIError.parseError("No predictions found in response")
            }
            throw OpenAIError.invalidResponseStructure(jsonObject)
        }
        return allPredictions
    }

    private static func contentStrings(from message: [String: Any]) -> [String] {
        if let content = message["content"] as? String {
            return [content]
        }
        if let parts = message["content"] as? [[String: Any]] {
            return parts.compactMap { $0["text"] as? String }
        }
        return []
    }

    static func parsePredictions(from rawContent: String) -> [String] {
        let content = self.stripMarkdownFence(rawContent)
        if let object = self.jsonObject(from: content), let predictions = self.predictions(fromJSON: object) {
            return predictions
        }
        if let start = content.firstIndex(where: { $0 == "{" || $0 == "[" }),
           let end = content.lastIndex(where: { $0 == "}" || $0 == "]" }),
           start < end,
           let object = self.jsonObject(from: String(content[start...end])),
           let predictions = self.predictions(fromJSON: object) {
            return predictions
        }

        // JSONとして解釈できない場合は行単位のテキストとして扱う
        var seen = Set<String>()
        let lines = content.components(separatedBy: .newlines)
            .compactMap { self.cleanFallbackLine($0) }
            .filter { line in
                !line.hasPrefix("```") && !line.hasPrefix("Predictions:")
            }
        let uniqueLines = lines.filter { seen.insert($0).inserted }
        return Array(uniqueLines.prefix(10))
    }

    private static func cleanFallbackLine(_ rawLine: String) -> String? {
        var line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !line.isEmpty else {
            return nil
        }
        if let range = line.range(of: #"^\s*(?:[-*・]|\d+[.)])\s+"#, options: .regularExpression) {
            line = String(line[range.upperBound...])
        }
        line = line.trimmingCharacters(in: CharacterSet(charactersIn: "\"'[] "))
        return line.isEmpty ? nil : line
    }

    private static func jsonObject(from string: String) -> Any? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data)
    }

    private static func predictions(fromJSON object: Any) -> [String]? {
        if let dictionary = object as? [String: Any] {
            if let predictions = dictionary["predictions"] as? [String] {
                return predictions
            }
            if let result = dictionary["result"] as? String {
                return [result]
            }
            if let data = dictionary["data"] as? [String] {
                return data
            }
        }
        if let array = object as? [String] {
            return array
        }
        return nil
    }

    private static func stripMarkdownFence(_ raw: String) -> String {
        var content = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard content.hasPrefix("```") else {
            return content
        }
        if let newline = content.firstIndex(of: "\n") {
            content = String(content[content.index(after: newline)...])
        }
        if let range = content.range(of: "```", options: .backwards) {
            content = String(content[..<range.lowerBound])
        }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Simple text transformation method for AI Transform feature
    public static func sendTextTransformRequest(prompt: String, modelName: String, apiKey: String, apiEndpoint: String) async throws -> String {
        let includeResponseFormat = self.prefersStructuredOutput(for: apiEndpoint)
        do {
            return try await self.performTextTransformRequest(
                prompt: prompt,
                modelName: modelName,
                apiKey: apiKey,
                apiEndpoint: apiEndpoint,
                includeResponseFormat: includeResponseFormat
            )
        } catch let error as OpenAIError {
            guard self.shouldRetryWithAlternateResponseFormat(error) else {
                throw error
            }
            return try await self.performTextTransformRequest(
                prompt: prompt,
                modelName: modelName,
                apiKey: apiKey,
                apiEndpoint: apiEndpoint,
                includeResponseFormat: !includeResponseFormat
            )
        }
    }

    private static func performTextTransformRequest(
        prompt: String,
        modelName: String,
        apiKey: String,
        apiEndpoint: String,
        includeResponseFormat: Bool
    ) async throws -> String {
        let body = self.textTransformBody(prompt: prompt, modelName: modelName, includeResponseFormat: includeResponseFormat)
        let request = try self.makeURLRequest(body: body, apiKey: apiKey, apiEndpoint: apiEndpoint)

        // Send async request
        let (data, response) = try await URLSession.shared.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.noServerResponse
        }

        guard httpResponse.statusCode == 200 else {
            let responseBody = String(bytes: data, encoding: .utf8) ?? "Body is not encoded in UTF-8"
            throw OpenAIError.invalidResponseStatus(code: httpResponse.statusCode, body: responseBody)
        }

        // Parse response data using similar approach as sendRequest
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        guard let jsonDict = jsonObject as? [String: Any],
              let choices = jsonDict["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any] else {
            throw OpenAIError.invalidResponseStructure(jsonObject)
        }
        for contentString in self.contentStrings(from: message) {
            if let result = self.parseTextTransformContent(contentString) {
                return result
            }
        }
        throw OpenAIError.parseError("Failed to parse text transform response")
    }

    private static func textTransformBody(prompt: String, modelName: String, includeResponseFormat: Bool) -> [String: Any] {
        let userPrompt = includeResponseFormat
            ? prompt
            : prompt + "\n\nReturn only the transformed text as a JSON object with a 'result' field. Do not include markdown code fences or any other text."
        var body: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that transforms text according to user instructions."],
                ["role": "user", "content": userPrompt]
            ]
        ]
        if includeResponseFormat {
            body["response_format"] = [
                "type": "json_schema",
                "json_schema": [
                    "name": "text_transform_response",
                    "strict": true,
                    "schema": [
                        "type": "object",
                        "properties": [
                            "result": [
                                "type": "string",
                                "description": "The transformed text"
                            ]
                        ],
                        "required": ["result"],
                        "additionalProperties": false
                    ] as [String: Any]
                ] as [String: Any]
            ] as [String: Any]
        }
        return body
    }

    static func parseTextTransformContent(_ rawContent: String) -> String? {
        let content = self.stripMarkdownFence(rawContent)
        if let object = self.jsonObject(from: content) {
            if let dictionary = object as? [String: Any], let result = dictionary["result"] as? String {
                return result.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if let string = object as? String {
                return string.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        if let start = content.firstIndex(of: "{"),
           let end = content.lastIndex(of: "}"),
           start < end,
           let object = self.jsonObject(from: String(content[start...end])),
           let dictionary = object as? [String: Any],
           let result = dictionary["result"] as? String {
            return result.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

private enum ErrorUnion: Error {
    case nullError
    case double(any Error, any Error)
}

private struct ChatRequest: Codable {
    var model: String = "gpt-4o-mini"
    var messages: [Message] = []
}

private struct Message: Codable {
    enum Role: String, Codable {
        case user
        case system
        case assistant
    }
    var role: Role
    var content: String
}

private struct ChatSuccessResponse: Codable {
    var id: String
    var object: String
    var created: Int
    var model: String
    var choices: [Choice]

    struct Choice: Codable {
        var index: Int
        var logprobs: Double?
        var finishReason: String
        var message: Message
    }

    struct Usage: Codable {
        var promptTokens: Int
        var completionTokens: Int
        var totalTokens: Int
    }
}

private struct ChatFailureResponse: Codable, Error {
    var error: ErrorResponse
    struct ErrorResponse: Codable {
        var message: String
        var type: String
    }
}
