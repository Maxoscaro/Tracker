//
//  AnalyticsService.swift
//  TrackerApp
//
//  Created by Maksim on 26.01.2025.
//

import Foundation
import YandexMobileMetrica

struct AnalyticsEvent {
    let eventType: AnalyticsEventType
    let screen: String
    let item: AnalyticsClickEventType?
}

enum AnalyticsEventType: String {
    case open
    case close
    case click
}

enum AnalyticsClickEventType: String {
    case add_track
    case track
    case filter
    case edit
    case delete
}

final class AnalyticsService {
    func sendEvent(_ analyticsEvent: AnalyticsEvent) {
        var params: [AnyHashable: Any] = [
            "event": analyticsEvent.eventType.rawValue,
            "screen": analyticsEvent.screen
        ]
        
        if let item = analyticsEvent.item {
            params["item"] = item.rawValue
        }
        
        YMMYandexMetrica.reportEvent(analyticsEvent.eventType.rawValue, parameters: params, onFailure: { error in
                print("DID FAIL REPORT EVENT: \(error.localizedDescription)")
        })
    }
}
