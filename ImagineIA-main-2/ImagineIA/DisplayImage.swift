//
//  DisplayImage.swift
//  ImagineIA
//
//  Created by Anthony José on 04/04/23.
//

import SwiftUI

fileprivate class ImagesURL: ObservableObject {
    @Published var urls: [Datum] = [Datum(url: "")]
}


struct DisplayImage: View {
    
    @Binding var text: String
    @Binding var numberImages: Int
    
    @ObservedObject private var urls = ImagesURL()
    
    @State private var errorResult = OpenIAError(error: ErrorModel(message: "", type: ""))
    
    @State var columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init(text: Binding<String>, numberImages: Binding<Int>, errorResult: OpenIAError = OpenIAError(error: ErrorModel(message: "", type: "")), columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]) {
        self._text = text
        self._numberImages = numberImages
        self.errorResult = errorResult
        self.columns = columns
        
        getData()
    }
    
    
    func getData() {
        Task {
            await APIOpenIA().generateImage(image: text, number: numberImages, completion: { result in
                switch result {
                case .success(let success):
                    self.urls.urls = success.data!
                    print("success", success)
                case .failure(let failure):
                    self.errorResult = failure
                    print("failure", failure)
                }
            })
        }
    }
    
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
               }
               
               Spacer()
               
               VStack {
                 BannerAd(unitID: "ca-app-pub-8762893864776699/6944583961")
               }.frame(height: 70)
           }
    }
}
