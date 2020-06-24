//
//  ActivityStatsView.swift
//  Trail Lab
//
//  Created by Nika on 6/16/20.
//  Copyright © 2020 nilka. All rights reserved.
//

import SwiftUI

struct ActivityStatsView: View {
    @EnvironmentObject var activityHandler: ActivityHandler
    var body: some View {
        ZStack {
            AppBackground()
                .cornerRadius(12)
            VStack {
                Text("\(activityHandler.activity?.duration.rounded() ?? 0)")
                Text("Steps: \(activityHandler.activity?.numberOfSteps ?? 0)")
                Text("distance: \(activityHandler.activity?.distance ?? 0)")
                Text("averagePace: \(activityHandler.activity?.averagePace ?? 0)")
                Text("pace: \(activityHandler.activity?.pace ?? 0)")
                Text("cadence: \(activityHandler.activity?.cadence ?? 0)")
            }
        }
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.4), radius: 10.0)
    }
}

struct ActivityStatsView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityStatsView()
    }
}
