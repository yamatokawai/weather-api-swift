

import UIKit
//import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    fileprivate var oneSqlite: OneSqlite!
    fileprivate var weatherData : WeatherDataFetch!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postalCodeInput: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //        locationManager.requestWhenInUseAuthorization()
        //        getCurrentLocation()
        self.oneSqlite = OneSqlite()
        //        self.oneSqlite.deleteDatabase()
        self.weatherData = WeatherDataFetch()
        print("aaa")
        //
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        guard let inputText = postalCodeInput.text else { return }
        
        findLocationByPostalCode(
            postalCode: inputText, completion: {result, error in
                print("result")
            })
    }
    
    func findLocationByPostalCode(postalCode: String,completion: @escaping(String?, Error?) -> Void) {
        CLGeocoder().geocodeAddressString(postalCode) {
            (placemarks, error) in
            if let error = error {
                completion(nil,error)
                return
            }
            if let placemark = placemarks?.first {
                if let lat = placemark.location?.coordinate.latitude,let lon = placemark.location?.coordinate.longitude {
                    self.weatherData.fetchWeather(latitude: lat, longitude: lon, completion: { result in
                        if !self.oneSqlite.createOneDB() { return }
                        if !self.oneSqlite.deleteOneTable() {return}
                        if !self.oneSqlite.createOneTable() { return }
                        guard let resp = result else {return}
                        let temp = "\(resp.main.temp)°C"
                        let weather = resp.weather.first?.description ?? "不明"
                        let insertResult = self.oneSqlite.insertOneTable(temperature: temp, weather: weather)
                        insertResult ? self.oneSqlite.printAllMembers() : print("失敗");
                    })
                }
            }
        }
    };
}
