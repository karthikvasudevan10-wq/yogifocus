//
//  ContentView.swift
//  Yogi Focus
//
//  Created by kartvasu on 11/12/2023.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @State private var selectedItem = 1
    var body: some View {
        VStack(alignment: .trailing) {
            Button(action: {
                self.selectedItem = 5
            }, label: {
                Text("Skip").font(.custom("Inter-Regular", size: 16))
            }).foregroundColor(.secondaryText)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 30))
                .opacity(self.selectedItem > 4 ? 0 : 1)
            TabView(selection: $selectedItem) {
                OnboardingPage(warp: "Warp_Green",
                               yogi: "Yogi_Normal",
                               subText: "स तु दीर्घकालनैरन्तर्यसत्कारासेवितो दृढभूमिः ||1.14||",
                               subSubText: "sa tu dīrghakālanairantaryasatkārādarāsevito dṛḍhabhūmiḥ",
                               mainMessage: "\"It is only when the correct practice is followed for a long time, without interruptions and with a quality of positive attitude and eagerness, that it can succeed.\"",
                               ref: "- Yoga Sūtras, Patañjali (2 Century BCE)"
                ).tag(1)
                OnboardingPage(warp: "Warp_Orange",
                               yogi: "Yogi_LookLeft",
                               mainMessage: "Master your goals with ancient techniques in just a few taps!"
                ).tag(2)
                OnboardingPage(warp: "Warp_Purple",
                               yogi: "Yogi_LookRight",
                               mainMessage: "Start by concentrating on one task for a targeted 10-minute session."
                ).tag(3)
                OnboardingPage(warp: "Warp_Pink",
                               yogi: "Yogi_Normal",
                               mainMessage: "Do the task daily in the same spot, exactly at the set time for 30 days."
                ).tag(4)
                OnboardingPage(warp: "Warp_Yellow",
                               yogi: "Yogi_ClosedEye",
                               mainMessage: "In 30 days, experience enhanced focus and better task outcomes."
                ).tag(5)
                
                TaskForm(
                ).tag(6).gesture(DragGesture())
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
            HStack(alignment: .center) {
                Text(String(self.selectedItem) + "/5").foregroundStyle(.secondaryText).padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 0))
                Spacer()
                Button(action: {
                    withAnimation
                    {
                        if (self.selectedItem < 6) {
                            
                            self.selectedItem = self.selectedItem + 1
                        }
                        if (self.selectedItem == 5) {
                            //Navigation Link
                            UserDefaults.standard.set(true, forKey: "_onboarded")
                        }
                        
                    }
                }, label: {
                    if (self.selectedItem < 5) {
                        Image(systemName: "arrow.forward").frame(width: 80, height: 80)
                    }
                    if (self.selectedItem == 5) {
                        Text("Get Started").font(.custom("Inter-Regular", size: 14)).frame(width: 180, height: 80)
                    }
                })
                .frame(width: self.selectedItem < 5 ? 80 : 180, height: self.selectedItem < 5 ? 80 : 80)
                    .foregroundColor(.primaryText)
                    .background(.primaryButtons)
                    .clipShape(self.selectedItem < 5 ? AnyShape(Circle()) : AnyShape(Capsule()))
                    
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 30))
            .opacity(self.selectedItem == 6 ? 0 : 1)
        }
    }
}

#Preview {
    OnboardingView()
}
