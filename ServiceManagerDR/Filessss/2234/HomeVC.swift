//
//  ViewController.swift
//

import UIKit
import Combine

class HomeVC: UIViewController {
    private var viewModel = HomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    @IBOutlet weak var tbl: UITableView!
    lazy var refreshControl: UIRefreshControl = configureRefreshControl(for: self.tbl, action: #selector(handleRefresh(_:)))
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        viewModel.current_page = 1
        self.viewModel.fetchPrice()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        userSingleton.write(type: .authorization, value: auth)
        setupTableView()
        setupBindings()
        viewModel.fetchPrice()
    }
    
    private func setupTableView() {
        tbl.dataSource = self
        tbl.delegate = self
    }
    
    private func setupBindings() {
        viewModel.$priceList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in 
                
                self?.refreshControl.endRefreshing()
                self?.tbl.reloadData()
                
                if  ((self?.viewModel.priceList.isEmpty) != nil) {
                } else {
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showErrorAlert(message: errorMessage)
                }
            }
            .store(in: &cancellables)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.priceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        cell.lblName.text = viewModel.priceList[indexPath.row].name ?? ""
        return cell
    }
}



extension UIViewController {
    func configureRefreshControl(for scrollView: UIScrollView, action: Selector) -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .blue
        refreshControl.addTarget(self, action: action, for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        scrollView.refreshControl = refreshControl
        return refreshControl
    }
}
