//
//  API Caller.swift
//  Art feedback provider v4
//
//  Created by Satvi Mahesh on 3/19/25.
//
// This is the Claude Caller

import Foundation
import SwiftAnthropic
import SwiftUICore
import UIKit
import SwiftUI

// Function to convert a given image to Base64 Encoded String by converting it to a JPEG first as Claude accepts only JPEG.
// If JPEG converted chars are over 20M Chars Claude will reject then lower the Compression Quality say 0.4
func convertImageToBase64(image: UIImage, quality: CGFloat = 0.7) -> String? {
    guard let jpegData = image.jpegData(compressionQuality: quality) else { return nil }
    return jpegData.base64EncodedString()
}

func streamToString(_ stream: AsyncThrowingStream<MessageStreamResponse, Error>) async throws -> String {
    var result = ""
    for try await chunk in stream {
        if let content = chunk.delta?.text {
            result += content
        }
    }
    return result
}

func sendImageToClaude(prompt: String, media: UIImage) async throws -> String {
    let apiKey = "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"
    
    let betaHeaders = ["tools-2024-04-04"]
    let service = AnthropicServiceFactory.service(apiKey: apiKey, betaHeaders: betaHeaders)

    let maxTokens = 1024
    
    let base64Image = convertImageToBase64(image: media)
 
//    print("Base64 image size: \(base64Image!.count) characters\n")
//    print(base64Image!)
    
    let imageObject = MessageParameter.Message.Content.ContentObject.image(.init(type: .base64, mediaType: .jpeg, data: base64Image!))
    
    let textObject = MessageParameter.Message.Content.ContentObject.text(prompt)
    
    var message : String = ""
    
    let content = MessageParameter.Message.Content.list([imageObject, textObject])

    let userMessage = MessageParameter.Message(role: .user, content: content)
    
    // Use Claude35Sonnet is the latest model that this Claude API supports as Claude3Sonnet is using 2024 API which is erroring out
    let parameters = MessageParameter(model: .claude35Sonnet, messages: [userMessage], maxTokens: maxTokens)

    do {
     //  print(parameters)
        let stream = try await service.streamMessage(parameters)
        message = try await streamToString(stream)
    } catch {
        print("Full error: \(error)")
        message = "Error Message: \(error.localizedDescription)"
        
    }
    
    return message
    
}





