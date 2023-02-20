//
//  DocumentsService.swift
//  oa-wallet-ios
//
//  Created by Tan Cher Shen on 11/2/23.
//

import Foundation

struct GetUploadurlResponse: Codable {
    let filename: String
    let upload_url: String
}

struct GetDownloadurlRequestParams: Codable {
    let filename: String
    let expiry_in_seconds: Int
}

struct GetDownloadurlResponse: Codable {
    let download_url: String
}

enum DocumentsServiceError: Error {
    case uploadUrlNotDefined
    case uploadUrlInvalid
    case downloadUrlNotDefined
    case failedToUploadFile
    case failedToGetUploadUrl
    case failedToGetDownloadUrl
}

class DocumentsService {
    static func uploadDocument(data: Data, validityDuration: Int) async throws -> String {
        guard let uploadUrl = URL(string: Config.getuploadurlEndpoint) else {
            throw DocumentsServiceError.uploadUrlNotDefined
        }
        guard let downloadUrl = URL(string: Config.getdownloadurlEndpoint) else {
            throw DocumentsServiceError.downloadUrlNotDefined
        }
        
        // Get the S3 presigned upload url
        let (uploadurlResponseData, uploadurlResponse) = try await URLSession.shared.data(from: uploadUrl)
        if let uploadurlResponse = uploadurlResponse as? HTTPURLResponse {
            guard uploadurlResponse.statusCode == 200 else {
                throw DocumentsServiceError.failedToGetUploadUrl
            }
        }
        let getUploadurlResponse = try JSONDecoder().decode(GetUploadurlResponse.self, from: uploadurlResponseData)
        guard let uploadUrl = URL(string: getUploadurlResponse.upload_url) else {
            throw DocumentsServiceError.uploadUrlInvalid
        }
        
        // Upload the document to S3
        var uploadRequest = URLRequest(url: uploadUrl)
        uploadRequest.httpMethod = "PUT"
        uploadRequest.httpBody = data
        let (_, uploadDocumentResponse) = try await URLSession.shared.data(for: uploadRequest)
        if let uploadDocumentResponse = uploadDocumentResponse as? HTTPURLResponse {
            guard uploadDocumentResponse.statusCode == 200 else {
                throw DocumentsServiceError.failedToUploadFile
            }
        }
        
        // Get the S3 presigned download url for the document
        let downloadUrlParams = GetDownloadurlRequestParams(filename: getUploadurlResponse.filename, expiry_in_seconds: validityDuration)
        var getDownloadUrlRequest = URLRequest(url: downloadUrl)
        getDownloadUrlRequest.httpMethod = "POST"
        getDownloadUrlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonObj = try! JSONEncoder().encode(downloadUrlParams)
        getDownloadUrlRequest.httpBody = jsonObj
        let (downloadUrlResponseData, downloadUrlResponse) = try await URLSession.shared.data(for: getDownloadUrlRequest)
        if let downloadUrlResponse = downloadUrlResponse as? HTTPURLResponse {
            guard downloadUrlResponse.statusCode == 200 else {
                throw DocumentsServiceError.failedToGetDownloadUrl
            }
        }
        let downloadurlResponse = try JSONDecoder().decode(GetDownloadurlResponse.self, from: downloadUrlResponseData)
        
        return downloadurlResponse.download_url
    }
}
