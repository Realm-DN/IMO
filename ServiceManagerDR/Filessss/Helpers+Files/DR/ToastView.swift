//
//  ToastView.swift
// 

import Foundation
import UIKit

class ToastView: UIView {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    var dismissAction: (() -> Void)?
    
    init(message: String, showButton: Bool = true,bgColor:UIColor? = .blue) {
        super.init(frame: .zero)
        backgroundColor = .blue
        layer.cornerRadius = 10
        layer.borderWidth = 0.0
        layer.borderColor = UIColor.black.cgColor
//        if bgColor == .appColorBlueDark{
//            messageLabel.textColor = .white
//        }else{
//            messageLabel.textColor = .appColorBlueDark
//        }
        
        messageLabel.textColor = .secondarySystemBackground
        
        addSubview(messageLabel)
        
        messageLabel.text = message
        
        if showButton {
            addSubview(dismissButton)
            dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        }
        
        setupConstraints(showButton: showButton)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints(showButton: Bool) {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let labelLeadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        let labelTrailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        
        var constraints: [NSLayoutConstraint] = [
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            labelLeadingConstraint,
            labelTrailingConstraint,
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ]
        
        if showButton {
            dismissButton.translatesAutoresizingMaskIntoConstraints = false
            
            constraints.append(contentsOf: [
                dismissButton.topAnchor.constraint(equalTo: topAnchor, constant: 4),
                dismissButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
                dismissButton.widthAnchor.constraint(equalToConstant: 20),
                dismissButton.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Adjust label constraints to allow multiline layout
        messageLabel.preferredMaxLayoutWidth = messageLabel.frame.size.width
    }
    
    @objc private func dismissButtonTapped() {
        dismissAction?()
    }
}

var tempMessage = ""

func showToast(message: String,bgColor:UIColor? = .blue, showButton: Bool = true, duration: TimeInterval = 2.5, position: ToastPosition = .top) {
//    
//    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//          let window = windowScene.windows.first else {
//        return
//    }
//    
//    //Don't show same message again and again , if popup dismissed after that same message will show as new message
//    if tempMessage == message{
//        return
//    }else{
//        tempMessage = message
//    }
//    
//    let toast = ToastView(message: message, showButton: showButton,bgColor: .blue)
//    toast.translatesAutoresizingMaskIntoConstraints = false
//    window.addSubview(toast)
//    
//    toast.dismissAction = {
//        UIView.animate(withDuration: 0.2, animations: {
//            toast.alpha = 0.0
//        }) { _ in
//            tempMessage = ""
//            toast.removeFromSuperview()
//        }
//    }
//    
//    var constraint: NSLayoutConstraint
//    
//    switch position {
//    case .top:
//        constraint = toast.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 16)
//    case .center:
//        constraint = toast.centerYAnchor.constraint(equalTo: window.centerYAnchor)
//    case .bottom:
//        constraint = toast.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -16)
//    }
//    
//    NSLayoutConstraint.activate([
//        toast.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 16),
//        toast.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -16),
//        constraint
//    ])
//    
//    if position == .bottom {
//        toast.transform = CGAffineTransform(translationX: 0, y: window.bounds.height)
//    } else {
//        toast.transform = CGAffineTransform(translationX: 0, y: -window.bounds.height)
//    }
//    
//    toast.alpha = 0.0
//    
//    UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
//        toast.alpha = 1.0
//        toast.transform = .identity
//    }, completion: nil)
//    
//    
//    
//    // Auto-dismiss after the specified duration
//    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
//        toast.dismissAction?()
//    }
}

enum ToastPosition{
    case bottom
    case top
    case center
}
