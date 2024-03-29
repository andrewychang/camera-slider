//
//  ContentView.swift
//  Camera Slider
//
//  Created by Andrew Chang on 10/23/19.
//  Copyright © 2019 Andrew Chang. All rights reserved.
//

import Foundation
import SwiftUI
import CoreBluetooth
import UIKit


struct ContentView: View {
    @ObservedObject var bleConnection = BLEConnection()
    @EnvironmentObject var data: DataObject
    @State var showAlert: Bool = false
    @State var showAlert1: Bool = false
    @State var showAlert2: Bool = false
    @State var showAlert3: Bool = false
    @State var specAlert: ActiveAlert3 = .first
    @State var startAlert: ActiveAlert2 = .first
    @State var timeRemaining = 40
    @State var expand = false
    @State var xExpand = 100
    @State var yExpand = -250
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let numberFormatter = NumberFormatter.numberFormatter()
    private let numberFormatterWithDecimals = NumberFormatter.numberFormatter(maxDecimalPlaces: 2, minDecimalPlaces: 0)
    var rangeSlider = RangeSlider()
    var timeSlider = ColorUISlider(color: UIColor(red: 165/255, green: 0, blue: 0, alpha: 1), value: .constant(0.5))
    @State var confirmedStart: String = "--"
    @State var confirmedEnd: String = "--"
    @State var confirmedTime: String = "--"
    var body: some View {
        ZStack{
            VStack(spacing: 0) {
                Rectangle()
                    .frame(width: 500, height: 220)
                    .foregroundColor(.clear)
                    .background(LinearGradient(gradient: Gradient(colors: [Color("color6"), Color("color5")]), startPoint: .leading, endPoint: .trailing))
                Rectangle()
                    .foregroundColor(Color.white)
            }
            VStack(spacing: 20) {
                    Text("Camera Slider")
                    .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                    .font(.custom("Montserrat-Bold", size: 50))
                        .offset(y: 10)
                    .frame(width: 300, height: 130, alignment: .leading)
                    .offset(x: -10)
                
                HStack(spacing: 20){
                    VStack(spacing: 20) {
                        Text("Start")
                        .font(.custom("Montserrat-Bold", size: 30))
                        Text(confirmedStart)
                        .font(.custom("Montserrat-Bold", size: 20))
                    }
                    .frame(width: 90, height: 100)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    
                    
                    VStack(spacing: 20) {
                        Text("End")
                        .font(.custom("Montserrat-Bold", size: 30))
                        Text(confirmedEnd)
                        .font(.custom("Montserrat-Bold", size: 20))
                    }
                    .frame(width: 90, height: 100)
                    .shadow(radius: 10)
                    .cornerRadius(20)
                    
    
                    VStack(spacing: 20) {
                        Text("Time")
                        .font(.custom("Montserrat-Bold", size: 30))
                        Text(confirmedTime)
                        .font(.custom("Montserrat-Bold", size: 20))
                    }
                    .frame(width: 90, height: 100)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                
                    
                }
                .frame(width: 350, height: 130, alignment: .center)
                .background(LinearGradient(gradient: Gradient(colors: [Color("color4"), Color("color3")]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(20)
                .shadow(radius: 10)
                
                VStack(spacing: 30) {
                    rangeSlider
                        .offset(y:10)
                    VStack(spacing: 0) {
                    timeSlider
                        .padding()
                    Text("\(numberFormatter.string(from: data.time as NSNumber) ?? "") seconds")
                        .font(.custom("Montserrat-Bold", size: 12))
                    }
                    
                    Button(action: {
                        if self.bleConnection.connected == false {
                            self.specAlert = .first
                            self.showAlert.toggle()
                        } else{
                            if self.data.time > Double(abs((self.data.selectedMaxValue - self.data.selectedMinValue) * 500)) {
                                self.specAlert = .second
                                self.showAlert.toggle()
                            }
                            else if self.data.time < Double(abs((self.data.selectedMaxValue - self.data.selectedMinValue) * 4)) {
                                self.specAlert = .third
                                self.showAlert.toggle()
                            }
                            else {
                                self.confirmedStart = "\(self.numberFormatterWithDecimals.string(from: self.data.selectedMinValue as NSNumber) ?? "") m"
                                self.confirmedEnd = "\(self.numberFormatterWithDecimals.string(from: self.data.selectedMaxValue as NSNumber) ?? "") m"
                                self.confirmedTime = "\(self.numberFormatter.string(from: self.data.time as NSNumber) ?? "") s"
                                self.data.updateData()
                                print(self.data.bufferArray)
                                self.bleConnection.writeData(data: self.data.bufferArray)
                            }
                        }
                    }) {
                        Text("Set Specifications")
                            .fontWeight(.semibold)
                            .font(.custom("Montserrat-Light", size: 17))
                    }
                    .frame(width: 180, height: 40)
                    .foregroundColor(.black)
                    .background(LinearGradient(gradient: Gradient(colors: [Color("color6"), Color("color5")]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(20)
                    .offset(y: -10)
                    .buttonStyle(buttonAnimationStyle())
                    .alert(isPresented: $showAlert) {
                        switch specAlert {
                        case .first:
                            return Alert(title: Text("Bluetooth Not Connected"), message: Text("Connect to the camera slider via Bluetooth using the connect button before setting data"), dismissButton: .default(Text("Got it!")))
                        case .second:
                            return Alert(title: Text("Time is too long"), message: Text("The provided distance between start and end is too short for the provided time. Please either decrease the time or increase the distance"), dismissButton: .default(Text("Got it!")))
                        case .third:
                            return Alert(title: Text("Time is too Short"), message: Text("The provided distance between start and end is too long for the provided time. Please either increase the time or decrease the distance"), dismissButton: .default(Text("Got it!")))
                        }
                    }
                    
                }
                .frame(width: 350, height: 260, alignment: .center)
                .background(LinearGradient(gradient: Gradient(colors: [Color("color4"), Color("color3")]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(20)
                .shadow(radius: 10)
                
                
                
                // ForEach: Loop here to list all BLE Devices in "devices" array
                // Monitor "devices" array for changes. As changes happen, Render the Body again.
                Button(action: {
                    if self.bleConnection.bluetoothText == "Connect" {
                        self.startAlert = .first
                        self.showAlert1.toggle()
                    }
                    else if self.confirmedStart == "--" || self.confirmedEnd == "--" || self.confirmedTime == "--" {
                        self.startAlert = .second
                        self.showAlert1.toggle()
                        print("yes")
                    } else {
                        self.bleConnection.startCamera(data: self.data.oneBuffer)
                    }
                }) {
                    Text("Start Camera")
                        .fontWeight(.semibold)
                        .font(.custom("Montserrat-Light", size: 30))
                }
                .buttonStyle(buttonAnimationStyle())
                .frame(width: 350, height: 70, alignment: .center)
                .foregroundColor(.black)
                .background(LinearGradient(gradient: Gradient(colors: [Color("color6"), Color("color5")]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(20)
                .offset(y: 0)
                .shadow(radius: 10)
                .alert(isPresented: $showAlert1) {
                    switch startAlert {
                    case .first:
                        return Alert(title: Text("Bluetooth Not Connected"), message: Text("Connect to the camera slider via Bluetooth using the connect button before starting camera"), dismissButton: .default(Text("Got it!")))
                    case .second:
                        return Alert(title: Text("Specifications Not Set"), message: Text("Finish setting specification for start, end, and time before starting the camera slider"), dismissButton: .default(Text("Got it!")))
                    }
                
                }
            }
            VStack(spacing: 20) {
                HStack {
                Image("raspberrypi")
                   .resizable()
                   .frame(width: 55, height: 70)
                   .onTapGesture { self.expand.toggle() }
                   .padding()
                VStack{
                    Circle()
                        .fill(Color("\(self.bleConnection.greenIndicator)"))
                        .frame(width: 15, height: 15, alignment: .center)
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    Circle()
                        .fill(Color("\(self.bleConnection.redIndicator)"))
                        .frame(width: 15, height: 15, alignment: .center)
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                } .offset(x: -15)
                }
               if expand {
                   Button(action: {
                       if self.bleConnection.connected == false {
                       self.bleConnection.startCentralManager()
                           print(self.bleConnection.bluetoothText)
                       
                       } else {
                           self.bleConnection.disconnect()
                       }
                   }) {
                       Text(self.bleConnection.bluetoothText)
                           .font(.custom("Montserrat-Bold", size: 15))
                   }.offset(y: -20)
                    .buttonStyle(buttonAnimationStyle())
                .foregroundColor(Color.black)
                   Button(action: {
                    if self.bleConnection.connected == false {
                        self.startAlert = .second
                        self.showAlert2.toggle()
                    } else {
                        self.startAlert = .first
                        self.showAlert2.toggle()
                       self.bleConnection.reboot(data: self.data.oneBuffer)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                            self.bleConnection.startCentralManager()
                        }
                        }
                   }) {
                       Text("Reboot")
                        .font(.custom("Montserrat-Bold", size: 15))
                   } .offset(y: -20)
                    .foregroundColor(Color.black)
                    .buttonStyle(buttonAnimationStyle())
                    .alert(isPresented: $showAlert2) {
                        switch startAlert {
                        case .first:
                            return Alert(title: Text("Reboot Starting"), message: Text("Please wait 40 seconds for the Raspberry Pi to reboot and reconnect"), dismissButton: .default(Text("Got it!")))
                        case .second:
                            return Alert(title: Text("Bluetooth Not Connected"), message: Text("Must be connected to Raspberry Pi via bluetooth to reboot"), dismissButton: .default(Text("Got it!")))
                        }
                    }
                   Button(action: {
                    if self.bleConnection.connected == false {
                        self.showAlert3.toggle()
                    } else {
                        self.bleConnection.shutdown(data: self.data.oneBuffer)
                    }
                   }) {
                       Text("Shutdown")
                        .font(.custom("Montserrat-Bold", size: 15))
                   }.offset(y: -20)
                .foregroundColor(Color.black)
                .buttonStyle(buttonAnimationStyle())
                .alert(isPresented: $showAlert3) {
                    Alert(title: Text("Bluetooth Not Connected"), message: Text("Must be connected to Raspberry Pi via bluetooth to shut down"), dismissButton: .default(Text("Got it!")))
                }
               }
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color("color4"), Color("color3")]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20)
            .stroke(Color.black, lineWidth: 3))
            .offset(x: 120, y: self.expand ? -193 : -250)
            .animation(.spring())
        }
        .edgesIgnoringSafeArea(.all)
        .supportedOrientations(.portrait)
        }
        
}

struct buttonAnimationStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View { configuration.label
        .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().environmentObject(DataObject())
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
            .previewDisplayName("iPhone 8")
            ContentView().environmentObject(DataObject())
               .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
               .previewDisplayName("iPhone 11")

            ContentView().environmentObject(DataObject())
               .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro"))
               .previewDisplayName("iPhone 11 Pro")
        }
    }
}
#endif



enum ActiveAlert2 {
    case first, second
}

enum ActiveAlert3 {
    case first, second, third
}
