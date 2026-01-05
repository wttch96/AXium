//
//  ContentView.swift
//  AXiumDemo
//
//  Created by Wttch on 2026/1/3.
//

import AppKit
import ApplicationServices
import AXium
import Combine
import SwiftUI

struct ContentView: View {
    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
    @State private var window: NSWindow? = nil
    @State private var image: NSImage? = nil
    @State private var text: String = ""
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            TextEditor(text: $text)
                .border(Color.gray, width: 1)
                .frame(height: 100)
                .padding()
            Text("Hello, world!")
            
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 1000)
            }

            Button("获取权限", action: {
                do {
                    let appId = "com.roadesign.Codyeapp"
                    // 如果程序没启动则启动程序, 使用 apple api
                    let appElement = AccessibilityApplication(withBundleIdentifier: appId)!
                    let element = appElement.findElement { element in
                        
                        element.role == .textArea || element.role == .textField
                    }
                    
                    element?.setValue(value: text)
                    
                    let moreInfoButton = appElement.findElement { element in
                        element.role == .button && element.description == "More Info"
                    }
                    print(moreInfoButton)
                    moreInfoButton?.perform(.press)
                    
                    Thread.sleep(forTimeInterval: 0.1)
                    
                    // 异步点击菜单项
                    
                    let window1 = try appElement.findElement { element in
                        do {
                            return try element.role == .menuItem && element.title?.contains("Copy to Clipboard") ?? false
                        } catch {
                            return false
                        }
                    }
                    Task.runDetached {
                        try window1?.perform(.press)
                    }
                    
                    // 当前应用前置
                    NSApp.windows.first?.makeKeyAndOrderFront(nil)
                
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.image = getImageFromPasteboard()
                    }
                    
                } catch {
                    print(error.localizedDescription)
                }
            })
        }
        .padding()
        .onReceive(timer, perform: { _ in
            
        })
    }
}

func getImageFromPasteboard() -> NSImage? {
    let pasteboard = NSPasteboard.general
    if let types = pasteboard.types, types.contains(.tiff) {
        if let data = pasteboard.data(forType: .tiff) {
            return NSImage(data: data)
        }
    }
    return nil
}

#Preview {
    ContentView()
}
