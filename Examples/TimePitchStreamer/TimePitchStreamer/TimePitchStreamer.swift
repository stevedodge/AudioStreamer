//
//  TimePitchStreamer.swift
//  TimePitchStreamer
//
//  Created by Syed Haris Ali on 6/5/18.
//  Copyright © 2018 Ausome Apps LLC. All rights reserved.
//
//  Extended to include AVAudioUnitEQ by Steve Dodge on 12/26/2018


import Foundation
import AVFoundation
import AudioStreamer

/// The `TimePitchStreamer` demonstrates how to subclass the `Streamer` and add a time/pitch shift effect.
final class TimePitchStreamer: Streamer {
    
    /// An `AVAudioUnitTimePitch` used to perform the time/pitch shift effect
    let timePitchNode = AVAudioUnitTimePitch()
    
    /// A `Float` representing the pitch of the audio
    var pitch: Float {
        get {
            return timePitchNode.pitch
        }
        set {
            timePitchNode.pitch = newValue
        }
    }
    
    /// A `Float` representing the playback rate of the audio
    var rate: Float {
        get {
            return timePitchNode.rate
        }
        set {
            timePitchNode.rate = newValue
        }
    }

    /// 'AVAudioUnitEQ' to perform high and low pass filter effects
    let eqFilterFrequencies:[Float] = [ 125, 800, 4000 ]
    let eqFilterNode = AVAudioUnitEQ(numberOfBands: 3)

    override init() {
        super.init()

        eqFilterNode.globalGain = 10

        for i in 0 ..< eqFilterNode.bands.count {
            eqFilterNode.bands[i].filterType = .parametric
            eqFilterNode.bands[i].frequency = eqFilterFrequencies[i]
            eqFilterNode.bands[i].bypass = false
            eqFilterNode.bands[i].bandwidth = 3.0
        }
    }

    /// Global gain applied to the EQ audio unit
    var midGain:Float {
        get {
            return eqFilterNode.globalGain
        }
        set {
            eqFilterNode.globalGain = 10
            eqFilterNode.bands.forEach { $0.gain = newValue }
        }
    }

    /// Cutoff frequency for low pass filter
    var lowGain:Float {
        get {
            return eqFilterNode.bands[0].gain
        }
        set {
            eqFilterNode.bands[0].gain = newValue
        }
    }

    /// Cutoff frequency for high pass filter
    var highGain:Float {
        get {
            return eqFilterNode.bands[1].gain
        }
        set {
            eqFilterNode.bands[1].gain = newValue
        }
    }

    // MARK: - Methods
    
    override func attachNodes() {
        super.attachNodes()
        engine.attach(timePitchNode)
        engine.attach(eqFilterNode)
    }
    
    override func connectNodes() {
        engine.connect(playerNode, to: eqFilterNode, format: readFormat)
        engine.connect(eqFilterNode, to: timePitchNode, format: readFormat)
        engine.connect(timePitchNode, to: engine.mainMixerNode, format: readFormat)
    }
    
}
