

import UIKit

struct WeatherData: Codable {
    struct Main: Codable {
        let temp: Double
    }
    struct Weather: Codable{
        let description: String
    }
    let main: Main
    let weather: [Weather]
}

class ViewController: UIViewController {
    fileprivate var oneSqlite: OneSqlite!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.oneSqlite = OneSqlite()
//        self.oneSqlite.deleteDatabase()
        fetchWeather()
    }
    
    func fetchWeather() {
        let latitude = "38.1705275"
        let longitude = "140.417219"
        let API_KEY = "410d8b4757a0796aa539f00fadd458c5"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(API_KEY)"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else {
                print("no data")
                return
            }
            
            guard let resp = response else {
                print("no data")
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    print(resp)
                    print(weatherData)
                    let temp = "\(weatherData.main.temp)°C"
                    let weather = weatherData.weather.first?.description ?? "不明"
                    
                    if (self.oneSqlite.createOneDB()){
                        if (self.oneSqlite.createOneTable()){
                            let result = self.oneSqlite.insertOneTable(temperature: temp, weather: weather)
                            if result {
                                self.oneSqlite.printAllMembers()
                            } else {
                                print(result)
                            }
                        }
                    }
                    
                }
            } catch{
                print("error")
            }
        }
        task.resume()
    }
}
