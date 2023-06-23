//
//  ContentView.swift
//  ImagineIA
//
//  Created by Anthony José on 29/03/23.
//

import SwiftUI
import CoreData
import PhotosUI
import SwiftUI
import OpenAIKit
import GoogleMobileAds

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            TabView {
                TextGenerateView().tabItem {
                    Label("Prompt Generation", systemImage: "character.cursor.ibeam")
                }
                
                GenerateImageVariationExample().tabItem {
                    Label("Image Variation", systemImage: "scribble.variable")
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct GenerateImageVariationExample: View {
    @State private var image: UIImage = UIImage()
    @State private var isGeneratingVariation: Bool = false
    
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }


    var body: some View {
        NavigationStack {
            ScrollView {
            
                Spacer()
                
                if isGeneratingVariation == true {
                    VStack {
                        ProgressView("Generating Image...")
                    }.onAppear() {
                        Interstitial.shared.loadInterstitial()
                        Interstitial.shared.showInterstitialAds()
                    }
                } else {
                    VStack {
                        Image(uiImage: self.image)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit) // << for square !!
                            .clipped()
                            .onAppear() {
                                Interstitial.shared.loadInterstitial()
                                Interstitial.shared.showInterstitialAds()
                            }
                        
                         Spacer()
                        
                        VStack {
                          BannerAd(unitID: "ca-app-pub-8762893864776699/6944583961")
                        }.frame(height: 70)
                    }
                }
                
                
            }
            .toolbar {
                PhotosPicker("Select images", selection: $selectedItems, maxSelectionCount: 1, matching: .images)
            }
            .onChange(of: selectedItems) { _ in
                Task {
                    selectedImages.removeAll()
                    for item in selectedItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            if let image = UIImage(data: data) {
                                isGeneratingVariation = true
                                
                                Task {
                                    do {
                                        let config = Configuration(
                                            organizationId: "personal",
                                            apiKey: "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"
                                        )
                                        let openAI = OpenAI(config)
                                        
                                        let imageVariationParam = try ImageVariationParameters(
                                            image: self.resizeImage(image: image, targetSize: CGSizeMake(500.0, 500.0))!,
                                            resolution: .medium,
                                            responseFormat: .base64Json
                                        )
                                        let variationResponse = try await openAI.generateImageVariations(
                                            parameters: imageVariationParam
                                        )
                                        
                                        self.image = try openAI.decodeBase64Image(
                                            variationResponse.data[0].image
                                        )
                                        
                                        isGeneratingVariation = false
                                    } catch {
                                        print("ERROR - \(error)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct GenerateImageVariationExample_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GenerateImageVariationExample()
        }
    }
}



struct TextGenerateView: View {
                        
    @State var inputImage: String = ""
    @State var numberImages: Int = 1
                        
    var body: some View {
        VStack(spacing: 10) {
            VStack(alignment: .center, spacing: 10) {
                Text("ImagineIA").font(.largeTitle)
                Text("Describe something you would like to see!").font(.title3).foregroundColor(.secondary).multilineTextAlignment(.center)
            }.padding()
                            
            if #available(iOS 15.0, *) {
                HStack(alignment: .center) {
                    TextField(text: $inputImage) { Text("Example: cat with hat") }
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color("FormDark")))
                        .padding(.leading)
                    
                    
                    VStack(alignment: .center) {
                        Picker("Choose how many images you want to generate", selection: $numberImages) {
                            ForEach(1..<11, id: \.self) {
                                Text("\($0)")
                            }
                        }
                        .padding(.trailing)
                        .pickerStyle(.wheel)
                        
                        
                    }.frame(width: 120, height: 100)
                }
            } else {
                // Fallback on earlier versions
                TextField("Example: cat with hat", text: $inputImage)
                    .padding(20)
                    .textFieldStyle(.roundedBorder)
                    .shadow(radius: 2)
            }
            
            VStack(alignment: .leading) {
                Text("Choose how many images you want to generate.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }.padding(5)
            
            NavigationLink(destination: DisplayImage(text: $inputImage, numberImages: $numberImages)) {
                    if inputImage == "" {
                        Text("Continue")
                           .foregroundColor(.white)
                           .padding(10)
                           .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray))
                    } else {
                        Text("Continue")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
                        
                    }
            }.disabled(inputImage == "")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
