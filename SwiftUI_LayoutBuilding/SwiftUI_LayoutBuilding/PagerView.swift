//
//  PagerView.swift
//  SwiftUI_LayoutBuilding
//
//  Created by JaneshSwift.com on 29/08/22.
//

import SwiftUI

struct PageView: View {
    var body: some View {
        TabView {
            ForEach(0..<2) { i in
                ZStack {
                    Color.white
                    VStack {
                        HStack() {
                            Image(systemName: "laptopcomputer")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 70)
                                .foregroundColor(.pink)
                            VStack(alignment: .leading, spacing: 0) {
                                // Spacer()
                                Text("Macbook Exclusive Offer")
                                    .padding(.leading,10)
                                    .foregroundColor(.black)
                                HStack{
                                    Text("$1000")
                                        .strikethrough(true, color: .black)
                                        .padding(.leading,10).font(.caption)
                                    Text ("$700")
                                        .font(Font.headline.weight(.semibold))
                                    Text ("30% off")
                                        .font(Font.body.weight(.light))
                                        .foregroundColor(.green)
                                    
                                }
                                .foregroundColor(.black)
                                //Spacer()
                                .frame(height: 50)
                            }
                        }
                        Divider()
                        Text("Get 5% instant Cashback up to ₹6,000 with qualifying credit cards. Terms apply. The all-new MacBook Air")
                            .font(.system(size: 10))
                    }
                    
                }
                .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))                
            }
            .padding([.all], 10)
        }
        .frame(maxHeight: .infinity)
        .frame(width: UIScreen.main.bounds.width)
        .tabViewStyle(PageTabViewStyle())
        .background(Color.red)
        .onAppear {
            setupAppearanceForPager()
        }
    }
    
    func setupAppearanceForPager() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView()
    }
}
