//
//  FullIMageVIew.swift
//  ImagineIA
//
//  Created by Anthony José on 05/04/23.
//

import Foundation
import SwiftUI

struct FullImageView: View {
    @State var image: Image
    
    init(image: Image) {
        self.image = image
    }
    
    var body: some View {
        Group {
            GeometryReader { geo in
                VStack(alignment: .center) {
                    image
                        .resizable()
                        .scaledToFit()
                        .modifier(ImageModifier(contentSize: CGSize(width: geo.size.width, height: geo.size.height)))
                    
                    ShareLink(item: image, preview: SharePreview("ImagineIA - \(Date())", image: image))
                }
            }
        }.onAppear() {
            Interstitial.shared.loadInterstitial()
            Interstitial.shared.showInterstitialAds()
        }
    }
}

