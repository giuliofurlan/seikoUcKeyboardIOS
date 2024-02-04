//
//  ContentView.swift
//  seikoUcKeyboard
//
//  Created by Giulio Furlan on 27/01/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    let dataTransmitter = DataTransmitter()
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 10)
    let rows = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
   
    @State private var shifted = false
    
    var body: some View {
        var currentKeys = !shifted ? Keyboard.keys : Keyboard.shiftKeys
        
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(0..<70) { index in
                        let currentKey = currentKeys[index]
                        if(currentKey.text == "") { Text("").background(Color.black) }
                        else {
                            Button(currentKey.text) {
                                if(currentKey.value != nil) {
                                    dataTransmitter.transmit(input: currentKey.value!)
                                }
                                if(currentKey.text == "SFT") {
                                    self.shifted.toggle()
                                }
                            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 45)
                                .background(Color.blue)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(8)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }.background(Color.black)
        }
    }
}


#Preview { ContentView() }
