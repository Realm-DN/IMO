//
//  LocationManager.swift
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

struct CustomGMSAddress: Codable {
    let short_address : String?
    let address_line_1, address_line_2, city, state, country, zip, latitude, longitude,country_name_code,state_name_code: String?
    let id: Int?
    let complete_address : String?
}


public protocol LocationManagerDelegate: AnyObject {
    func currentLocation(coordinates: CLLocationCoordinate2D)
}

protocol LocationProtocol {
    //func getAddressValue(_ locationAddress: CustomGMSAddress)
}

class LocationViewController: UIViewController {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var delegate: LocationProtocol?
    var completion: ((CustomGMSAddress?) -> Void)?
    var locCoordinate: ((CLLocationCoordinate2D?) -> Void)?
    var searchBool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemBackground
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.tableCellBackgroundColor = .systemBackground
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.delegate = self
        searchController?.searchBar.returnKeyType = .done
        let filter = GMSAutocompleteFilter()
        resultsViewController?.autocompleteFilter = filter
        searchController?.popoverPresentationController?.backgroundColor = .systemBackground
        
        let subView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 45.0))
        subView.addSubview(searchController!.searchBar)
        view.addSubview(subView)
        definesPresentationContext = true
        
        searchController?.searchBar.tintColor = .blue
        searchController?.navigationItem.rightBarButtonItem?.tintColor = .blue
        searchController?.searchBar.becomeFirstResponder()
        // Set the color for the cancel button
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.link], for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController?.isActive = true
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchBar.becomeFirstResponder()
        }
    }
}

extension LocationViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}

extension LocationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

open class LocationManagerLVC: NSObject {
    var locationDelegate: LocationManagerDelegate?
    private var locationManager = CLLocationManager()
    private var presentationController: UIViewController?
    static let shared = LocationManagerLVC()
    
    public init(controller: UIViewController, locationDelegate: LocationManagerDelegate) {
        super.init()
        self.locationDelegate = locationDelegate
        
        self.locationManager.delegate = self
        self.locationManager.requestLocation()
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.presentationController = controller
    }
    
    func startUpdatingLocation() {
        self.locationManager.delegate = self
        self.locationManager.requestLocation()
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    public override init() {}
    
    func stopUpdatingLocations() {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.delegate = nil
    }
}

extension LocationManagerLVC: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
            break
        case .notDetermined:
            self.locationManager.requestLocation()
            self.locationManager.requestWhenInUseAuthorization()
        default:
            self.locationManager.stopUpdatingLocation()
            
            let alertController = UIAlertController(title: "Location is turned off", message: "Please enable location from the privacy section", preferredStyle: .alert)
            let openAction = UIAlertAction(title: "Open", style: .default) { (clicked) in
                self.presentationController?.openSettings()
            }
            alertController.addAction(openAction)
            self.presentationController?.present(alertController, animated: true, completion: nil)
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationDelegate?.currentLocation(coordinates: location.coordinate)
            self.stopUpdatingLocations()
        }
    }
}

extension UIViewController {
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                // Handle
            })
        }
    }
}

class LocationManager: NSObject {
    // MARK: - Variables
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var completion: ((CLLocationCoordinate2D?, Error?) -> Void)?
    
    // MARK: - Methods
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    func requestLocation(){
        locationManager.requestLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    // MARK: - Get Current Location
    func getCurrentLocation(completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        self.locationManager.delegate = self
        self.completion = completion
       
//        if !CLLocationManager.locationServicesEnabled() {
//            completion(nil, NSError(domain: "Location services not enabled", code: 0, userInfo: nil))
//            return
//        }
        
        locationManager.requestLocation()
        //locationManager.startUpdatingLocation()
    }
    // MARK: - Check Location is enabled or not
    func isLocationEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .restricted, .denied:
            completion?(nil, NSError(domain: "Location services not authorized", code: 1, userInfo: nil))
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestLocation()
             // Authorization request handled in `requestLocation`
        @unknown default:
            completion?(nil, NSError(domain: "Unknown authorization status", code: 2, userInfo: nil))
        }
    }
}

// MARK: - Location Manager Delegate Methods
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        completion?(location.coordinate, nil)
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil

    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(nil, error)
        locationManager.stopUpdatingLocation()
    }
}

extension GMSGeocoder {
    static func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D, completion: @escaping (CustomGMSAddress?) -> Void) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let data = response?.firstResult(),
                  let _ = data.lines?.first else {
                completion(nil)
                return
            }
            
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let clGeocoder = CLGeocoder()
            clGeocoder.reverseGeocodeLocation(location) { placemarks, error in
                guard let placemark = placemarks?.first, error == nil else {
                    completion(nil)
                    return
                }
                
                let stateCode = placemark.administrativeArea
                let finalAddress = data.addressLine1()
                let addresswithoutCountry = finalAddress?.getAddressWithoutCountryName()
                var shortAddress = ""
                
                if data.locality != nil ||  data.locality != ""
                {
                    shortAddress = "\(data.locality ?? ""), \(stateCode ?? "")"
                }
                else
                {
                    shortAddress = "\(stateCode ?? "")"
                }
               
                let customGMSAddress = CustomGMSAddress(
                    short_address: shortAddress, address_line_1: addresswithoutCountry,
                    address_line_2: finalAddress,
                    city: data.locality,
                    state: data.administrativeArea,
                    country: data.country,
                    zip: data.postalCode,
                    latitude: "\(coordinate.latitude)",
                    longitude: "\(coordinate.longitude)",
                    country_name_code: "",
                    state_name_code: stateCode,
                    id: nil,
                    complete_address: nil
                )
              //  DispatchQueue.main.async {
                    completion(customGMSAddress)
                    print("stateCode: \(stateCode ?? "N/A")")
               // }
            }
        }
    }
}

extension LocationViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        searchController?.searchBar.text = place.formattedAddress
        self.dismiss(animated: true, completion: nil)
        GMSGeocoder.reverseGeocodeCoordinate(place.coordinate) { customGMSAddress in
            if let customAddress = customGMSAddress {
                 self.completion?(customAddress)
               // self.delegate?.getAddressValue(customAddress)
            } else {
                debugPrint("Location not found")
            }
        }
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
    }
}

// MARK: - Get Current Location
extension UIViewController {
    func fetchAndSetCustomGMSAddress(completion: @escaping (CustomGMSAddress?) -> Void) {
        LocationManager.shared.getCurrentLocation { [weak self] coordinate, error in
            guard let self = self, let coordinate = coordinate else {
                if let error = error {
                    print("Error getting location: \(error.localizedDescription)")
                }
                completion(nil)
                return
            }
            GMSGeocoder.reverseGeocodeCoordinate(coordinate, completion: completion)
        }
    }
}

// MARK: - Search Location by Search Field
extension UIViewController: LocationProtocol {
    func findLocation(completion: @escaping (CustomGMSAddress?) -> Void) {
        let locationClass = LocationViewController()
        locationClass.delegate = self
        locationClass.completion = completion
        self.present(locationClass, animated: true)
    }
    
    func getAddressValue(_ locationAddress: CustomGMSAddress) {
        if let locationClass = self.presentedViewController as? LocationViewController {
            locationClass.completion?(locationAddress)
        }
    }
}

extension String {
    func getAddressWithoutCountryName() -> String {
        if let lastIndex = self.lastIndex(of: ",") {
            return String(self.prefix(upTo: lastIndex))
        }
        return self
    }
}
