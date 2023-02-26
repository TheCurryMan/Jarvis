//
//  ScreenshotView.swift
//  Screenshot Analysis
//
//  Created by Avinash Jain on 2/25/23.
//

import SwiftUI
import UIImageColors
import Vision

struct ScreenshotView: View {
    @Binding var selectedScreenshot: Screenshot?
    @State var selectedAnalysis: ScreenshotAnalysisType?
    @State var color: UIColor?
    @State var text: [String]?
    
    
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            return
        }
        let recognizedStrings = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            return observation.topCandidates(1).first?.string
        }
        
        // Process the recognized strings.
        text = recognizedStrings
    }
    
    func analyzeColor() {
        if (color == nil) {
            setColor(image: (selectedScreenshot?.image)!, color: &color)
        }
        selectedAnalysis = .color
    }
    
    func analyzeWords() {
        if (text == nil) {
            setText(image: (selectedScreenshot?.image)!, completionHandler: recognizeTextHandler)
        }
        selectedAnalysis = .words
    }
    
    func analyzeNumbers() {
        if (text == nil) {
            setText(image: (selectedScreenshot?.image)!, completionHandler: recognizeTextHandler)
        }
        selectedAnalysis = .numbers
    }
    
    func resetAnalysis(screenshot: Screenshot?) {
        text = nil
        color = nil
        selectedAnalysis = nil
    }
    
    var body: some View {
        ZStack {
            if (selectedScreenshot == nil) {
                Text("Select or take a Screenshot")
            } else {
                if ((selectedScreenshot?.image) != nil) {
                    VStack() {
                        VStack(spacing: 20.0) {
                            Image(nsImage: (selectedScreenshot?.image)!).resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(10.0)
                                .padding(.horizontal, 50).padding(.top, 20.0).frame(idealHeight: 200, maxHeight: 300)
                            //                            VStack() {
                            //                                Text((selectedScreenshot?.name)!).multilineTextAlignment(.leading)
                            //                            }
                            
                            HStack(spacing: 10.0){
                                Button(action: {analyzeColor()}, label: {
                                    Image(systemName: "paintpalette.fill").foregroundColor(selectedAnalysis == .color ? Color.blue : Color.primary)}).controlSize(.large)
                                    .keyboardShortcut("c", modifiers: .shift)
                                Button(action: {analyzeWords()}, label: {
                                    Image(systemName: "text.word.spacing").foregroundColor(selectedAnalysis == .words ? Color.blue : Color.primary)}).controlSize(.large)
                                    .keyboardShortcut("s", modifiers: .shift)
                                Button(action: {analyzeNumbers()}, label: {
                                    Image(systemName: "number.square.fill").foregroundColor(selectedAnalysis == .numbers ? Color.blue : Color.primary)}).controlSize(.large)
                                    .keyboardShortcut("x", modifiers: .shift)
                            }
                            
                            if ((color) != nil && selectedAnalysis == .color) {
                                HStack(spacing: 30.0) {
                                    ZStack {
                                        Color.init(cgColor: color!.cgColor)
                                    }.frame(width: 100.0, height: 100.0).cornerRadius(20.0)
                                    if (color!.components() != nil) {
                                        VStack(alignment: .leading, spacing: 10.0) {
                                            Text("" + (color!.components()!.0.css ?? "N/A")).textSelection(.enabled).font(Font.title)
                                            Text("" + ("rgb(\(color!.components()!.1.red.formatted()), \(color!.components()!.1.green.formatted()), \(color!.components()!.1.blue.formatted()))")).textSelection(.enabled).font(Font.title)
                                        }
                                    }
                                }
                            }
                            if ((text) != nil && selectedAnalysis == .words) {
                                VStack(alignment: .leading, spacing: 10.0) {                                  
                                    Text("Character Count: " + (text?.wordAnalysis().characterCount.formatted())!).textSelection(.enabled).font(Font.title)
                                    Text("Word Count: " + (text?.wordAnalysis().wordCount.formatted())!).textSelection(.enabled).font(Font.title)
                                }
                            }
                            if ((text) != nil && selectedAnalysis == .numbers) {
                                VStack(alignment: .leading, spacing: 10.0) {
                                    Text("Numbers: " + (text?.numberAnalysis().numbersFound)!).textSelection(.enabled)
                                    Text("Sum: " + (text?.numberAnalysis().sum.formatted())!).textSelection(.enabled).font(Font.title)
                                    Text("Average: " + (text?.numberAnalysis().average.formatted())!).textSelection(.enabled).font(Font.title)
                                }
                            }
                            
                        }
                        Spacer()
                    }.onChange(of: selectedScreenshot, perform: resetAnalysis)
                    
                } else {
                    Text("No Screenshot selected!")
                }
            }
        }
    }
}
