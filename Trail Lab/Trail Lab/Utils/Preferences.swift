//
//  Preferences.swift
//  Trail Lab
//
//  Created by Nika on 6/13/20.
//  Copyright © 2020 nilka. All rights reserved.
//

import Foundation

@propertyWrapper
public struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.setValue(newValue, forKey: key) }
    }
}

struct Preferences {
    @UserDefault("ACTIVITY_TYPE", defaultValue: ActivityType.walking.rawValue)
    static var activityType: Int
    @UserDefault("PREFERED_UNIT", defaultValue: getLocal().rawValue)
    static var unit: Int
    @UserDefault("DISTANCE_WEEKLY_GOAL", defaultValue: 16000.0)
    static var distanceGoal: Meter
    @UserDefault("TIME_WEEKLY_GOAL", defaultValue: 9000)
    static var timeGoal: TimeInterval
    @UserDefault("HAS_SEEN_OBNOARDING", defaultValue: false)
    static var hasSeenOnboarding: Bool
    @UserDefault("SORTED_ACTIVITY_TYPES", defaultValue: [ActivityType.walking.rawValue, ActivityType.running.rawValue, ActivityType.hiking.rawValue, ActivityType.biking.rawValue])
    static var sortedActivityTypes: [Int]
    
    static func addNewPreferredWorkout(type: Int) {
        var typeList = Preferences.sortedActivityTypes
        typeList.removeAll { (aType) -> Bool in
            return aType == type
        }
        typeList.insert(type, at: 0)
        Preferences.sortedActivityTypes = typeList
    }
}

enum UnitPreference: Int {
    case metric = 0
    case imperial = 1
    
    var stringValue: String {
        switch self {
        case .imperial:
            return "ft"
        case .metric:
            return "m"
        }
    }
}

/// Gets device local.
      /// This method is used to determin users default unit preferance before user explisitly sets it into the app setting
      /// - Returns: UnitPreference based on device local
   func getLocal() -> UnitPreference {
       //User region setting return
       let locale = Locale.current //NSLocale.current
       //Returns true if the locale uses the metric system (Note: Only three countries do not use the metric system: the US, Liberia and Myanmar.)
       let isMetric = locale.usesMetricSystem
       return isMetric ? .metric : .imperial
   }
