//
//  AttachmentType+CM.swift
//

import Foundation

enum AttachmentCodingKeys: String, CodingKey, CaseIterable {
    case title
    case type
    case image
    case url
    case name
    case text
    case author = "author_name"
    case ogURL = "og_scrape_url"
    case thumbURL = "thumb_url"
    case fallback
    case imageURL = "image_url"
    case assetURL = "asset_url"
    case titleLink = "title_link"
    case originalWidth = "original_width"
    case originalHeight = "original_height"
}

public enum LocalAttachmentState: Hashable {
    case unknown
    case pendingUpload
    case uploading(progress: Double)
    case uploadingFailed
    case uploaded
}

public struct AttachmentAction: Codable, Hashable {
    
    public let name: String
    public let value: String
    public let style: ActionStyle
    public let type: ActionType
    public let text: String
    public init(
        name: String,
        value: String,
        style: ActionStyle,
        type: ActionType,
        text: String
    ) {
        self.name = name
        self.value = value
        self.style = style
        self.type = type
        self.text = text
    }
    
    
    public var isCancel: Bool { value.lowercased() == "cancel" }
    
    public enum ActionType: String, Codable {
        case button
    }
    
    public enum ActionStyle: String, Codable {
        case `default`
        case primary
    }
}

public struct AttachmentType: RawRepresentable, Codable, Hashable, ExpressibleByStringLiteral {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
    
    public init(fileExtension: String) {
        let attachmentFileType = AttachmentFileType(ext: fileExtension)
        let mainMimeType = attachmentFileType.mimeType.split(separator: "/").first
        switch mainMimeType {
        case "image":
            self = .image
        case "video":
            self = .video
        case "audio":
            self = .audio
        default:
            self = .file
        }
    }
}

public extension AttachmentType {
    static let pdf = Self(rawValue: "pdf")
    static let image = Self(rawValue: "image")
    static let file = Self(rawValue: "file")
    static let giphy = Self(rawValue: "giphy")
    static let video = Self(rawValue: "video")
    static let audio = Self(rawValue: "audio")
    static let voiceRecording = Self(rawValue: "voiceRecording")
    static let linkPreview = Self(rawValue: "linkPreview")
    static let unknown = Self(rawValue: "unknown")
}

public struct AttachmentFile: Codable, Hashable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        case mimeType = "mime_type"
        case size = "file_size"
    }
    
    
    public let type: AttachmentFileType
    public let size: Int64
    public let mimeType: String?
    public static let sizeFormatter = ByteCountFormatter()
    public var sizeString: String { AttachmentFile.sizeFormatter.string(fromByteCount: size) }
    public init(type: AttachmentFileType, size: Int64, mimeType: String?) {
        self.type = type
        self.size = size
        self.mimeType = mimeType
    }
    
    public init(url: URL) throws {
        guard url.isFileURL else {
            throw ClientError.InvalidAttachmentFileURL(url)
        }
        
        let fileType = AttachmentFileType(ext: url.pathExtension)
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        
        self.init(
            type: fileType,
            size: attributes?[.size] as? Int64 ?? 0,
            mimeType: fileType.mimeType
        )
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mimeType = try? container.decodeIfPresent(String.self, forKey: .mimeType)
        
        if let mimeType = mimeType {
            type = AttachmentFileType(mimeType: mimeType)
        } else {
            type = .generic
        }
        
        if let size = try? container.decodeIfPresent(Int64.self, forKey: .size) {
            self.size = size
        } else if let floatSize = try? container.decodeIfPresent(Float64.self, forKey: .size) {
            size = Int64(floatSize.rounded())
        } else {
            size = 0
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(size, forKey: .size)
        try container.encodeIfPresent(mimeType, forKey: .mimeType)
    }
}


public enum AttachmentFileType: String, Codable, Equatable, CaseIterable {
    
    case generic, doc, docx, pdf, ppt, pptx, tar, xls, zip, x7z, xz, ods, odt, xlsx
    case csv, rtf, txt
    case mp3, wav, ogg, m4a, aac, mp4
    case mov, avi, wmv, webm
    case jpeg, png, gif, bmp, webp
    case unknown
    
    private static let mimeTypes: [String: AttachmentFileType] = [
        "application/octet-stream": .generic,
        "application/msword": .doc,
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document": .docx,
        "application/pdf": .pdf,
        "application/vnd.ms-powerpoint": .ppt,
        "application/vnd.openxmlformats-officedocument.presentationml.presentation": .pptx,
        "application/x-tar": .tar,
        "application/vnd.ms-excel": .xls,
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": .xlsx,
        "application/zip": .zip,
        "application/x-7z-compressed": .x7z,
        "application/x-xz": .xz,
        "application/vnd.oasis.opendocument.spreadsheet": .ods,
        "application/vnd.oasis.opendocument.text": .odt,
        "text/csv": .csv,
        "text/rtf": .rtf,
        "text/plain": .txt,
        "audio/mp3": .mp3,
        "audio/mp4": .m4a,
        "audio/aac": .aac,
        "audio/wav": .wav,
        "audio/ogg": .ogg,
        "video/mp4": .mp4,
        "video/quicktime": .mov,
        "video/x-msvideo": .avi,
        "video/x-ms-wmv": .wmv,
        "video/webm": .webm,
        "image/jpeg": .jpeg,
        "image/jpg": .jpeg,
        "image/png": .png,
        "image/gif": .gif,
        "image/bmp": .bmp,
        "image/webp": .webp
    ]
    
