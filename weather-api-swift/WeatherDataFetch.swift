import Foundation

struct WeatherData: Codable {
    struct Main: Codable {
        let temp: Double
    }
    struct Weather: Codable {
        let description: String
    }
    let main: Main
    let weather: [Weather]
}


/// 天気情報クラス
class WeatherDataFetch {
    
    /// 天気情報取得
    /// - Returns: 取得した天気情報
    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping(WeatherData?) -> Void) {
        let API_KEY = "410d8b4757a0796aa539f00fadd458c5"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(API_KEY)"
        guard let url = URL(string: urlString) else { return }
        
        // 非同期でデータを取得
        
        URLSession.shared.dataTask(with: url) { data, response, err in
            do {
                print("bbb")
                // レスポンスコードが正常かチェック
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    guard let data = data else { return }
                    
                    let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                    DispatchQueue.main.async {
                        completion(weatherData)
                    }
                    // JSONデコード
                    print(weatherData)
                } else {
                    print("Invalid response or status code")
                    completion(nil)
                }
            } catch {
                print("Error fetching weather: \(error)")
                completion(nil)
            }
        }.resume()
        
        
    }
}
