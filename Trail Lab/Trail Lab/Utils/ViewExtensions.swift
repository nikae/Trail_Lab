//
//  ViewExtensions.swift
//  Trail Lab
//
//  Created by Nika on 6/16/20.
//  Copyright © 2020 nilka. All rights reserved.
//

import SwiftUI

//MARK: Background
extension View {
    func AppBackground() -> some View {
        return Color(UIColor.background.primary)
            .edgesIgnoringSafeArea(.all)
    }
}

//MARK: Button styles
extension View {
    func workoutButton(withBorder: Bool = false,
                       background: Color = .blue,
                       imageName: String = "",
                       isSystemIcon: Bool = false) -> some View {
        return ZStack(alignment: .center) {
            Circle()
                .overlay(Circle()
                    .stroke(
                        withBorder ? Color.black : .clear ,
                        lineWidth: 0.5))
                .foregroundColor(background)

            if isSystemIcon {
                Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.black)
                .padding(20)
                   // .border(Color.white)
            } else {

            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.black)
                .padding(20)
            }
        }
    }

    func mapButton(_ text: String, selected: Bool)  -> some View  {
        return selected ?
            Text(text)
                .underline()
                .lineLimit(1)
                .foregroundColor(Color(.label)) :
            Text(text)
                .lineLimit(1)
                .foregroundColor(Color(.label))
    }

    func directionalButton(_ direction: graphDirection)  -> some View  {
        let name: String

        switch direction {
        case .previous:
            name = "chevron.left"
        case .next:
            name = "chevron.right"
        case .current:
            name = ""
        }

        return HStack {
            if direction == .previous {
                Spacer()
            }
            Image(systemName: name)
            if direction == .next {
                Spacer()
            }
        }
        .frame(minWidth: .zero, maxWidth: .infinity)

    }
    
}

struct EndProgressBar: View {
    @Binding var progress: Float
    var body: some View {
        Circle()
            .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
            .stroke(style: StrokeStyle(
                lineWidth: 5,
                lineCap: .round,
                lineJoin: .round))
            .foregroundColor(Color.red)
            .rotationEffect(Angle(degrees: 270.0))
    }
}


//MARK: StatsView
extension View {
    func StatsView(value: String,
                   title: String,
                   tintColor: Color) -> some View {
        return VStack(spacing: 2) {
            Text(value)
                .font(.body)
                .fontWeight(.bold)
                Text(title)
                    .font(.caption)
                    .foregroundColor(tintColor)
                    .minimumScaleFactor(0.5)
            
        }
    }

    func StatsViewLarge(value: String,
                     title: String,
                     tintColor: Color, larger: Bool = false) -> some View {
        return  HStack {
            VStack(alignment:.leading, spacing: 2) {
              Text(value)
                .fontWeight(.bold)
                .font(Font.system(larger ? .largeTitle : .title, design: .rounded).monospacedDigit())
                  Text(title)
                      .font(.headline)
                      .foregroundColor(tintColor)
            }
            Spacer()
          }
      }

    //MARK: textWithCircle
    func TextWithCircle(color: Color, title: String) -> some View {
        return HStack {
            Image(systemName: "circle.fill").foregroundColor(color)
            Text(title)
        }
        .font(.footnote)
    }

    func ColorGuide() -> some View {
        let arr: [ActivityType] = [.walking, .running, .hiking, .biking]
        return HStack {
            ForEach(arr, id: \.self) { type in
                self.TextWithCircle(color: type.color(), title: type.name())
                .frame(minWidth: .zero, maxWidth: .infinity)
            }
        }
    }
}


//MARK: Extension Previews
struct Extension_Previews: View {
var body: some View {
    self.StatsView(value: "5h:45m:1sec",
                   title: "Duration",
                   tintColor: .blue)
            .frame(height: 40)
    }
}

struct Extension_Previews_Previews: PreviewProvider {
    static var previews: some View {
       Extension_Previews()
    }
}


extension View {
    @warn_unqualified_access
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
