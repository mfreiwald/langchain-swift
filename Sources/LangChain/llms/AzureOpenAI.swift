//
//  AzureOpenAILLM.swift
//  OpenAIPlayground
//
//  Created by Michael on 04.11.24.
//

import Foundation
import SwiftOpenAI

public class AzureOpenAI: LLM {
    let temperature: Double
    let model: Model
    let apiVersion: String

    public init(temperature: Double = 0.0, model: Model = Model.gpt4o, apiVersion: String = "", callbacks: [BaseCallbackHandler] = [], cache: BaseCache? = nil) {
        self.temperature = temperature
        self.model = model
        self.apiVersion = apiVersion
        super.init(callbacks: callbacks, cache: cache)
    }

    public override func _send(text: String, stops: [String] = []) async throws -> LLMResult {
        let env = LC.loadEnv()

        if let apiKey = env["AZURE_OPENAI_API_KEY"], let baseUrl = env["AZURE_OPENAI_API_BASE"] {
            let configuration = AzureOpenAIConfiguration(resourceName: baseUrl, openAIAPIKey: .apiKey(apiKey), apiVersion: apiVersion)

            let service = OpenAIServiceFactory.service(azureConfiguration: configuration)
            let completion = try await service.startChat(
                parameters: .init(
                    messages: [.init(role: .user, content: .text(text))],
                    model: model,
                    stop: stops,
                    temperature: temperature
                )
            )
            return LLMResult(llm_output: completion.choices.first!.message.content)
        } else {
            print("Please set azure openai api key.")
            return LLMResult(llm_output: "Please set azure openai api key.")
        }

    }
}
