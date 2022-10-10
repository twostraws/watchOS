//
//  ContentView.swift
//  Project6 Watch App
//
//  Created by Paul Hudson on 07/10/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var redBackground = false
    
    var body: some View {
        VStack {
            Text("Hello, world!")
                .frame(width: 100, height: 100)
                .background(.red)
                .onAppear {
                    print(type(of: self.body))
                }
            
            Text("Hello, world!")
                .padding()
                .background(.red)
                .padding()
                .background(.blue)
                .padding()
                .background(.green)
                .padding()
                .background(.yellow)
            
            Text("Hello World")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(redBackground ? .red : .blue)
                .onTapGesture {
                    // flip the Boolean between true and false
                    redBackground.toggle()
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
