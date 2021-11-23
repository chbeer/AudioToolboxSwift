//
//  InputAudioQueue.swift
//  
//
//  Created by Christian Beer on 15.11.21.
//

import Foundation
import AudioToolbox

public class InputAudioQueue: AudioQueue {
    
    public init(format: AudioStreamBasicDescription, dispatchQueue: DispatchQueue,
         callback: @escaping AudioQueueInputCallbackBlock) throws {
        // inFlags: Reserved for future use. Pass 0.
        let flags: UInt32 = 0
        var format = format
        var queue: AudioQueueRef?
        try aqAssert(AudioQueueNewInputWithDispatchQueue(&queue, &format, flags,
                                                         dispatchQueue, callback))
        try super.init(queue!, streamFormat: format)
    }
    
}
