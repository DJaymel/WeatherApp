//
//  WeatherStackController.swift
//  WeatherApp
//
//  Created by Jaymel Dash on 1/17/21.
//

import Foundation

private enum API {
    static let key = ""
}

final class WeatherStackController: WebServiceController {
    
    let fallbackService: WebServiceController?
    
    init(fallbackService: WebServiceController? = nil) {
        self.fallbackService = fallbackService
    }
    
    func fetchWeatherData(for city: String, completionHandler: @escaping (String?, WebServiceControllerError?) -> Void) {
        let endpoint = "http://api.weatherstack.com/current?access_key=\(API.key)&query=\(city)&units=f"
        
        let safeURLString = endpoint.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
             
        guard let endpointURL = URL(string: safeURLString) else {
                completionHandler(nil, WebServiceControllerError.invalidURL(safeURLString))
                return
        }
        
        let dataTask = URLSession.shared.dataTask(with: endpointURL, completionHandler: {
            (data, response, error) -> Void in
            guard error == nil else {
                if let fallback = self.fallbackService {
                    fallback.fetchWeatherData(for: city, completionHandler: completionHandler)
                } else {
                    completionHandler(nil, WebServiceControllerError.forwarded(error!))
                }
                return
            }
            
            guard let responseData = data else {
                if let fallback = self.fallbackService {
                    fallback.fetchWeatherData(for: city, completionHandler: completionHandler)
                } else {
                    completionHandler(nil, WebServiceControllerError.invalidPayload(endpointURL))
                }
                 return
            }
            
            // Decode JSON
            let decoder = JSONDecoder()
            do {
                let weatherList = try decoder.decode(OpenWeatherMapContainer.self, from: responseData)
                guard let weatherInfo = weatherList.list?.first,
                      let weather = weatherInfo.weather.first?.main,
                      let temperature = weatherInfo.main.temp else {
                    completionHandler(nil, WebServiceControllerError.invalidPayload(endpointURL))
                    return
                }
                
                //Compose Weather Information
                let weatherDescription = "\(weather) \(temperature) degrees F"
                completionHandler(weatherDescription, nil)
            } catch let error {
                completionHandler(nil, WebServiceControllerError.forwarded(error))
            }
        })
        dataTask.resume()
    }
}
