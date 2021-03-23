//
//  ContentView.swift
//  MusicApp
//
//  Created by Hannah  Keefe  on 2021-01-17.
//

import SwiftUI
import Firebase
import UIKit
import Vision
import CoreML
import CoreBluetooth

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
                NavigationLink(destination: MoodChoice(Mood: Mood, data:data)){
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
    // initialize stress to being false
    @State var stressed = false
    // neutral is 0
    @State private var firstAlbum : Album?
   // @State private var happysong = Song?
    @State var Mood = 0
   // @State var stressed : Int
    @ObservedObject var data : OurData
    //self.run_model()
    var body: some View {
        Text("How do you want to feel?").font(.title)
        //NavigationView {
        VStack {
            Image("Logo").resizable().aspectRatio(contentMode: .fill).frame(width: 250.0, height: 300.0, alignment: .center).offset(y: 0.1).padding(.bottom, 5)
           if Mood == 0 {
                SongCell(toggle : true, stressed: stressed, album: self.data.albums[0], song: self.data.albums[0].songs[0], data: data)
            }
            }.onAppear() {
                // NOT STRESSED DATA
                // [78.33547663797935, 765.936489762931, 34.41605920305109, 31.22258423691327, 43.055714690716115, 0.6328293736501079, 0.10367170626349892, 19.53125, 30.4445295775368, 37.78252635849141, 3613.683681099977, 0.8057833213340581, 0.0985410296692963]
                // STRESSED DATA
                // [89.90187639869168, 667.3943014705883, 135.41305465423056, 34.80621351882085, 51.67483029423028, 0.5, 0.2222222222222222, 50.78125, 36.35355106331697,     113.98250381622292, 13017.71937556236, 0.3189397481733756, 0.0441033783187792]
                stressed = self.run_model(numbers: [89.90187639869168, 667.3943014705883, 135.41305465423056, 34.80621351882085, 51.67483029423028, 0.5, 0.2222222222222222, 50.78125, 36.35355106331697,     113.98250381622292, 13017.71937556236, 0.3189397481733756, 0.0441033783187792])
                print("*****")
                print(stressed)
                print("*****")
        }
    }
    func run_model(numbers: [Float]) -> Bool{
        print(numbers)
        let model = MoodSwing_Final()
        guard let mlMultiArray = try? MLMultiArray(shape:[13], dataType:MLMultiArrayDataType.double) else {
            print("ERROR")
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        for (index, element) in numbers.enumerated() {
            mlMultiArray[index] = NSNumber(floatLiteral: Double(element))
        }
        
        guard let Output = try? model.prediction(i:  mlMultiArray)
        else {
            print("ERROR")
            fatalError("Unexpected runtime error.")
        }
        print(Output.Output)
        if( Output.Output == 1){
            return true
        } else {
            return false
        }
    }
}
        
class HRMManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager!
    var heartRatePeripheral: CBPeripheral!
    var count = 0
    @Published var last10:[Int] = [0,0,0,0,0,0,0,0,0,0]
    @Published var hr = "-"
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
}
    let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
    let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")
    
    
}
extension HRMManager {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
      case .unknown:
        print("central.state is .unknown")
      case .resetting:
        print("central.state is .resetting")
      case .unsupported:
        print("central.state is .unsupported")
      case .unauthorized:
        print("central.state is .unauthorized")
      case .poweredOff:
        print("central.state is .poweredOff")
      case .poweredOn:
        print("central.state is .poweredOn")
        centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
    }
    
  }
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                      advertisementData: [String: Any], rssi RSSI: NSNumber) {
    print(peripheral)
    hr = "scanning for HR"
    heartRatePeripheral = peripheral
    heartRatePeripheral.delegate = self
    centralManager.stopScan()
    centralManager.connect(heartRatePeripheral)
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    hr = "Connected to sensor!"
    print("Connected!")
    heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
    //heartRatePeripheral.discoverServices(nil)
  }
}

