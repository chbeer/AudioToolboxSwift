//
//  File.swift
//  
//
//  Created by Christian Beer on 20.11.21.
//

import Foundation
import AudioToolbox

public extension AudioComponentDescription {
    
    enum ComponentType {
        case output
        case musicDevice
        case musicEffect
        case formatConverter
        case effect
        case mixer
        case panner
        case generator
        case offlineEffect
        case midiProcessor
        case remoteEffect
        case remoteGenerator
        case remoteInstrument
        case remoteMusicEffect
    }
    enum SubType {
        case genericOutput
        case voiceProcessingIO

#if os(macOS)
        case halOutput
        case defaultOutput
        case systemOutput
#else
        case remoteIO
#endif

#if os(macOS)
        case dlsSynth
#endif
        case sampler
        case midiSynth

        case auConverter
        case varispeed
        case deferredRenderer
        case splitter
        case multiSplitter
        case merger
        case newTimePitch
        case auiPodTimeOther
        case roundTripAAC
        case timePitch
        
        case peakLimiter
        case dynamicsProcessor
        case lowPassFilter
        case highPassFilter
        case bandPassFilter
        case highShelfFilter
        case lowShelfFilter
        case parametricEQ
        case distortion
        case delay
        case sampleDelay
        case nBandEQ
        case reverb2
        
#if os(macOS)
        case graphicEQ
        case multiBandCompressor
        case matrixReverb
        case pitch
        case aiFilter
        case netSend
        case rogerBeep
#endif
        
        case multiChannelMixer
        case matrixMixer
        case spatialMixer
    }
    enum Manufacturer {
        case apple
    }
    
    init(type: ComponentType, subType: SubType,
         manufacturer: Manufacturer,
         flags: UInt32 = 0, flagsMask: UInt32 = 0) {
        self.init(componentType: type.rawValue,
                  componentSubType: subType.rawValue,
                  componentManufacturer: manufacturer.rawValue,
                  componentFlags: flags, componentFlagsMask: flagsMask)
    }
}
