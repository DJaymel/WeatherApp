//
//  WebServiceController.swift
//  WeatherApp
//
//  Created by Jaymel Dash on 1/17/21.
//

import Foundation

public enum WebServiceControllerError: Error {
    case invalidURL(String)
    case invalidPayload(URL)
    case forwarded(Error)
}

public protocol WebServiceController {
    func  fetchWeatherData(for city: String,
                           completionHandler: @escaping (String?, WebServiceControllerError?) -> Void)
    
    init(fallbackService: WebServiceController?)
    
    var fallbackService: WebServiceController? { get }
}
