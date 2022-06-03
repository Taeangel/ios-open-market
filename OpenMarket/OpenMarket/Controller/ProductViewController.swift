//
//  ProductViewController.swift
//  OpenMarket
//
//  Created by marlang, Taeangel on 2022/05/30.
//

import UIKit

fileprivate enum Const {
    static let zero = "0"
    static let empty = ""
    static let addImage = "sss"
      
      enum Product {
          static let name = "상품명"
          static let price = "상품가격"
          static let discountedPrice = "할인가격"
          static let stock = "재고수량"
      }
}

class ProductViewController: UIViewController {
    let network = URLSessionProvider<DetailProduct>()
    var managementType: ManagementType?
    var imageCount: Int {
        return imagesStackView.arrangedSubviews.count
    }
    
    private let imagesScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let imagesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var addImageView: UIImageView = {
        let image = UIImageView()
        image.isUserInteractionEnabled = true
        image.image = UIImage(named: Const.addImage)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let textFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Const.Product.name
        textField.clearButtonMode = .whileEditing
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let priceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let priceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Const.Product.price
        textField.clearButtonMode = .whileEditing
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: CurrencyType.inventory)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentControl
    }()
    
    private let discountedPriceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Const.Product.discountedPrice
        textField.clearButtonMode = .whileEditing
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let stockTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Const.Product.stock
        textField.clearButtonMode = .whileEditing
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    func addImage(imageView: UIImageView) {
        imagesStackView.insertArrangedSubview(imageView, at: imagesStackView.arrangedSubviews.count - 1)
    }
    
    func extractData() -> ProductInfomation {
        let name = nameTextField.text
        let price = Int(priceTextField.text ?? Const.zero)
        let discountedPrice = Int(discountedPriceTextField.text ?? Const.zero)
        let currency = (CurrencyType(
            rawValue: segmentControl.selectedSegmentIndex) ?? CurrencyType.krw)
            .description
        let stock = Int(stockTextField.text ?? Const.zero)
        let description = descriptionTextView.text
        let images: [ImageFile] = extractImage()
       
        let param = ProductInfomation(
            name: name,
            price: price,
            discountedPrice: discountedPrice,
            currency: currency,
            secret: OpenMarket.secret.description,
            descriptions: description,
            stock: stock,
            images: images)
        
        return param
    }
    
    private func extractImage() -> [ImageFile] {
        var images: [ImageFile] = []
        let imagePicker = imagesStackView.arrangedSubviews.last
        imagePicker?.removeFromSuperview()
        
        imagesStackView.arrangedSubviews.forEach { UIView in
            guard let UIimage = UIView as? UIImageView else {
                return
            }
            
            guard let data = UIimage.image?.jpegData(compressionQuality: 0.1) else {
                return
            }
            
            let image = ImageFile(fileName: Const.empty, type: Const.empty, data: data)
            images.append(image)
        }
        return images
    }
}

// MARK: - Keyboard

extension ProductViewController {
    
    func setupKeyboardNotification() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
        
        let swipeDown = UISwipeGestureRecognizer(
            target: self,
            action: #selector(respondToSwipeGesture)
        )
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                as? NSValue else {
            return
        }
        
        let keyboardHieght = keyboardFrame.cgRectValue.height
        
        if descriptionTextView.isFirstResponder {
            view.bounds.origin.y = 150
            descriptionTextView.contentInset.bottom = keyboardHieght - 150
        } else {
            view.bounds.origin.y = 0
            descriptionTextView.contentInset.bottom = 0
        }
    }
    
    @objc private func keyboardWillHide() {
        view.bounds.origin.y = 0
        descriptionTextView.contentInset.bottom = 0
    }
    
    @objc private func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        view.endEditing(true)
    }
    
    func setupEditView(product: DetailProduct?) {
        DispatchQueue.main.async { [weak self] in
            self?.nameTextField.text = product?.name
            self?.priceTextField.text = product?.price?.description
            self?.segmentControl.selectedSegmentIndex = 0
            self?.discountedPriceTextField.text = product?.discountedPrice?.description
            self?.stockTextField.text = product?.stock?.description
            self?.descriptionTextView.text = product?.description
            
            let imageImagePicker = self?.imagesStackView.arrangedSubviews.first
            imageImagePicker?.removeFromSuperview()
            
            product?.images?.forEach { image in
                let imageView = image.url?.convertImageView() ?? UIImageView()
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
                self?.imagesStackView.addArrangedSubview(imageView)
            }
        }
    }
}

// MARK: - ViewLayout

extension ProductViewController {
    
    func setupView() {
        
        addsubView()
        constraintLayout()
        view.backgroundColor = .systemBackground
        
        func addsubView() {
            view.addsubViews(imagesScrollView, textFieldStackView, descriptionTextView)
            imagesScrollView.addSubview(imagesStackView)
            imagesStackView.addArrangedsubViews(addImageView)
            textFieldStackView.addArrangedsubViews(
                nameTextField,
                priceStackView,
                discountedPriceTextField,
                stockTextField
            )
            priceStackView.addArrangedsubViews(priceTextField, segmentControl)
        }
        
        func constraintLayout() {
            NSLayoutConstraint.activate([
                imagesScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                imagesScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                imagesScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                imagesScrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),
                
                imagesStackView.topAnchor.constraint(equalTo: imagesScrollView.topAnchor),
                imagesStackView.bottomAnchor.constraint(equalTo: imagesScrollView.bottomAnchor),
                imagesStackView.leadingAnchor.constraint(equalTo: imagesScrollView.leadingAnchor),
                imagesStackView.trailingAnchor.constraint(equalTo: imagesScrollView.trailingAnchor),
                imagesStackView.heightAnchor.constraint(equalTo: imagesScrollView.heightAnchor),
                
                addImageView.widthAnchor.constraint(equalTo: addImageView.heightAnchor),
                
                textFieldStackView.topAnchor.constraint(equalTo: imagesScrollView.bottomAnchor, constant: 10),
                textFieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                textFieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                textFieldStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),
                
                segmentControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
                
                descriptionTextView.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 10),
                descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                descriptionTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
}
