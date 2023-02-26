//
//  SidebarView.swift
//  Screenshot Analysis
//
//  Created by Avinash Jain on 2/25/23.
//

import SwiftUI

struct SidebarView: View {
    @Binding var screenshots: [Screenshot]
    @Binding var selectedScreenshot: Screenshot?
    
    var body: some View {
        VStack{
            List(selection: $selectedScreenshot) {
                Section("SCREENSHOTS") {
                    
                    ForEach(screenshots, id: \.self) { screenshot in
                        Text(screenshot.name)
                    }
                }
            }
            .listStyle(.sidebar)
        }
        Button(action: {addScreenshot(screenshots: &screenshots, selectedScreenshot: &selectedScreenshot)}, label: {
            Image(systemName: "plus.app")}).padding(10)
        Spacer()
        Spacer()
    }
    
}