extension HRMManager: CBPeripheralDelegate {
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }
    hr = "Scanning for data"
    for service in services {
      print(service)
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                  error: Error?) {
    guard let characteristics = service.characteristics else { return }

    for characteristic in characteristics {
      print(characteristic)
      if characteristic.properties.contains(.read) {
        //print("\(characteristic.uuid): properties contains .read")
      }
      if characteristic.properties.contains(.notify) {
        //print("\(characteristic.uuid): properties contains .notify")
        peripheral.setNotifyValue(true, for: characteristic)
      }

    }
  }
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                  error: Error?) {
    switch characteristic.uuid {
      case bodySensorLocationCharacteristicCBUUID:
        print(characteristic.value ?? "no value")
      case heartRateMeasurementCharacteristicCBUUID:
        let bpm = heartRate(from: characteristic)
        hr = bpm
        last10[count] = Int(bpm) ?? 0
        count+=1
        if count >= 10 {
            count = 0
        }
            
        //onHeartRateReceived(bpm)
        //let data = Data(characteristic.value!)
        //let arr = [UInt8](data)
        //print(arr)
      default:
        print("Unhandled Characteristic UUID: \(characteristic.uuid)")
    }
  }

  private func heartRate(from characteristic: CBCharacteristic) -> String {
    guard let characteristicData = characteristic.value else { return "Fail" }
    let byteArray = [UInt8](characteristicData)
    print(byteArray)
    let firstBitValue = byteArray[0] & 0x01
    if firstBitValue == 0 {
      // Heart Rate Value Format is in the 2nd byte
      return String(Int(byteArray[1]))
    } else {
      // Heart Rate Value Format is in the 2nd and 3rd bytes
      return String((Int(byteArray[1]) << 8) + Int(byteArray[2]))
    }
  }

    public func last10String()->String{
        var printable = ""
        for i in last10{
            printable += String(i) + " "
        }
        return printable
    }
  }

    
// Where the heart rate stuff would go
struct HeartRate : View {
    @ObservedObject var HeartRate = HRMManager()
    var body: some View {
        VStack {
            Text(HeartRate.last10String()).frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Text(HeartRate.hr).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
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
                                //print(album)
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
                                        SongCell(toggle: false, stressed: false, album: currentAlbum ?? self.data.albums.first!, song: song, data: data)
                                      
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
    // variable
    var toggle : Bool
    var stressed : Bool
    var album : Album
    var song : Song
    @ObservedObject var data : OurData
    @State var showDetail: Bool = false
    @State private var displayPopupMessage: Bool = false
    @State private var Happy: Bool = false
    @State private var Relaxed: Bool = false
    @State private var flag : Bool = false
    //@State var mood : String
    var body : some View {
        // so for when the player view is called, feed the player view and song
        // if we are not trying to diagnose users mood, just load and play songs
        if( toggle == false) {
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
        } else {
           // displayPopupMessage = true
            if (stressed == true) {
                VStack {
                    NavigationLink(destination: PlayerView(album: self.data.albums[0], song: self.data.albums[0].songs[0]),isActive: self.$showDetail) {
                        EmptyView()
                    }
                    Button(action : {
                        self.displayPopupMessage = true
                        self.Happy = true
                        })
                
                    { Text("Happy").font(.title).foregroundColor(.white).frame(height: 40).padding(.horizontal, 40).background(RoundedRectangle(cornerRadius: 8).fill(Color.yellow))
                    }.padding(15).alert(isPresented: $Happy) {
                        Alert(title: Text("Sensing you are Unhappy"), message: Text("Happy Playlist will begin playing"), dismissButton:  .default(Text("OK"), action: {
                            print("OK CLICK")
                            self.showDetail = true
                            })
                        )
                    }
                }
                VStack {
                    NavigationLink(destination: PlayerView(album: self.data.albums[1], song: self.data.albums[1].songs[0]),isActive: self.$showDetail) {
                        EmptyView()
                    }
                    Button(action : {
                        self.displayPopupMessage = true
                        self.Relaxed = true
                        })
                
                    { Text("Relaxed").font(.title).foregroundColor(.white).frame(height: 40).padding(.horizontal, 40).background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
                    }.padding(15).alert(isPresented: $Relaxed) {
                        Alert(title: Text("Sensing you are Stressed"), message: Text("Relaxing playlist will begin playing"), dismissButton:  .default(Text("OK"), action: {
                            print("OK CLICK")
                            self.showDetail = true
                            })
                        )
                    }
                }
           } else {
                VStack {
                    Button(action : {
                        self.flag = true
                        })
                    {
                        Text("Happy").font(.title).foregroundColor(.white).frame(height: 40).padding(.horizontal, 40).background(RoundedRectangle(cornerRadius: 8).fill(Color.yellow))
        
                    }.padding(15)
                    Button(action : {
                        self.flag = true
                    })
                    {
                        Text("Relaxed").font(.title).foregroundColor(.white).frame(height: 40).padding(.horizontal, 40).background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
                    }.padding(15)
                } .padding(55).alert(isPresented: $flag) {
                    Alert(title: Text("You are currently not stressed!"), message: Text("You can browse playlist section if you are looking for music."), dismissButton: .default(Text("OK"), action: {
                        print("OK CLICK")
                        })
                    )
                }
           }
        }
    }
}
