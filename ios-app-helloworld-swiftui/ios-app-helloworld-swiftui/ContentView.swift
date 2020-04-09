//
//  ContentView.swift
//  ios-app-helloworld-swiftui
//
//  Created by Hunter Lien on 4/9/20.
//  Copyright © 2020 Navisens. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {

    @State private var motionDnaString = String("MotionDna Location:\n\n\n\n\n\n")
    var body: some View {
        VStack{
            NavisensReceiver(motionDnaString: $motionDnaString)
            Text(motionDnaString)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
