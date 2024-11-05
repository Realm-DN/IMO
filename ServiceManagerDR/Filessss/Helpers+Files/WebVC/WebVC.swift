//
//  WebViewVC.swift
//

import UIKit
import WebKit

enum WebUrl {
    case privacy, terms, about, help, tutorial
    case custom(url: String, title: String)
}

class WebVC: UIViewController {
    
    @IBOutlet weak var navViewContainer: UIView! {
        didSet {
            navViewContainer.configureNavViewContainer()
        }
    }
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var webView: WKWebView!
    
    var urlType: WebUrl?
    var isComeFromSettings: Bool = false
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    var url = ""
    let commonURL = "https://www.google.com/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        loadURL()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.performSegueToReturnBack()
    }
    
    private func setupNavigationBar() {
        if let itemUrl = userSingleton.getAppSettingsData(), hasValidSettings(itemUrl) {
            configureNavigationForType(using: itemUrl)
        } else {
            CommonSetting.share.getAppSettings { [weak self] status, msg in
                guard let self = self else { return }
                if status, let itemUrl = userSingleton.getAppSettingsData() {
                    self.configureNavigationForType(using: itemUrl)
                } else {
                    // Handle error or provide fallback if fetching settings fails
                    self.configureNavigation(url: self.commonURL, title: "Web View")
                }
            }
        }
    }

    private func hasValidSettings(_ itemUrl: AppSettingsModel) -> Bool {
        // Check if at least one of the required URLs is available
        return itemUrl.privacy_policy != nil || itemUrl.terms_conditions != nil ||
               itemUrl.about_us != nil || itemUrl.help != nil || itemUrl.tutorial != nil
    }

    private func configureNavigationForType(using itemUrl: AppSettingsModel) {
        switch urlType {
        case .privacy:
            configureNavigation(url: itemUrl.privacy_policy, title: String(with: .privacyPolicy))
        case .terms:
            configureNavigation(url: itemUrl.terms_conditions, title: String(with: .terms))
        case .about:
            configureNavigation(url: itemUrl.about_us, title: String(with: .about_Us))
        case .help:
            configureNavigation(url: itemUrl.help, title: String(with: .help))
        case .tutorial:
            configureNavigation(url: itemUrl.tutorial, title: "Tutorial")
        case .custom(let url, let title):
            configureNavigation(url: url, title: title)
        case .none:
            configureNavigation(url: commonURL, title: "Web View")
        }
    }

    
//    private func setupNavigationBar() {
//        if let itemUrl = userSingleton.getAppSettingsData(), !itemUrl.isEmpty {
//            configureNavigationForType(using: itemUrl)
//        } else {
//            CommonSetting.share.getAppSettings { [weak self] status, msg in
//                guard let self = self else { return }
//                if status, let itemUrl = userSingleton.getAppSettingsData() {
//                    self.configureNavigationForType(using: itemUrl)
//                } else {
//                    // Handle error or provide fallback if fetching settings fails
//                    self.configureNavigation(url: self.commonURL, title: "Web View")
//                }
//            }
//        }
//    }

//    private func configureNavigationForType(using itemUrl: AppSettingsData) {
//        switch urlType {
//        case .privacy:
//            configureNavigation(url: itemUrl.privacy_policy, title: String(with: .privacyPolicy))
//        case .terms:
//            configureNavigation(url: itemUrl.terms_conditions, title: String(with: .terms))
//        case .about:
//            configureNavigation(url: itemUrl.about_us, title: String(with: .about_Us))
//        case .help:
//            configureNavigation(url: itemUrl.help, title: String(with: .help))
//        case .tutorial:
//            configureNavigation(url: itemUrl.tutorial, title: "Tutorial")
//        case .custom(let url, let title):
//            configureNavigation(url: url, title: title)
//        case .none:
//            configureNavigation(url: commonURL, title: "Web View")
//        }
//    }

    
    
    
//    private func setupNavigationBar() {
//        guard let itemUrl = userSingleton.getAppSettingsData() else { return }
//        
//        switch urlType {
//        case .privacy:
//            configureNavigation(url: itemUrl.privacy_policy, title: String(with: .privacyPolicy))
//        case .terms:
//            configureNavigation(url: itemUrl.terms_conditions, title: String(with: .terms))
//        case .about:
//            configureNavigation(url: itemUrl.about_us, title: String(with: .about_Us))
//        case .help:
//            configureNavigation(url: itemUrl.help, title: String(with: .help))
//        case .tutorial:
//            configureNavigation(url: itemUrl.tutorial, title: "Tutorial")
//        case .custom(let url, let title):
//            configureNavigation(url: url, title: title)
//        case .none:
//            configureNavigation(url: commonURL, title: "Web View")
//        }
//    }
    
    private func configureNavigation(url: String?, title: String) {
        self.url = url ?? commonURL
        self.lblTitle.text = title.uppercased()
    }
    
    private func loadURL() {
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))
        }
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        activityIndicator.color = .gray
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension WebVC: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}
