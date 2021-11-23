//
//  AudioUnitMixer.swift
//  
//
//  Created by Christian Beer on 20.11.21.
//

import Foundation
import AudioToolbox

public class AudioUnitMixer: AudioUnit {

    var inputs: [AudioQueueOutput]
    
    var inputRenderCallback: AURenderCallback = { _,_,_,_,_,_  in return 0}
 
    public init(inputs: [AudioQueueOutput]) {
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
                inputProc: inputRenderCallback,
                inputProcRefCon: nil)
            try auAssert(AUGraphSetNodeInputCallback(graph.graph!,
                                                     node,
                                                     UInt32(index),
                                                     &inputCallback))
            
            var streamFormat = input.streamFormat
            streamFormat.mSampleRate = graph.sampleRate
            
            try setProperty(.streamFormat,
                            scope: .input,
                            element: UInt32(index),
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
}
