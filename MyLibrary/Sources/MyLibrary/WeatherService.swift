import Alamofire

public enum BaseURL: String {
    case openWeatherMap = "https://api.openweathermap.org/data/2.5/weather?q=corvallis&units=imperial&appid=12d4822d8deec321496e0e5805c2055d"
    case localMock = "http://localhost:3000/api/v1/weather"
}

public protocol WeatherService {
    func getTemperature(url: BaseURL) async throws -> Int
}

class WeatherServiceImpl: WeatherService {

    func getTemperature(url: BaseURL) async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url.rawValue, method: .get).validate(statusCode: 200..<300).responseDecodable(of: Weather.self) { response in
                switch response.result {
                case let .success(weather):
                    let temperature = weather.main.temp
                    let temperatureAsInteger = Int(temperature)
                    continuation.resume(with: .success(temperatureAsInteger))

                case let .failure(error):
                    continuation.resume(with: .failure(error))
                }
            }
        }
    }
}

public struct Weather: Decodable {
    public let main: Main

    public struct Main: Decodable {
        public let temp: Double
    }
}
