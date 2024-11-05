//
//  ProfileVC.swift
//

//pod 'TOCropViewController'
import UIKit
import TOCropViewController

class ProfileVC: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var imgBG: UIImageView!
    
    @IBOutlet weak var navViewContainer: UIView!{
        didSet{
            navViewContainer.clipsToBounds = true
            navViewContainer.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            navViewContainer.layer.shadowColor =  UIColor.lightGray.cgColor
            navViewContainer.layer.shadowOffset = .zero
            navViewContainer.layer.shadowRadius = 5.0
            navViewContainer.layer.shadowOpacity = 0.5
            navViewContainer.layer.masksToBounds = false
            navViewContainer.layer.cornerRadius = iPad ? 25 : 25
        }
    }
    
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var lblTitleProfile: UILabel!
    @IBOutlet weak var lblTitleName: UILabel!
    @IBOutlet weak var imgNavLogo: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var viewInfoContainer: UIView!
    @IBOutlet weak var lblPersonalInfo: UILabel!
    @IBOutlet weak var viewName: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tfFullName: UITextField!
    
    @IBOutlet weak var viewUserName: UIView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var btnSaveProfile: UIButton!{
        didSet { configureButton(btnSaveProfile, bgColor: "7D95BA", titleColor: "FFFFFF") }
    }
    
    //MARK: - Variables
    var viewModel = ProfileViewModel()
//    var imagePicker : ImagePicker?
    var isImageNew = false
    var imageDataLocal : Data? = nil
    
    //MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.localization()
    }
    
   private func localization(){
        self.lblTitleProfile.text = String(with: .editProfile).uppercased()
    }
    
    //MARK: - Functions
    func setupDidLoad(){
        setInitails()
//        self.imagePicker = ImagePicker(presentationController: self, delegate: self,allowEditing: false)
        
        self.viewModel.view = self
        
        if UserSingleton.shared.getUserData() == nil {
            self.viewModel.getProfile(completion: { status, msg in
                if status == true{
                    self.setupView()
                }
            })
        }else {
            self.setupView()
        }
    }
    
    //MARK: - setupView
    func setupView(isUpdate:Bool?=nil){
        let userData = userSingleton.getUserData()
        self.tfEmail.text = userData?.email ?? ""
        self.tfEmail.alpha = 0.7
        let isSocial : Bool? = userSingleton.read(type: .isSocialLogin)
        self.tfEmail.isUserInteractionEnabled = !(isSocial ?? false)
        self.tfUserName.text = userData?.user_name ?? ""
        self.tfUserName.alpha = 0.7
        self.tfFullName.text = userData?.full_name ?? ""
        if let image = userData?.image , isUpdate == nil{
            self.imageView.loadImage(with: URL(string: image), placeholder: .placeHolderProfile())
        }
        self.lblTitleName.text = userData?.full_name ?? ""
        self.btnProfile.isUserInteractionEnabled = true
        lblUserName.text = String(with: .userName)
    }
    //MARK: - @IBAction
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.performSegueToReturnBack()
    }
    
    @IBAction func imgOnTap(_ sender: UIButton) {
        selectImageFromGallery()
    }
    
    @IBAction func saveOnPress(_ sender: UIButton) {
        saveUpdateData()
    }
    
    func saveUpdateData() {
        if imageDataLocal != nil {
            guard let imageData = imageDataLocal, let image = UIImage(data: imageData), let imageURL = saveImageToTemporaryFile(image: image) else {
                showToast(message: "Failed to process image.")
                return
            }
            let attachmentType = AttachmentType(fileExtension: imageURL.pathExtension)
            let fileModel = FileModelDR(fileData: [imageData], fileURL: [imageURL], attachmentType: [attachmentType])
            
            uploadImageS3(fetchedData: fileModel) { [weak self] url in
                guard let self = self else { return }
                if url.isEmpty {
//                    showToast(message: "Failed to upload image to AWS.")
                } else {
                    self.viewModel.updateProfile(image: url.first ?? "") { status, msg in
                        self.setupView(isUpdate: true)
                        self.performSegueToReturnBack()
                    }
                }
            }
        }
        else{
            self.viewModel.updateProfile(image: "") { status, msg in
                self.setupView(isUpdate: true)
                self.performSegueToReturnBack()

            }
        }
    }
}
//MARK: - Image Picker Delegate
extension ProfileVC:ImagePickerDelegate {
    func didSelect(image: UIImage?, mediaInfo: [UIImagePickerController.InfoKey : Any]?, tag: Int) {
        if image != nil{
            presentCropper(with: image ?? UIImage())
        }
    }
    
}

extension ProfileVC{
    //MARK: - Custom Methods
    func setInitails(){
        tfFullName.delegate = self
        tfEmail.delegate = self
        lblName.text = String(with: .fullName)
        lblEmail.text = String(with: .email)
        btnSaveProfile.setTitle( String(with: .saveChanges), for: .normal)
//        lblTitleProfile.font = .font(type: .bold, customSize: iPad ? 24 : 12)
//        lblTitleName.font = .font(type: .bold, customSize: iPad ? 34 : 17)
    }
}

//MARK: - UITextFieldDelegate
extension ProfileVC : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfFullName {
            tfEmail.becomeFirstResponder()
        } else if textField == tfEmail {
            textField.resignFirstResponder()
        }
        return true
    }
}

import TOCropViewController
extension ProfileVC : UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    func selectImageFromGallery() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let selectedImage = info[.originalImage] as? UIImage {
            presentCropper(with: selectedImage)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    func presentCropper(with image: UIImage) {
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        let imageCropper = TOCropViewController(croppingStyle: .default, image: image)
        imageCropper.aspectRatioLockEnabled = true
        imageCropper.rotateButtonsHidden = true
        imageCropper.aspectRatioPreset = .preset5x4
        imageCropper.rotateClockwiseButtonHidden = true
        imageCropper.aspectRatioPickerButtonHidden = true
        imageCropper.resetButtonHidden = true
        
        
        imageCropper.onDidCropToRect = { [weak self] (croppedImage, cropRect, angle) in
            guard let strongSelf = self else { return }
            (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .all
            imageCropper.dismiss(animated: true, completion: nil)
            strongSelf.imageView.image = croppedImage
            let jpegData = croppedImage.jpegData(compressionQuality: 1.0)
            strongSelf.imageDataLocal = jpegData
        }
        imageCropper.onDidFinishCancelled = {[weak self] isFinished in
            guard let strongSelf = self else { return }
            imageCropper.dismiss(animated: true, completion: nil)
            (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .all
        }
        imageCropper.modalPresentationStyle = .fullScreen
        self.navigationController?.present(imageCropper, animated: true, completion: nil)
    }
}
