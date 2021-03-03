//
//  SwiftUITestsApp.swift
//  SwiftUITests
//
//  Created by Alexander Golikov on 1/9/21.
//

import SwiftUI

@main
struct SwiftUITestsApp: App {
    @State var items = ["test", "test1", "test3"]
    var body: some Scene {
        WindowGroup {
            ContentView(/*items: $items*/)
        }
    }
}
