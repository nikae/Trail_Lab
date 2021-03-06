//
//  ActivitiesView.swift
//  Trail Lab
//
//  Created by Nika on 6/26/20.
//  Copyright © 2020 nilka. All rights reserved.
//

import SwiftUI

struct ActivitiesNavigationView: View {
    @EnvironmentObject var historyViewHandler: HistoryViewHandler
    @State var open: Bool = false
    var body: some View {
        NavigationView {
            List {
                ForEach(historyViewHandler.activityList, id: \.id) { act in
                    ActivityCell(activity: act)
                        .onTapGesture {
                            self.historyViewHandler.selectedActivity = act
                            self.open.toggle()
                    }
                }
            }
            .navigationBarTitle("Activities", displayMode: .large)
            
        }
        .sheet(isPresented: $open, content: {
            SingleActivityView(singleActivityViewHandler: SingleActivityViewHandler(activity: self.historyViewHandler.selectedActivity),
                isNewActivity: false)
        })
    }
}

struct ActivitiesView: View {
    @EnvironmentObject var historyViewHandler: HistoryViewHandler
    @State var open: Bool = false
    var body: some View {
            List {
                ForEach(historyViewHandler.activityList, id: \.id) { act in
                    ActivityCell(activity: act)
                        .onTapGesture {
                            self.historyViewHandler.selectedActivity = act
                            self.open.toggle()
                    }
                }
            }
        .sheet(isPresented: $open, content: {
            let handler = SingleActivityViewHandler(activity: self.historyViewHandler.selectedActivity)
            SingleActivityView(singleActivityViewHandler: handler,
                isNewActivity: false)
        })
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitiesView()
    }
}

struct DismissIcon: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        Image(systemName: "chevron.compact.down")
            .padding(.top)
            .font(.system(size: 30, weight: .light, design: .default))
            .onTapGesture {
                self.presentationMode.wrappedValue.dismiss()
        }
    }
}
