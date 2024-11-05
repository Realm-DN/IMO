//
//  ReusableView+TV+CV+Extensions.swift
//

import UIKit

// Protocol for common functionality between UITableView and UICollectionView
protocol ReusableView: AnyObject {
    func setEmptyMessage(_ message: String)
    func restore()
    func registerNib<T: UIView>(_ cellClass: T.Type)
    func dequeueReusableCell<T: UIView>(for indexPath: IndexPath) -> T
}

// Generic implementation for setting empty message and restoring state
extension ReusableView where Self: UIScrollView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .blue
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = .font_size(type: .bold, size: UIDevice.current.userInterfaceIdiom == .pad ? 16 : 10)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if let tableView = self as? UITableView {
            tableView.backgroundView = messageLabel
        } else if let collectionView = self as? UICollectionView {
            collectionView.backgroundView = messageLabel
        }
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }

    func restore() {
        if let tableView = self as? UITableView {
            tableView.backgroundView = nil
            tableView.separatorStyle = .none
        } else if let collectionView = self as? UICollectionView {
            collectionView.backgroundView = nil
        }
    }
    
    func registerNib<T: UIView>(_ cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        let nib = UINib(nibName: identifier, bundle: nil)
        
        if let tableView = self as? UITableView {
            tableView.register(nib, forCellReuseIdentifier: identifier)
        } else if let collectionView = self as? UICollectionView {
            collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        }
    }

    func dequeueReusableCell<T: UIView>(for indexPath: IndexPath) -> T {
        let identifier = String(describing: T.self)
        
        if let tableView = self as? UITableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
                fatalError("Failed to dequeue cell with identifier: \(identifier)")
            }
            return cell
        } else if let collectionView = self as? UICollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
                fatalError("Failed to dequeue cell with identifier: \(identifier)")
            }
            return cell
        } else {
            fatalError("Unsupported view type")
        }
    }
}

// Extend UITableView to conform to ReusableView
extension UITableView: ReusableView {}

// Extend UICollectionView to conform to ReusableView
extension UICollectionView: ReusableView {}
