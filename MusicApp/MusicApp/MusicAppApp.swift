//
//  MusicAppApp.swift
//  MusicApp
//
//  Created by Hannah  Keefe  on 2021-01-17.
//

import SwiftUI
import Firebase

@main
struct MusicAppApp: App {
    let data = OurData()
    init() {
        FirebaseApp.configure()
        data.loadAlbums()
    }
    var body: some Scene {
        WindowGroup {
            //ContentView()
            ContentView(data: data)
        }
    }
}
