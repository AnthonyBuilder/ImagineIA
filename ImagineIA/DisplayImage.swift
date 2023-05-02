//
//  DisplayImage.swift
//  ImagineIA
//
//  Created by Anthony José on 04/04/23.
//

import SwiftUI


struct DisplayImage: View {
    
    @Binding var text: String
    @Binding var numberImages: Int
    
    @State private var urls: [Datum] = [Datum(url: "")]
    @State private var errorResult = OpenIAError(error: ErrorModel(message: "", type: ""))
    
    @State var columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
           Group {
               GeometryReader { geo in
                   ScrollView(showsIndicators: false) {
                       if errorResult.error.message != "" {
                           VStack(alignment: .center) {
                               Text("Sorry :(").font(.largeTitle).padding()
                               Text(errorResult.error.message)
                           }.padding()
                       } else {
                           LazyVGrid(columns: columns) {
                               ForEach(urls, id: \.self) { result in
                                   Color.clear.overlay(
                                    AsyncImage(url: URL(string: result.url), transaction: Transaction(animation: .easeInOut(duration: 0.5))) { phase in
                                        switch phase {
                                        case .success(let image):
                                            NavigationLink(destination: FullImageView(url: result.url)) {
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                            }
                                        case .empty:
                                            VStack() {
                                                ProgressView()
                                            }
                                        case .failure(_):
                                            Text(errorResult.error.message)
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
               }.onAppear() {
                   Task {
                       await APIOpenIA().generateImage(image: text, number: numberImages, completion: { result in
                           switch result {
                           case .success(let success):
                               self.urls = success.data ?? [Datum(url: "")]
                               print("success", success)
                           case .failure(let failure):
                               self.errorResult = failure
                               print("failure", failure)
                           }
                       })
                   }
               }
           }
    }
}