    public init(mimeType: String) {
        self = AttachmentFileType.mimeTypes[mimeType, default: .generic]
    }
    
    public init(ext: String) {
        let ext = ext.lowercased()
        if ext == "jpg" {
            self = .jpeg
            return
        }
        if ext == "7z" {
            self = .x7z
            return
        }
        
        self = AttachmentFileType(rawValue: ext) ?? .generic
    }
    
    /// Returns a mime type for the file type.
    public var mimeType: String {
        if self == .jpeg {
            return "image/jpeg"
        }
        
        return AttachmentFileType.mimeTypes
            .first(where: { $1 == self })?
            .key ?? "application/octet-stream"
    }
    
    public var isAudio: Bool {
        switch self {
        case .mp3, .wav, .ogg, .m4a, .aac:
            return true
        default:
            return false
        }
    }
    
    public var isUnknown: Bool {
        self == .unknown
    }
}

extension ClientError {
    class InvalidAttachmentFileURL: ClientError {
        init(_ url: URL) {
            super.init("The \(url) is invalid since it is not a file URL.")
        }
    }
}

public class ClientError: Error, CustomStringConvertible {
    public struct Location: Equatable {
        public let file: String
        public let line: Int
    }
    
    /// The file and line number which emitted the error.
    public let location: Location?
    
    public let message: String?
    
    /// An underlying error.
    public let underlyingError: Error?
    
    var errorDescription: String? { underlyingError.map(String.init(describing:)) }
    
    /// Retrieve the localized description for this error.
    public var localizedDescription: String { message ?? errorDescription ?? "" }
    
    public private(set) lazy var description = "Error \(type(of: self)) in \(location?.file ?? ""):\(location?.line ?? 0)"
    + (localizedDescription.isEmpty ? "" : " -> ")
    + localizedDescription
    
    public init(with error: Error? = nil, _ file: StaticString = #file, _ line: UInt = #line) {
        message = nil
        underlyingError = error
        location = .init(file: "\(file)", line: Int(line))
    }
    public init(_ message: String, _ file: StaticString = #file, _ line: UInt = #line) {
        self.message = message
        location = .init(file: "\(file)", line: Int(line))
        underlyingError = nil
    }
}

extension ClientError {
    public class Unexpected: ClientError {}
    public class Unknown: ClientError {}
}

extension ClientError: Equatable {
    public static func == (lhs: ClientError, rhs: ClientError) -> Bool {
        type(of: lhs) == type(of: rhs)
        && String(describing: lhs.underlyingError) == String(describing: rhs.underlyingError)
        && String(describing: lhs.localizedDescription) == String(describing: rhs.localizedDescription)
    }
}

extension ClientError {
    var isExpiredTokenError: Bool {
        (underlyingError as? ErrorPayload)?.isExpiredTokenError == true
    }
    var isInvalidTokenError: Bool {
        (underlyingError as? ErrorPayload)?.isInvalidTokenError == true
    }
}

public struct ErrorPayload: LocalizedError, Codable, CustomDebugStringConvertible, Equatable {
    private enum CodingKeys: String, CodingKey {
        case code
        case message
        case statusCode = "StatusCode"
    }
    
    public let code: Int
    public let message: String
    public let statusCode: Int
    
    public var errorDescription: String? {
        "Error #\(code): \(message)"
    }
    
    public var debugDescription: String {
        "ServerErrorPayload(code: \(code), message: \"\(message)\", statusCode: \(statusCode)))."
    }
}

private enum StreamErrorCode {
    static let accessKeyInvalid = 2
    static let expiredToken = 40
    static let notYetValidToken = 41
    static let invalidTokenDate = 42
    static let invalidTokenSignature = 43
}

extension ErrorPayload {
    var isExpiredTokenError: Bool {
        code == StreamErrorCode.expiredToken
    }
    
    var isInvalidTokenError: Bool {
        ClosedRange.tokenInvalidErrorCodes ~= code || code == StreamErrorCode.accessKeyInvalid
    }
    
    var isClientError: Bool {
        ClosedRange.clientErrorCodes ~= statusCode
    }
}

extension ClosedRange where Bound == Int {
    static let tokenInvalidErrorCodes: Self = StreamErrorCode.expiredToken...StreamErrorCode.invalidTokenSignature
    static let clientErrorCodes: Self = 400...499
}

public struct ErrorPayloadDetail: LocalizedError, Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case code
        case messages
    }
    public let code: Int
    public let messages: [String]
}
