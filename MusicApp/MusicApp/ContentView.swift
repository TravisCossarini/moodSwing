//
//  ContentView.swift
//  MusicApp
//
//  Created by Hannah  Keefe  on 2021-01-17.
//

import SwiftUI
import Firebase

struct Album : Hashable {
    var id = UUID()
    var name : String
    var image : String
    var songs : [Song]
}

struct Song : Hashable {
    var id = UUID()
    var name : String
    var time : String
    var file : String
}

struct ContentView : View {
    @ObservedObject var data : OurData
    @State private var currentAlbum : Album?
   
  //  var currentAlbum : Album?
    var body: some View {
        NavigationView{
            ScrollView {
                ScrollView(.horizontal, showsIndicators: false, content: {
                    LazyHStack {
                        ForEach(self.data.albums, id:\.self, content: {
                            album in
                            AlbumArt(album: album, isWithText: true).onTapGesture {
                                self.currentAlbum = album
                            }
                        })
                    }
                })
               LazyVStack {
                if self.data.albums.first == nil {
                    EmptyView()
                } else {
                    ForEach((self.currentAlbum?.songs ?? self.data.albums.first?.songs) ?? [Song(name: "", time: "", file: "")],
                                    id: \.self,
                                    content: {
                                    song in
                                        SongCell(album: currentAlbum ?? self.data.albums.first!, song: song)
                            })
                        }
            
                    }
            }.navigationTitle("Mood PlayLists")
        }
    }
}


struct AlbumArt : View {
    var album : Album
    var isWithText : Bool
    var body : some View {
        ZStack (alignment: .bottom, content: {
            Image(album.image).resizable().aspectRatio(contentMode: .fill).frame(width: 170.0, height: 200.0, alignment: .center)
             
            if isWithText == true {
                ZStack {
                    Blur(style: .dark)
                    Text(album.name).foregroundColor(.white)
                }.frame(height: 60, alignment: .center)
            }
        }).frame(width: 170.0, height: 200.0, alignment: . center).clipped().cornerRadius(20).shadow(radius: 10).padding(20)
    }
}

struct SongCell :  View {
    var album : Album
    var song : Song
    var body : some View {
        // so for when the player view is called, feed the player view and song
       NavigationLink(destination: PlayerView(album: album, song: song), label: {
            HStack {
                ZStack {
                    Circle().frame(width: 50, height: 50, alignment: .center).foregroundColor(.blue)
                    Circle().frame(width: 20, height: 20, alignment: .center).foregroundColor(.white)
                }
                Text(song.name).bold()
                Spacer()
                Text(song.time)
            }.padding(20)
        }).buttonStyle(PlainButtonStyle())
    }
}
