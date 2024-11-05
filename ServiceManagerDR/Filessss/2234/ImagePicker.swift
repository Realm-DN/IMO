import UIKit
import AVFoundation
import Photos
import MobileCoreServices

// Protocol for image picker delegate
@objc public protocol ImagePickerDelegate: AnyObject {
    @objc func didSelect(image: UIImage?, mediaInfo: [UIImagePickerController.InfoKey: Any]?, tag: Int)
    @objc optional func didSelectVideo(picker: UIImagePickerController, didFinishPickingMediaWithInfo: [UIImagePickerController.InfoKey: Any], tag: Int)
    @objc optional func didSelectDocument(url: URL?, tag: Int)
}

// Enum for image picker source types
enum ImagePickerSourceEnum {
    case image, video, gallery
}

class ImagePicker: NSObject {

    // Properties
    private var pickerController = UIImagePickerController()
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    private var tag: Int?
    private var selectedFileType: ImagePickerSourceEnum?
    public var isPickerDismissedBlocked: ((Bool) -> Void)?
    public var allowEditing: Bool

    // Initializer
    public init(presentationController: UIViewController?, delegate: ImagePickerDelegate?, allowEditing: Bool = true) {
        self.presentationController = presentationController
        self.delegate = delegate
        self.allowEditing = allowEditing
        super.init()
        pickerController.delegate = self
        pickerController.allowsEditing = allowEditing
    }

    // Presents the action sheet for choosing between camera, gallery, and document picker
    public func present(tag: Int, cameraTitle: String? = nil, galleryTitle: String? = nil, videoTitle: String? = nil, documentTitle: String? = nil) {
        self.tag = tag
        let alertController = UIAlertController(title: "Select option", message: nil, preferredStyle: .actionSheet)

        let actions: [(title: String, type: UIImagePickerController.SourceType, mediaType: String, captureMode: UIImagePickerController.CameraCaptureMode)] = [
            (title: galleryTitle ?? "Photo library", type: .photoLibrary, mediaType: "public.image", captureMode: .photo),
            (title: cameraTitle ?? "Take photo", type: .camera, mediaType: "public.image", captureMode: .photo),
            (title: videoTitle ?? "Take video", type: .camera, mediaType: "public.movie", captureMode: .video)
        ]

        for action in actions {
            if UIImagePickerController.isSourceTypeAvailable(action.type) {
                alertController.addAction(UIAlertAction(title: action.title, style: .default) { _ in
                    self.selectedFileType = action.type == .camera && action.mediaType == "public.movie" ? .video : (action.mediaType == "public.image" ? .image : .gallery)
                    self.presentImagePicker(sourceType: action.type, mediaType: action.mediaType, captureMode: action.captureMode)
                })
            }
        }

        if let documentTitle = documentTitle {
            alertController.addAction(UIAlertAction(title: documentTitle, style: .default) { _ in
                self.presentDocumentPicker()
            })
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if UIDevice.current.userInterfaceIdiom == .pad {
            if let sourceView = getTopViewController()?.view {
                alertController.popoverPresentationController?.sourceView = sourceView
                alertController.popoverPresentationController?.sourceRect = sourceView.bounds
                alertController.popoverPresentationController?.permittedArrowDirections = []
            }
        }

        presentationController?.present(alertController, animated: true)
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType, mediaType: String, captureMode: UIImagePickerController.CameraCaptureMode) {
        if sourceType == .camera {
            checkCameraAccess { isAccess in
                if isAccess {
                    DispatchQueue.main.async {
                        self.pickerController.sourceType = sourceType
                        self.pickerController.mediaTypes = [mediaType]
                        self.pickerController.cameraCaptureMode = captureMode
                        self.presentationController?.present(self.pickerController, animated: true)
                    }
                } else {
                    self.presentAlertSettings(title: "Camera Access Denied", message: "You can enable access in Settings -> Privacy -> Camera.")
                }
            }
        } else if sourceType == .photoLibrary {
            checkPhotoLibraryPermission { isAccess in
                if isAccess {
                    DispatchQueue.main.async {
                        self.pickerController.sourceType = sourceType
                        self.presentationController?.present(self.pickerController, animated: true)
                    }
                } else {
                    self.presentAlertSettings(title: "Photo Library Access Denied", message: "You can enable access in Settings -> Privacy -> Photos.")
                }
            }
        }
    }

    private func checkCameraAccess(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in completion(success) }
        default:
            completion(false)
        }
    }

    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in completion(status == .authorized) }
        default:
            completion(false)
        }
    }

    private func presentAlertSettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
        })
        DispatchQueue.main.async {
            self.presentationController?.present(alertController, animated: true)
        }
    }

    private func getTopViewController() -> UIViewController? {
        var topController = UIApplication.shared.keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }

    private func presentDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.presentationController?.present(documentPicker, animated: true)
    }
}

// UIImagePickerControllerDelegate
extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.pickerController.removeFromParent()
            self.isPickerDismissedBlocked?(true)
        }
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            self.pickerController.removeFromParent()
            let image = (self.allowEditing ? info[.editedImage] : info[.originalImage]) as? UIImage
            if self.selectedFileType == .video {
                self.delegate?.didSelectVideo?(picker: picker, didFinishPickingMediaWithInfo: info, tag: self.tag ?? 0)
            } else {
                self.delegate?.didSelect(image: image, mediaInfo: info, tag: self.tag ?? 0)
            }
            self.isPickerDismissedBlocked?(true)
        }
    }
}

// UIDocumentPickerDelegate
extension ImagePicker: UIDocumentPickerDelegate {

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        self.delegate?.didSelectDocument?(url: url, tag: self.tag ?? 0)
        self.isPickerDismissedBlocked?(true)
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true) {
            self.isPickerDismissedBlocked?(true)
        }
    }
}

// Helper functions
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func imagePickerImageURL(info: [UIImagePickerController.InfoKey: Any]) -> URL? {
    let imageURL = info[.imageURL] as? URL
    let originalImage = info[.originalImage] as? UIImage

    if imageURL == nil {
        if let imageToSave = originalImage {
            let imageName = UUID().uuidString
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName).appendingPathExtension("jpeg")

            if let jpegData = imageToSave.jpegData(compressionQuality: 0.6) {
                try? jpegData.write(to: imagePath)

                guard info[.editedImage] is UIImage else {
                    return imagePath
                }

                return imagePath
            } else {
                return nil
            }
        } else {
            return nil
        }
    } else {
        guard info[.editedImage] is UIImage else {
            return imageURL
        }
        return imageURL
    }
}

import Kingfisher

extension UIImageView{
    func loadImage(with url: URL?, placeholder: UIImage?) {
        if let url = url {
            self.kf.indicatorType = .activity
            self.kf.setImage(with: url, placeholder: placeholder)
        } else {
            self.image = placeholder
        }
    }
}


