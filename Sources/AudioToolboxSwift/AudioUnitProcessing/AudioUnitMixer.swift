//
//  AudioUnitMixer.swift
//  
//
//  Created by Christian Beer on 20.11.21.
//

import Foundation
import AudioToolbox
import CoreAudio

@objc protocol AURenderCallbackDelegate {
    func performRender(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                       inTimeStamp: UnsafePointer<AudioTimeStamp>,
                       inBusNumber: UInt32,
                       inNumberFrames: UInt32,
                       ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus
}

public class AudioUnitMixer: AudioUnit {

    var inputs: [MixerInput]
    
    public struct MixerInput {
        var unit: AudioUnit!
        var bus: Int!
        
        let isStereo: Bool                      // set to true if there is data in the audioDataRight member
        let frameCount: UInt32                  // the total number of frames in the audio data
        let sampleNumber: UInt32                // the next audio sample to play
        let audioDataLeft: AudioUnitSampleType  // the complete left (or mono) channel of audio data read from an audio file
        let audioDataRight: AudioUnitSampleType // the complete right channel of audio data read from an audio file
        
        internal init(isStereo: Bool, frameCount: UInt32, sampleNumber: UInt32, audioDataLeft: AudioUnitSampleType, audioDataRight: AudioUnitSampleType) {
            self.isStereo = isStereo
            self.frameCount = frameCount
            self.sampleNumber = sampleNumber
            self.audioDataLeft = audioDataLeft
            self.audioDataRight = audioDataRight
        }
        
        enum MultiChannelMixerParameter: AudioUnitParameterID, AudioUnitParameter {
            case volume = 0
            case enable = 1
            case pan    = 2
            // read only
            case preAveragePower     = 1000
            case prePeakHoldLevel    = 2000
            case postAveragePower    = 3000
            case postPeakHoldLevel   = 4000
        }
        
        var streamFormat: AudioStreamBasicDescription {
            if isStereo { return setupStereoStreamFormat() }
            else { return monoStreamFormat() }
        }
        
    }
    
    public init(inputs: [MixerInput]) {
        self.inputs = inputs
        
        super.init(audioComponentDescription: .init(type: .mixer,
                                                    subType: .multiChannelMixer,
                                                    manufacturer: .apple))
    }
    
    // MARK: -
    
    public override func didOpenGraph(_ graph: AudioUnitGraph) throws {
        try super.didOpenGraph(graph)
        
        guard let node = node else { throw AudioUnitError.nodeUnitialized }
        
        try setBusCount(inputs.count)
        try setMaximumFramesPerSlice(4096)
        
        for (index, input) in inputs.enumerated() {
            var inputCallback = AURenderCallbackStruct(
                inputProc: AudioUnitMixer.inputRenderCallback,
                inputProcRefCon: Unmanaged.passUnretained(self).toOpaque())
            try auAssert(AUGraphSetNodeInputCallback(graph.graph!,
                                                     node,
                                                     UInt32(index),
                                                     &inputCallback))
            
            var streamFormat = input.streamFormat
            streamFormat.mSampleRate = graph.sampleRate
            
            try setProperty(.streamFormat,
                            scope: .input,
                            element: Int(index),
                            value: streamFormat)
        }
        
        try setProperty(.sampleRate,
                        scope: .output,
                        value: Float64(graph.sampleRate))
    }
    
    // MARK: - Properties
    
    internal func setBusCount(_ count: Int) throws {
        try setProperty(.elementCount,
                        scope: .input,
                        value: UInt32(count))
    }
    internal func setMaximumFramesPerSlice(_ count: Int) throws {
        try setProperty(.maximumFramesPerSlice,
                        scope: .global,
                        value: UInt32(count))
    }
    
    // MARK: -
    
//    // Inspired by MixerHost
//    class SoundStruct {
//        let isStereo: Bool                      // set to true if there is data in the audioDataRight member
//        let frameCount: UInt32                  // the total number of frames in the audio data
//        let sampleNumber: UInt32                // the next audio sample to play
//        let audioDataLeft: AudioUnitSampleType  // the complete left (or mono) channel of audio data read from an audio file
//        let audioDataRight: AudioUnitSampleType // the complete right channel of audio data read from an audio file
//
//        internal init(isStereo: Bool, frameCount: UInt32, sampleNumber: UInt32, audioDataLeft: AudioUnitSampleType, audioDataRight: AudioUnitSampleType) {
//            self.isStereo = isStereo
//            self.frameCount = frameCount
//            self.sampleNumber = sampleNumber
//            self.audioDataLeft = audioDataLeft
//            self.audioDataRight = audioDataRight
//        }
//    }
    
