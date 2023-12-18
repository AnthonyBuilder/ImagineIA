//
//  DisplayImage.swift
//  ImagineIA
//
//  Created by Anthony José on 04/04/23.
//

import SwiftUI

struct DisplayImage: View {
        
    @StateObject private var urls = ImagesURL.sharedSingleton
    @State var columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
           Group {
               GeometryReader { geo in
                   ScrollView(showsIndicators: false) {
                       if urls.errorResult.error.message != "" {
                           VStack(alignment: .center) {
                               Text("Sorry :(").font(.largeTitle).padding()
                               Text(urls.errorResult.error.message)
                           }.padding()
                       } else {
                           LazyVGrid(columns: columns) {
                               ForEach(self.urls.urls, id: \.self) { result in
                                   Color.clear.overlay(
                                    AsyncImage(url: URL(string: result.url), transaction: Transaction(animation: .easeInOut(duration: 0.5))) { phase in
                                        switch phase {
                                        case .success(let image):
                                            NavigationLink(destination: FullImageView(image: image)) {
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                            }
                                        case .empty:
                                            VStack() {
                                                ProgressView()
                                            }
                                        case .failure(_):
                                            Text(urls.errorResult.error.message)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                   )
                                   .frame(maxWidth: .infinity)
                                   .aspectRatio(1, contentMode: .fit) // << for square !!
                                   .clipped()
                               }
                               
                           }.padding(5)
                       }
                   }
               }
               Spacer()
               
               VStack {
                   BannerAd(unitID: "ca-app-pub-8762893864776699/1465324983")
               }.frame(height: 70)
           }
    }
}
