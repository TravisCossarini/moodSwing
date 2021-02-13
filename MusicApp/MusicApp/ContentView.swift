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

struct ContentView: View {
    @ObservedObject var data : OurData
    @State var Mood = 0
    let disciplines = ["Playlist"]
    var body: some View {
        Text("MoodSwing").font(.title).foregroundColor(.purple).background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
        NavigationView {
            VStack(alignment: .center) {
                Image("Logo").resizable().aspectRatio(contentMode: .fill).frame(width: 250.0, height: 300.0, alignment: .center).offset(y: 0.1).padding(.bottom, 5)
                NavigationLink(destination: MusicView(data: data)){
                    Text("View Playlist").font(.title).foregroundColor(.white).frame(height: 40).padding(.horizontal, 40).background(RoundedRectangle(cornerRadius: 8).fill(Color.purple))
                }.buttonStyle(PlainButtonStyle()).padding(10)
                // fill these in when we have more buttons/ views that we need
                NavigationLink(destination: MoodChoice(Mood: Mood)){
                    Text("Pick My Mood").font(.title).foregroundColor(.white).frame(height: 40).padding(.horizontal, 40).background(RoundedRectangle(cornerRadius: 8).fill(Color.purple))
                }.buttonStyle(PlainButtonStyle()).padding(10)
                NavigationLink(destination: HeartRate()){
                    Text("View My Heart Rate").font(.title).foregroundColor(.white).frame(height: 40).padding(.horizontal, 40).background(RoundedRectangle(cornerRadius: 8).fill(Color.purple))
                }.buttonStyle(PlainButtonStyle()).padding(10)
                
            }//.navigationTitle("Welcome!")
        }
    }
}

// Where the user would select mood choice!
struct MoodChoice : View {
    // neutral is 0
    @State var Mood = 0
   
    var body: some View {
        Text("How do you want to feel?")
        VStack{
        Button {
            // happy is 1
            Mood = 1
            print(Mood)
           // print("Happy button is pressed")
        } label : {
            Text("Happy").font(.title).foregroundColor(.white).frame(height: 40).padding(.horizontal, 40).background(RoundedRectangle(cornerRadius: 8).fill(Color.yellow))
                .padding(20)
        }.buttonStyle(PlainButtonStyle())
        
        Button {
            // relaxed is 2
            Mood = 2
            print(Mood)
        } label : {
            Text("Relaxed").font(.title).foregroundColor(.white).frame(height: 40).padding(.horizontal, 40).background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
                .padding(20)
        }.buttonStyle(PlainButtonStyle())
        Button {
            // happy is 1
            Mood = 0
            print(Mood)
            // print("Happy button is pressed")
        } label : {
            Text("Neutral").font(.title).foregroundColor(.white).frame(height: 40).padding(.horizontal, 40).background(RoundedRectangle(cornerRadius: 8).fill(Color.green))
                    .padding(20)
        }.buttonStyle(PlainButtonStyle())
        }
    }
}

// Where the heart rate stuff would go
struct HeartRate : View {
    var body: some View {
        Text("Current Heart Rate")
    }
}

struct MusicView : View {
    @ObservedObject var data : OurData
    @State private var currentAlbum : Album?
   
  //  var currentAlbum : Album?
    var body: some View {
       // NavigationView{
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
            }.navigationTitle("Playlists")
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
