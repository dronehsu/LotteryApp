//
//  LotteryAppApp.swift
//  LotteryApp
//
//  Created by 徐榮彬 on 2026/9/15.
//

import SwiftUI

@main
struct LotteryAppApp: App {
    @State private var store = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .task { await store.start() }
        }
    }
}
