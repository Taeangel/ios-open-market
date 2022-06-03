//
//  RegistrationViewController.swift
//  OpenMarket
//
//  Created by marlang, Taeangel on 2022/05/25.
//

import UIKit

fileprivate enum Const {
    static let error = "ERROR"
    static let cancel = "Cancel"
    static let done = "Done"
    static let really = "Really?"
    static let postSuccesse = "Post Successe"
}

final class RegistrationViewController: ProductViewController {
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        managementType = ManagementType.registration
        setupRegistrationView()
        setupNavigationItems()
        setupKeyboardNotification()
    }
    
    private func setupRegistrationView() {
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.allowsEditing = true
        self.imagePicker.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapAddImageButton))
        addImageView.addGestureRecognizer(gesture)
        
    }
    
    @objc private func didTapAddImageButton() {
        self.present(self.imagePicker, animated: true)
    }
   
    private func postProduct() {
        let productToRegister = extractData()
        
        self.network.postData(params: productToRegister) { result in
            switch result {
            case .success(_):
                self.showAlert(title: Const.postSuccesse) {
                    self.dismiss(animated: true)
                }
            case .failure(let error):
                self.showAlert(title: Const.error, message: error.errorDescription)
            }
        }
    }
}

// MARK: - UIImagePicker

extension RegistrationViewController: UIImagePickerControllerDelegate,
                                      UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
       
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        let pickedImage = image.convertSize(size: addImageView.image?.size.width ?? .zero)
        let imageView = UIImageView(image: pickedImage)
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        
        if imageCount == 5 {
            addImageView.isHidden = true
        }
        
        addImage(imageView: imageView)
        
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - navigationBar

extension RegistrationViewController {
    private func setupNavigationItems() {
        self.navigationItem.title = managementType?.type
        
        let cancelButton = UIBarButtonItem(
            title: Const.cancel,
            style: .plain,
            target: self,
            action: #selector(didTapCancelButton)
        )
        navigationItem.leftBarButtonItem = cancelButton
        
        let doneButton = UIBarButtonItem(
            title: Const.done,
            style: .plain,
            target: self,
            action: #selector(didTapDoneButton)
        )
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapDoneButton() {
        self.showAlert(title: Const.really, cancel: Const.cancel, action: postProduct)
    }
}
