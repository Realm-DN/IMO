//
//  UIImageView+Extensions.swift
//

import UIKit
import Kingfisher
import Foundation
import AVFoundation

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

func assignImage(_ named: String) -> [UIImage] {
    return [UIImage(named: named)].compactMap { $0 }
}

extension UIImage{
    class func photoIcon() -> UIImage{
        return UIImage.init(named: "photo_icon") ?? UIImage()
    }
   
    class func placeHolderProfile() -> UIImage{
        return UIImage.init(named: "No_Image_Available") ?? UIImage()
    }
    
    class func billPlaceHolder() -> UIImage{
        return UIImage.init(named: "ic_receipt") ?? UIImage()
    }
    

    
    
}

func generateThumbnail(from url: URL, completion: @escaping (UIImage?) -> Void) {
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    // Set the time at which you want to capture the thumbnail (e.g., 1 second)
    let time = CMTime(seconds: 1, preferredTimescale: 600)
    
    // Generate the thumbnail
    imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, image, _, _, _ in
        guard let cgImage = image else {
            completion(nil)
            return
        }
        
        let thumbnail = UIImage(cgImage: cgImage)
        completion(thumbnail)
    }
}

func extractArtwork(from audioURL: URL) -> UIImage? {
    let asset = AVAsset(url: audioURL)
    let metadata = asset.commonMetadata
    
    for item in metadata {
        if item.commonKey == .commonKeyArtwork, let data = item.dataValue, let image = UIImage(data: data) {
            return image
        }
    }
    
    return nil
}



// Reusable function to create FileModelDR from image data
func createFileModel(from imageData: Data) -> FileModelDR? {
    guard let image = UIImage(data: imageData), let imageURL = saveImageToTemporaryFile(image: image) else {
        // Handle failure to process image
        showToast(message: "Failed to process image.")
        return nil
    }
    
    let attachmentType = AttachmentType(fileExtension: imageURL.pathExtension)
    let fileModel = FileModelDR(fileData: [imageData], fileURL: [imageURL], attachmentType: [attachmentType])
    
    return fileModel
}
