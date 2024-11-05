//
//  DropDownDR.swift
//

import Foundation
import UIKit

protocol DropdownViewDRDelegate: AnyObject {
    func didSelectOption(_ option: String, _ index: Int)
}

class DropdownViewDR: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private let transparentView = UIView()
    private let tableView = UITableView()
    private var tblCellHeight: CGFloat = 50
    private var dataSource = [String]()
    private var imageArray: [String?]?
    weak var delegate: DropdownViewDRDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDropdownView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDropdownView()
    }
    
    private func setupDropdownView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func showDropdown(in view: UIView, from sourceView: UIView, with options: [String], images: [String?]? = nil, leading: CGFloat, trailing: CGFloat, height: CGFloat, cellHeight: CGFloat = 50) {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
//            return
//        }
        
        guard let window = keyWindow else {return}
        
        view.endEditing(true)

        transparentView.frame = window.frame
        window.addSubview(transparentView)

        let sourceFrame = sourceView.convert(sourceView.bounds, to: window)
        let spaceBelow = window.frame.height - sourceFrame.maxY
        let showAbove = spaceBelow < height
        
        let dropdownFrame: CGRect
        if showAbove {
            dropdownFrame = CGRect(x: sourceFrame.origin.x + leading, y: sourceFrame.origin.y - height, width: sourceFrame.width - (leading + trailing), height: height)
        } else {
            dropdownFrame = CGRect(x: sourceFrame.origin.x + leading, y: sourceFrame.origin.y + sourceFrame.height, width: sourceFrame.width - (leading + trailing), height: height)
        }

        tableView.frame = dropdownFrame
        window.addSubview(tableView)
        tableView.layer.cornerRadius = 5

        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        dataSource = options
        imageArray = images
        tblCellHeight = cellHeight
        tableView.reloadData()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeDropdownView))
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0

        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = dropdownFrame
        }, completion: nil)
    }
    
    @objc private func removeDropdownView() {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.width, height: 0)
        }, completion: { _ in
            self.transparentView.removeFromSuperview()
            self.tableView.removeFromSuperview()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = dataSource[indexPath.row].localized()
        cell.textLabel?.font = UIFont(name: "Poppins-Regular", size: 15)
        if let imageArray = imageArray, let imageName = imageArray[indexPath.row] {
            if let image = UIImage(systemName: imageName) {
                // The image is a system image
                cell.imageView?.image = image
            } else {
                // The image is not a system image; you can try loading it from a file
                if let customImage = UIImage(named: imageName) {
                    cell.imageView?.image = customImage
                } else {
                    // If no image exists or if the image name is invalid, set a placeholder or leave it empty
                    cell.imageView?.image = nil
                }
            }
        } else {
            // If imageArray is nil or the imageName is nil, set a placeholder or leave it empty
            cell.imageView?.image = nil
        }
        
        cell.selectionStyle = .none
        cell.separatorInset = .zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tblCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = dataSource[indexPath.row]
        delegate?.didSelectOption(selectedOption, indexPath.row)
        removeDropdownView()
    }
}
