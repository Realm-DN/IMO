//
//  MediaPickerDR.swift
//

import UIKit
import PhotosUI

class MediaPickerControllerDR: NSObject,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    static let shared = MediaPickerControllerDR()
    var viewController = UIViewController()
    
    private override init() {
        super.init()
    }
    func configureMediaSelection(from vc: UIViewController,selectionType: SelectionTypeDR, filterType: FilterTypeDR, completion: @escaping (Bool,FileModelDR?) -> Void) {
        self.viewController = vc
        switch filterType {
        case .none:
            debugPrint("none")
        case .camera:
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.presentImagePicker(sourceType: .camera, mediaType: "public.image")
            } else {
                debugPrint("Camera is not available.")
                completion(false, nil)
            }
        case .video:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.presentImagePicker(sourceType: .camera, mediaType: "public.movie")
            } else {
                debugPrint("Camera is not available.")
                completion(false, nil)
            }
        case .galleryPhoto,.galleryVideo:
            
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = selectionType == .single ? 1 : 10
            
            if case .galleryPhoto = filterType {
                configuration.filter = .images
            } else {
                configuration.filter = .videos
            }
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            viewController.present(picker, animated: true)
        case .docType(let docType):
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.requestMicrophonePermission { granted in
                    if granted {
                        let pickerController = UIDocumentPickerViewController(forOpeningContentTypes: [docType])
                        pickerController.delegate = self
                        pickerController.allowsMultipleSelection = selectionType == .single ? false : true
                        pickerController.modalPresentationStyle = .fullScreen
                        self.viewController.present(pickerController, animated: true, completion: nil)
                    } else {
                        debugPrint("Microphone access is required to select audio files.")
                    }
                }
            }
        }
        self.mediaCompletion = completion
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType, mediaType: String) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = [mediaType]
        picker.delegate = self
        viewController.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[.mediaType] as? String else { return }
        
        let dispatchGroup = DispatchGroup()
        var selectedData = [Data]()
        var selectedURLs = [URL]()
        var attachmentTypes = [AttachmentType]()
        
        switch mediaType {
        case "public.image":
            if let image = info[.originalImage] as? UIImage {
                dispatchGroup.enter()
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    selectedData.append(imageData)
                }
                if let imageURL = saveImageToTemporaryFile(image: image) {
                    selectedURLs.append(imageURL)
                    attachmentTypes.append(AttachmentType(fileExtension: imageURL.pathExtension))
                }
                dispatchGroup.leave()
            }
        case "public.movie":
            if let videoURL = info[.mediaURL] as? URL {
                dispatchGroup.enter()
                if let videoData = try? Data(contentsOf: videoURL) {
                    selectedData.append(videoData)
                    selectedURLs.append(videoURL)
                    attachmentTypes.append(AttachmentType(fileExtension: videoURL.pathExtension))
                }
                dispatchGroup.leave()
            }
        default:
            break
        }
        
        dispatchGroup.notify(queue: .main) {
            let fileModel = FileModelDR(fileData: selectedData, fileURL: selectedURLs, attachmentType: attachmentTypes)
            debugPrint("FileModel: \(fileModel)")
            picker.dismiss(animated: true)
            self.mediaCompletion?(true, fileModel)
        }
    }
    
    func saveImageToTemporaryFile(image: UIImage) -> URL? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        
        do {
            let fileURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("jpg")
            
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            debugPrint("Error saving image to temporary file:", error)
            return nil
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    private var mediaCompletion: ((Bool,FileModelDR?) -> Void)?
}

extension MediaPickerControllerDR: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else {
            mediaCompletion?(false, nil)
            return
        }
        let dispatchGroup = DispatchGroup()
        var selectedData = [Data]()
        var selectedURLs = [URL]()
        var attachmentTypes = [AttachmentType]()
        
        for result in results {
            dispatchGroup.enter()
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.data.identifier) { url, error in
                defer { dispatchGroup.leave() }
                if let error = error {
                    debugPrint("Error loading file representation: \(error.localizedDescription)")
                } else if let url = url, let data = try? Data(contentsOf: url) {
                    selectedData.append(data)
                    selectedURLs.append(url)
                    attachmentTypes.append(AttachmentType(fileExtension: url.pathExtension))
                } else {
                    debugPrint("Error converting file to Data")
                }
            }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            let fileModel = FileModelDR(fileData: selectedData, fileURL: selectedURLs, attachmentType: attachmentTypes)
            debugPrint("fileModel: \(fileModel)")
            self?.mediaCompletion?(true, fileModel)
        }
    }
}

extension MediaPickerControllerDR: UIDocumentPickerDelegate {
    
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized: completion(true)
        case .denied, .restricted: completion(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        @unknown default:
            print("Unknown case detected for AVAuthorizationStatus.")
            completion(false)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.mediaCompletion?(false, nil)
        debugPrint("Document picker was cancelled.")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var selectedData = [Data]()
        var selectedURLs = [URL]()
        var attachmentTypes = [AttachmentType]()
        let dispatchGroup = DispatchGroup()
        
        for url in urls {
            dispatchGroup.enter()
            guard url.startAccessingSecurityScopedResource() else { continue }
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                let fileData = try Data(contentsOf: url)
                selectedData.append(fileData)
                selectedURLs.append(url)
                attachmentTypes.append(AttachmentType(fileExtension: url.pathExtension))
            } catch {
                debugPrint(error)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            let fileModelCM = FileModelDR(fileData: selectedData, fileURL: selectedURLs, attachmentType: attachmentTypes)
            self.mediaCompletion?(true, fileModelCM)
        }
    }
}

enum MediaOptionDR {
    case location
    case photo
    case video
    case audio
    case galleryPhoto
    case galleryVideo
    
    var title: String {
        switch self {
        case .location: return "Send Location"
        case .photo: return "Take Photo"
        case .video: return "Record Video"
        case .audio: return "Choose from Library (Audio)"
        case .galleryPhoto: return "Choose from Library (Photo)"
        case .galleryVideo: return "Choose from Library (Video)"
        }
    }
    
    var selectionType: SelectionTypeDR {
        switch self {
        case .location, .photo, .video, .audio: return .single
        case .galleryPhoto, .galleryVideo: return .multiple
        }
    }
    
    var filterType: FilterTypeDR {
        switch self {
        case .location: return .none
        case .photo: return .camera
        case .video: return .video
        case .audio: return .docType(.audio)
        case .galleryPhoto: return .galleryPhoto
        case .galleryVideo: return .galleryVideo
        }
    }
    
    var sendType: MediaTypeDR {
        switch self {
        case .photo, .galleryPhoto: return .image
        case .video, .galleryVideo: return .video
        case .audio: return .audio
        case .location: return .location
        }
    }
}

struct FileModelDR{
    let fileData : [Data]
    let fileURL : [URL]
    let attachmentType : [AttachmentType]
}

enum SelectionTypeDR {
    case single
    case multiple
}

enum MediaTypeDR: String {
    case text = "text"
    case image = "image"
    case file = "file"
    case video = "video"
    case audio = "audio"
    case location = "location"
}

enum FilterTypeDR {
    case none
    case camera
    case video
    case galleryPhoto
    case galleryVideo
    case docType(UTType)
}