    static var inputRenderCallback: AURenderCallback = { inRefCon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData in
        let delegate = unsafeBitCast(inRefCon, to: AURenderCallbackDelegate.self)
        let result = delegate.performRender(ioActionFlags: ioActionFlags,
                                            inTimeStamp: inTimeStamp,
                                            inBusNumber: inBusNumber,
                                            inNumberFrames: inNumberFrames,
                                            ioData: ioData)
        return result
    }
}

extension AudioUnitMixer: AURenderCallbackDelegate {
    func performRender(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, inTimeStamp: UnsafePointer<AudioTimeStamp>, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
        
//        print("> ioActionFlags: \(ioActionFlags), inTimeStamp: \(inTimeStamp), inBusNumber: \(inBusNumber), inNumberFrames: \(inNumberFrames)")
//
//        let input = inputs[Int(inBusNumber)]
//        let frameTotalForSound      = input.frameCount
//        let isStereo                = input.isStereo
//
//        // Declare variables to point to the audio buffers. Their data type must match the buffer data type.
//        var dataInLeft: AudioUnitSampleType
//        var dataInRight: AudioUnitSampleType? = nil
//
//        dataInLeft                 = input.audioDataLeft;
//        if isStereo { dataInRight  = input.audioDataRight }
//
//        // Establish pointers to the memory into which the audio from the buffers should go. This reflects
//        //    the fact that each Multichannel Mixer unit input bus has two channels, as specified by this app's
//        //    graphStreamFormat variable.
//        var outSamplesChannelLeft: AudioUnitSampleType
//        var outSamplesChannelRight: AudioUnitSampleType
//
//        guard let ioData = ioData else { return 1 }
//        var audioBufferListPtr = UnsafeMutableAudioBufferListPointer(ioData)
//
//        outSamplesChannelLeft               = audioBufferListPtr.first.mData;
//        if (isStereo) outSampl.ChannelRight = audioBufferListPtr.mBuffers[1].mData;
//
//        // Get the sample number, as an index into the sound stored in memory,
//        //    to start reading data from.
//        var sampleNumber = input.sampleNumber
//
//        // Fill the buffer or buffers pointed at by *ioData with the requested number of samples
//        //    of audio from the sound stored in memory.
//        for frameNumber in 0..<inNumberFrames {
//
//            outSamplesChannelLeft[frameNumber]                 = dataInLeft[sampleNumber];
//            if (isStereo) outSamplesChannelRight[frameNumber]  = dataInRight[sampleNumber];
//
//            sampleNumber++;
//
//            // After reaching the end of the sound stored in memory--that is, after
//            //    (frameTotalForSound / inNumberFrames) invocations of this callback--loop back to the
//            //    start of the sound so playback resumes from there.
//            if (sampleNumber >= frameTotalForSound) sampleNumber = 0;
//        }
//
//        // Update the stored sample number so, the next time this callback is invoked, playback resumes
//        //    at the correct spot.
//        input.sampleNumber = sampleNumber
        
        return noErr
    }
    
    
    
    
}

// MARK: -

public extension AudioUnitMixer.MixerInput {
    var enabled: Bool {
        get throws {
            return try unit.getParameter(MultiChannelMixerParameter.enable, scope: .input, element: bus) != 0
        }
    }
    func setEnabled(_ value: Bool) throws {
        try unit.setParameter(MultiChannelMixerParameter.enable, scope: .input, element: bus, value: value ? 1 : 0)
    }

    func volume(scope: AudioUnit.Scope) throws -> Double {
        return Double(try unit.getParameter(MultiChannelMixerParameter.volume, scope: scope, element: bus))
    }
    func setVolume(_ value: Double, scope: AudioUnit.Scope) throws {
        try unit.setParameter(MultiChannelMixerParameter.volume, scope: scope, element: bus, value: AudioUnitParameterValue(value))
    }

    var pan: Double {
        get throws {
            return Double(try unit.getParameter(MultiChannelMixerParameter.pan, scope: .input, element: bus))
        }
    }
    func setPan(_ value: Double) throws {
        try unit.setParameter(MultiChannelMixerParameter.pan, scope: .input, element: bus, value: AudioUnitParameterValue(value))
    }

    func preAveragePower(scope: AudioUnit.Scope) throws -> Double {
        Double(try unit.getParameter(MultiChannelMixerParameter.preAveragePower, scope: scope))
    }
    func prePeakHoldLevel(scope: AudioUnit.Scope) throws -> Double {
        Double(try unit.getParameter(MultiChannelMixerParameter.prePeakHoldLevel, scope: scope))
    }
    func postAveragePower(scope: AudioUnit.Scope) throws -> Double {
        Double(try unit.getParameter(MultiChannelMixerParameter.postAveragePower, scope: scope))
    }
    func postPeakHoldLevel(scope: AudioUnit.Scope) throws -> Double {
        Double(try unit.getParameter(MultiChannelMixerParameter.postPeakHoldLevel, scope: scope))
    }
    
    func setupStereoStreamFormat() -> AudioStreamBasicDescription {
        let bytesPerSample = MemoryLayout<AudioUnitSampleType>.size
        let stereoStreamFormat = AudioStreamBasicDescription(mSampleRate: 44100,
                                                             mFormatID: kAudioFormatLinearPCM,
                                                             mFormatFlags: kAudioFormatFlagsAudioUnitCanonical,
                                                             mBytesPerPacket: UInt32(bytesPerSample), mFramesPerPacket: 1,
                                                             mBytesPerFrame: UInt32(bytesPerSample), mChannelsPerFrame: 2,
                                                             mBitsPerChannel: UInt32(8 * bytesPerSample),
                                                             mReserved: 0)
        return stereoStreamFormat
    }

    func monoStreamFormat() -> AudioStreamBasicDescription {
        let bytesPerSample = MemoryLayout<AudioUnitSampleType>.size
        let stereoStreamFormat = AudioStreamBasicDescription(mSampleRate: 44100,
                                                             mFormatID: kAudioFormatLinearPCM,
                                                             mFormatFlags: kAudioFormatFlagsAudioUnitCanonical,
                                                             mBytesPerPacket: UInt32(bytesPerSample), mFramesPerPacket: 1,
                                                             mBytesPerFrame: UInt32(bytesPerSample), mChannelsPerFrame: 1,
                                                             mBitsPerChannel: UInt32(8 * bytesPerSample),
                                                             mReserved: 0)
        return monoStreamFormat()
    }
}
