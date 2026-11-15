//
//  OnboardingPage.swift
//  Yogi Focus
//
//  Created by kartvasu on 14/12/2023.
//

import SwiftUI

struct OnboardingPage: View {
    var warp: String
    var yogi: String
    var subText: String = ""
    var subSubText: String = ""
    var mainMessage: String
    var ref: String = ""
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ZStack(alignment: .center)
            {
                Image(warp)
                VStack(alignment: .center, spacing: 0) {
                    Image(yogi)
                    Text("yogi").font(.custom("SAMARKAN", size: 64, relativeTo: .title)).foregroundColor(.primaryText)
                    Text("Focus").font(.custom("Inter", size: 24, relativeTo: .title)).foregroundColor(.primaryText)
                }
            }
            if (!subText.isEmpty) {
                Text(subText).font(.custom("Tiro Devanagari Sanskrit", size: 20)).foregroundStyle(.secondaryText).padding([.horizontal], 25).multilineTextAlignment(.center)
            }
            if (!subSubText.isEmpty) {
                Text(subSubText).font(.custom("Tiro Devanagari Sanskrit", size: 12, relativeTo: .title)).foregroundStyle(.secondaryText).padding([.horizontal], 25).multilineTextAlignment(.center)
            }
            Text(mainMessage).font(.custom("Inter-Regular", size: subText.isEmpty ? 24 : 20, relativeTo: .title)).lineSpacing(/*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/).padding([.horizontal], 25).multilineTextAlignment(.center).foregroundColor(.primaryText)
                .padding(EdgeInsets(top: subText.isEmpty ? 100 : 0, leading: 0, bottom: 0, trailing: 0))
            
                
            if (!ref.isEmpty) {
                Text(ref).font(.custom("Inter-Regular", size: 12, relativeTo: .title)).padding([.horizontal], 25).multilineTextAlignment(.trailing).foregroundColor(.secondaryText)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    OnboardingPage(warp: "Warp_Purple", yogi: "Yogi_Normal", mainMessage: "Test")
}
