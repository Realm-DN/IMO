import UIKit
import UniformTypeIdentifiers

class imgVC: UIViewController {
    @IBOutlet weak var tbl: UITableView!
    var imgUI: [UIImage] = []
    var imgURL: [String] = []
    var isurl = true
    
    var rightBarButtonItem: UIBarButtonItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbl.dataSource = self
        tbl.delegate = self
        let image = UIImage(systemName: "plus")
        rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(rightButtonTapped))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func rightButtonTapped() {
        showImagePicker()
    }
    
    func showImagePicker() {
        presentImagePicker()
//        presentMediaPicker()
    }
    func presentMediaPicker(){
        MediaPickerControllerDR.shared.configureMediaSelection(from: self, selectionType: .single, filterType: .galleryPhoto) { isSelected, files in
            print("files:\(files?.fileURL)")
        }
    }
    
    func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = [UTType.image.identifier]
        self.present(imagePickerController, animated: true, completion: nil)
    }
}

extension imgVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let mediaType = info[.mediaType] as? String, mediaType == UTType.image.identifier {
            if let imageURL = info[.imageURL] as? URL {
                print("Image URL: \(imageURL)")
                print("Path Extension: \(imageURL.pathExtension)")
                self.imgURL.append(imageURL.absoluteString)
                self.tbl.reloadData()
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension imgVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isurl ? imgURL.count : imgUI.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "imgTblCell", for: indexPath) as? imgTblCell else {
            return UITableViewCell()
        }
        if isurl {
            if let url = URL(string: imgURL[indexPath.row]) {
                cell.img.loadImage(with: url, placeholder: .checkmark)
            }
        } else {
            cell.img.image = imgUI[indexPath.row]
        }
        return cell
    }
}
