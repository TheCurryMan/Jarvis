//
//  ContentView.swift
//  Screenshot Analysis
//
//  Created by Avinash Jain on 2/25/23.
//

import SwiftUI

struct ContentView: View {
    @State var screenshots: [Screenshot] = []
    @State var selectedScreenshot:Screenshot? = nil
    
    init(screenshots: [Screenshot]? = nil) {
        let screenshotOne = Screenshot(name: "test", type: .color)
        _screenshots = State(initialValue: [screenshotOne])
        _selectedScreenshot = State(initialValue: screenshotOne)
    }
    
    
    var body: some View {
        NavigationView {
            SidebarView(screenshots: $screenshots, selectedScreenshot: $selectedScreenshot)
            VStack{
                ScreenshotView(selectedScreenshot: $selectedScreenshot)
            }
            
        }
        .frame(
            minWidth: 700,
            idealWidth: 1000,
            maxWidth: 1000,
            minHeight: 400,
            idealHeight: 800,
            maxHeight: 800)
    }
}

struct ContentView_Previews: PreviewProvider {
    var screenshotOne = Screenshot(name: "Test Screenshot", type: .color)
    
    static var previews: some View {
        ContentView()
    }
}
