//
//  NavisensReceiver.swift
//  iOS-app-helloworld-TomTom
//
//  Created by Hunter Lien on 1/15/20.
//  Copyright © 2020 Navisens. All rights reserved.
//

import Foundation
import SwiftUI
import MotionDnaSDK
import Combine

func motionTypeToString(motionType: MotionType ) -> String? {
    switch (motionType) {
    case STATIONARY:
        return "STATIONARY";
    case FIDGETING:
        return "FIDGETING";
    case FORWARD:
        return "FORWARD";
    default:
        return "UNKNOWN MOTION";
    }
}

struct MotionData {
    var id:String
    var deviceName:String
    var location:Location
    var motionType:MotionType
}



struct NavisensReceiver: UIViewControllerRepresentable {
    
    @Binding var motionDnaString: String
    var manager = MotionDnaManager()
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<NavisensReceiver>) -> UIViewController {
        NSLog("Started receiver")
        startMotionDna()
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavisensReceiver>) {
    
    }
    
    typealias UIViewControllerType = UIViewController
    
    func receive(_ motionDna: MotionDna!) {
        let location = motionDna.getLocation()
        let localLocation = location.localLocation
        let globalLocation = location.globalLocation
        let motion = motionDna.getMotion()

        let motionDnaLocalString = String(format:"Local XYZ Coordinates (meters) \n(%.2f,%.2f,%.2f)",localLocation.x,localLocation.y,localLocation.z)
        let motionDnaHeadingString = String(format:"Current Heading: %.2f",location.heading)
        let motionDnaGlobalString = String(format:"Global Position: \n(Lat: %.6f, Lon: %.6f)",globalLocation.latitude,globalLocation.longitude)
        let motionDnaMotionTypeString = String(format:"Motion Type: %@",motionTypeToString(motionType: motion.motionType)!)

        guard let classifiers = motionDna.getClassifiers() else {
            return;
        }
        var motionDnaPredictionString = "Predictions (BETA):\n"
        
        for (classifierName, classifier) in classifiers {
            motionDnaPredictionString.append(String(format: "Classifier: %@\n", classifierName))
            motionDnaPredictionString.append(String(format: "\t prediction: %@ confidence: %.2f\n", classifier.currentPredictionLabel,classifier.currentPredictionConfidence))
                
            for (predictionLabel, predictionStats) in classifier.predictionStats {
                motionDnaPredictionString.append(String(format: "\t%@\n", predictionLabel))
                motionDnaPredictionString.append(String(format: "\t duration: %.2f\n", predictionStats.duration))
                motionDnaPredictionString.append(String(format: "\t distance: %.2f\n", predictionStats.distance))
            }
            motionDnaPredictionString.append("\n")
        }
        
        motionDnaString = String(format:"MotionDna Location:\n%@\n%@\n%@\n%@\n%@",motionDnaLocalString,
                                     motionDnaHeadingString,
                                     motionDnaGlobalString,
                                     motionDnaMotionTypeString,
                                     motionDnaPredictionString)
    }
    
    func receiveNetworkData(_ motionDna: MotionDna!) {
    
    }
    
    func receiveNetworkData(_ opcode: NetworkCode, withPayload payload: [AnyHashable : Any]!) {

    }
    
    func startMotionDna() {

            manager.receiver = self;

            //    This functions starts up the SDK. You must pass in a valid developer's key in order for
            //    the SDK to function. IF the key has expired or there are other errors, you may receive
            //    those errors through the reportError() callback route.
            
            manager.runMotionDna("_INSERT_YOUR_KEY_HERE_")

            //    Use our internal algorithm to automatically compute your location and heading by fusing
            //    inertial estimation with global location information. This is designed for outdoor use and
            //    will not compute a position when indoors. Solving location requires the user to be walking
            //    outdoors. Depending on the quality of the global location, this may only require as little
            //    as 10 meters of walking outdoors.

            manager.setLocationNavisens()


            //   Set accuracy for GPS positioning, states :HIGH/LOW_ACCURACY/OFF, OFF consumes
            //   the least battery.

            manager.setExternalPositioningState(LOW_ACCURACY)

            //    Manually sets the global latitude, longitude, and heading. This enables receiving a
            //    latitude and longitude instead of cartesian coordinates. Use this if you have other
            //    sources of information (for example, user-defined address), and need readings more
            //    accurate than GPS can provide.
    //        manager.setLocationLatitude(37.787582, longitude: -122.396627, andHeadingInDegrees: 0.0)

            //    Set the power consumption mode to trade off accuracy of predictions for power saving.

            manager.setPowerMode(PERFORMANCE)

            //    Connect to your own server and specify a room. Any other device connected to the same room
            //    and also under the same developer will receive any udp packets this device sends.

            manager.startUDP()

            //    Allow our SDK to record data and use it to enhance our estimation system.
            //    Send this file to support@navisens.com if you have any issues with the estimation
            //    that you would like to have us analyze.

            manager.setBinaryFileLoggingEnabled(true)

            //    Tell our SDK how often to provide estimation results. Note that there is a limit on how
            //    fast our SDK can provide results, but usually setting a slower update rate improves results.
            //    Setting the rate to 0ms will output estimation results at our maximum rate.

            manager.setCallbackUpdateRateInMs(500)

            //    When setLocationNavisens is enabled and setBackpropagationEnabled is called, once Navisens
            //    has initialized you will not only get the current position, but also a set of latitude
            //    longitude coordinates which lead back to the start position (where the SDK/App was started).
            //    This is useful to determine which building and even where inside a building the
            //    person started, or where the person exited a vehicle (e.g. the vehicle parking spot or the
            //    location of a drop-off).

            manager.setBackpropagationEnabled(true)

            //    If the user wants to see everything that happened before Navisens found an initial
            //    position, he can adjust the amount of the trajectory to see before the initial
            //    position was set automatically.

            manager.setBackpropagationBufferSize(2000)

            //    Enables AR mode. AR mode publishes orientation quaternion at a higher rate.

    //        manager.setARModeEnabled(true)
        }
    
}
