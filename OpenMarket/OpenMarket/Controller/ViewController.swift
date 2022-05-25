//
//  ViewController.swift
//  OpenMarket
//
//  Created by 김동욱 on 2022/05/24.
//

import UIKit

final class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationItem()
    }
    
    private func setupNavigationItem() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapDissmis))
        navigationItem.leftBarButtonItem = cancelButton
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(didTapDoneButton))
        navigationItem.leftBarButtonItem = doneButton
        navigationController?.title = "상품 등록"
    }
    
    @objc private func didTapDissmis() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapDoneButton() {
        let alert = UIAlertController(title: "상품 등록", message: "상품을 등록 하시겠습니까?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "예", style: .default, handler: {(_) in
            self.didTapDissmis()
        })
        let noAction = UIAlertAction(title: "아니오", style: .destructive, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
}
