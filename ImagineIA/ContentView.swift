//
//  ContentView.swift
//  ImagineIA
//
//  Created by Anthony José on 29/03/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @State var inputImage: String = ""
    @State var numberImages: Int = 1
    
    var body: some View {
        NavigationView {
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
                
//                VStack {
//                    BannerAd(unitID: "ca-app-pub-3940256099942544/2934735716")
//                }.frame(height: 70)
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
