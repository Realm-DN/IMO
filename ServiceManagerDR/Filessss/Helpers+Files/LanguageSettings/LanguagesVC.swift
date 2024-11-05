//
//  LanguagesVC.swift
//

import UIKit

class LanguagesVC: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var btnApplyLanguage: UIButton!
    @IBOutlet weak var tbl: UITableView!
    
    // MARK: - Variables
    var language = LanguageShort.english
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        tbl.delegate = self
        tbl.dataSource = self
        btnApplyLanguage.layer.cornerRadius = btnApplyLanguage.frame.height/2
        navigationController?.navigationBar.isHidden = false
     
        btnApplyLanguage.setTitle(String(with: .apply), for: .normal)

        self.title = String(with: .changeLanguage)
        setupLocalization()
    }
    private func setupLocalization() {
        let currentLanguage = SaveUserResponse.shared.currentLanguage()
        switch currentLanguage {
        case LanguageShort.spanish.rawValue:
            language = .spanish
        case LanguageShort.french.rawValue:
            language = .french
        default:
            language = .english
        }
        tbl.reloadData()
    }

    
    
    // MARK: - Custom Methods
    private func updateLanguage() {
        Bundle.setLanguage(lang: language.rawValue)
        SaveUserResponse.shared.saveLanguage(language.rawValue)
        print("language.rawValue:\(language.rawValue)")
        let vc = LanguagesVC.instantiate(.Main)
        self.transitionToRootVC(vc)
    }
    // MARK: - IBActions
    @IBAction func btnApplyAction(_ sender: UIButton) {
        updateLanguage()
    }
}

extension LanguagesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LanguageInfo.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        
        let language = LanguageInfo(rawValue: indexPath.row)
        
        let lblLanguage = UILabel()
        lblLanguage.translatesAutoresizingMaskIntoConstraints = false
        lblLanguage.text = language?.localizedDescription
        lblLanguage.textColor = .black
        
        let imgCircle = UIImageView()
        imgCircle.translatesAutoresizingMaskIntoConstraints = false
        imgCircle.image = UIImage(systemName: "circle")
        imgCircle.tintColor = .green //.appBlueDarkColor //UIColor(named: "Color_btn")
        imgCircle.contentMode = .scaleAspectFit
        
        let isSelectedLanguage = (self.language == .english && indexPath.row == LanguageInfo.english.rawValue) ||
                                 (self.language == .spanish && indexPath.row == LanguageInfo.spanish.rawValue) ||
                                 (self.language == .french && indexPath.row == LanguageInfo.french.rawValue)

        
        
        imgCircle.image = isSelectedLanguage ? UIImage(systemName: "circle.inset.filled") : UIImage(systemName: "circle")
        
        cell.contentView.addSubview(lblLanguage)
        cell.contentView.addSubview(imgCircle)
        cell.selectionStyle = .none
        
        NSLayoutConstraint.activate([
            lblLanguage.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
            lblLanguage.trailingAnchor.constraint(equalTo: imgCircle.leadingAnchor, constant: -20),
            lblLanguage.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            imgCircle.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
            imgCircle.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            imgCircle.widthAnchor.constraint(equalToConstant: 20),
            imgCircle.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case LanguageInfo.english.rawValue:
            language = .english
        case LanguageInfo.spanish.rawValue:
            language = .spanish
        case LanguageInfo.french.rawValue:
            language = .french
        default:
            break
        }
        tbl.reloadData()
    }

    
}

enum LanguageInfo: Int, CaseIterable {
    case english = 0
    case spanish = 1
    case french = 2
    var languageType: LanguageShort {
            switch self {
            case .english:
                return .english
            case .spanish:
                return .spanish
            case .french:
                return .french
            }
        }
        
        var localizedDescription: String {
            switch self {
            case .english:
                return LanguageLocalize.english.localized
            case .spanish:
                return LanguageLocalize.spanish.localized
            case .french:
                return LanguageLocalize.french.localized
            }
        }
}

enum LanguageShort: String {
    case english = "en"
    case spanish = "es"
    case french = "fr"
}

enum LanguageLocalize: String {
    case english
    case spanish
    case french
    
    var localized: String {
        switch self {
        case .english: return  String(with: .english)
        case .spanish: return  String(with: .spanish)
        case .french: return  String(with: .french)
        }
    }
}

func updateLanguage(lang language: LanguageShort, completionHandler: @escaping () -> Void) {
    Bundle.setLanguage(lang: language.rawValue)
    SaveUserResponse.shared.saveLanguage(language.rawValue)
    completionHandler()
}
