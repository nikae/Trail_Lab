//
//  ActivityStartView.swift
//  Trail Lab WatchOS Extension
//
//  Created by Nika Elashvili on 4/17/21.
//  Copyright © 2021 nilka. All rights reserved.
//

import SwiftUI

class ActivityStartViewHandler: ObservableObject {
    @EnvironmentObject var activityManager: ActivityManagerWatchOS
    @Published var activityTypes: [ActivityType] = []
    init() {
        activityTypes.append(
            contentsOf:
                [ActivityType.walking, ActivityType.running, ActivityType.hiking, ActivityType.biking])
    }
    
}

struct ActivityStartView: View {
    @ObservedObject var handler: ActivityStartViewHandler = ActivityStartViewHandler()
    let timer = Timer.publish(every: 30, on: .current, in: .common).autoconnect()
    @State var showGreeting: Bool = true
    
    var body: some View {
        GeometryReader { proxy in
            List {
                Section(header: header
                           
                ) {
                    ForEach(handler.activityTypes, id: \.self) { activity in
                        ActivityPlatter(activity: activity)
                            .frame(height: proxy.size.height * 0.7)
                        //                        .listRowPlatterColor(activity.color().opacity(0.15))
                    }
            }
        }
        .listStyle(CarouselListStyle())
        }.navigationTitle("Trail Lab")
    }
    
   
    private var header: some View {
        HStack {
            greeting
                .font(.system(.headline, design: .rounded))
                .minimumScaleFactor(0.2)
                .lineLimit(1)
                .onReceive(timer) { _ in
                    withAnimation {
                        self.showGreeting.toggle()
                    }
                }
            Spacer()
            Image(systemName: "gear")} .listRowPlatterColor(.black)
    }
    
   
    
    private var greeting: some View {
        if showGreeting {
            return Text(Date().greeting)
        } else {
            return Text(Date().localaizedDate(.medium))
            
        }
    }
   
    
   
}

struct ActivityStartView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityStartView()
    }
}
