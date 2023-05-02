//
//  FullIMageVIew.swift
//  ImagineIA
//
//  Created by Anthony José on 05/04/23.
//

import Foundation
import SwiftUI

struct FullImageView: View {
    @State var url = ""
    
    var body: some View {
        Group {
            GeometryReader { geo in
                AsyncImage(url: URL(string: url), transaction: Transaction(animation: .easeInOut(duration: 0.5))) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .modifier(ImageModifier(contentSize: CGSize(width: geo.size.width, height: geo.size.height)))
                        
                        ShareLink(item: phase.image!, preview: SharePreview("ImagineIA - \(Date())", image: phase.image!))
                        
                    default:
                        ProgressView()
                    }
                }
            }
        }
    }
}
