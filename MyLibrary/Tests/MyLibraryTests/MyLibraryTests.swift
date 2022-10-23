import XCTest
import MyLibrary

final class MyLibraryTests: XCTestCase {
    func testIsLuckyBecauseWeAlreadyHaveLuckyNumber() async {
        // Given
        let mockWeatherService = MockWeatherService(
            shouldSucceed: true,
            shouldReturnTemperatureWithAnEight: false
        )

        let myLibrary = MyLibrary(weatherService: mockWeatherService)

        // When
        let isLuckyNumber = await myLibrary.isLucky(8)

        // Then
        XCTAssertNotNil(isLuckyNumber)
        XCTAssert(isLuckyNumber == true)
    }

    func testIsLuckyBecauseWeatherHasAnEight() async throws {
        // Given
        let mockWeatherService = MockWeatherService(
            shouldSucceed: true,
            shouldReturnTemperatureWithAnEight: true
        )

        let myLibrary = MyLibrary(weatherService: mockWeatherService)

        // When
        let isLuckyNumber = await myLibrary.isLucky(0)

        // Then
        XCTAssertNotNil(isLuckyNumber)
        XCTAssert(isLuckyNumber == true)
    }

    func testIsNotLucky() async {
        // Given
        let mockWeatherService = MockWeatherService(
            shouldSucceed: true,
            shouldReturnTemperatureWithAnEight: false
        )

        let myLibrary = MyLibrary(weatherService: mockWeatherService)

        // When
        let isLuckyNumber = await myLibrary.isLucky(7)

        // Then
        XCTAssertNotNil(isLuckyNumber)
        XCTAssert(isLuckyNumber == false)
    }

    func testIsNotLuckyBecauseServiceCallFails() async {
        // Given
        let mockWeatherService = MockWeatherService(
            shouldSucceed: false,
            shouldReturnTemperatureWithAnEight: false
        )

        let myLibrary = MyLibrary(weatherService: mockWeatherService)

        // When
        let isLuckyNumber = await myLibrary.isLucky(7)

        // Then
        XCTAssertNil(isLuckyNumber)
    }

    // Unit Test for Weather model.
    func testIsStructWeatherHasCorrectTemp() throws {
        // Use data.json as data resource.
        let filepath = try XCTUnwrap(Bundle.module.path(forResource: "data", ofType: "json"))
        let jsonString = try String(contentsOfFile: filepath)
        let jsonData = Data(jsonString.utf8)
        let jsonDecoder = JSONDecoder()
        let weather = try jsonDecoder.decode(Weather.self, from: jsonData)

        // Test whether same as file
        XCTAssert(weather.main.temp == 295.83)
    }
    
    // Integration Test for WeatherServiceImpl
    func testWeatherServiceImplIntegration() async throws {
        let weatherService = MyLibrary()
        var mockTemperature = 0
        var realTemp = 0

        do {
            mockTemperature = try await weatherService.weatherService.getTemperature(url: BaseURL.localMock)
            realTemp = try await weatherService.weatherService.getTemperature(url: BaseURL.openWeatherMap)
        } catch {
            return
        }
        
        XCTAssert(mockTemperature == Int(295.83))
        XCTAssertNotNil(realTemp)
        XCTAssertGreaterThan(realTemp, 0)
    }
}
