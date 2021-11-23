//
//  File.swift
//  
//
//  Created by Christian Beer on 22.11.21.
//

import Foundation
import AudioToolbox

extension ExtendedAudioFile {
    
    class CallbackUserData {
        var file: ExtendedAudioFile
        var outputQueue: AudioQueueOutput?
        internal init(file: ExtendedAudioFile, outputQueue: AudioQueueOutput? = nil) {
            self.file = file
            self.outputQueue = outputQueue
        }
        deinit {
            print("deinit UserData")
        }
    }

    public var callback: AudioQueueOutputCallback {
        return { userData, q, destinationBuffer  in
            guard let userData = userData else { return }
               
            let callbackUserData = Unmanaged<ExtendedAudioFile.CallbackUserData>.fromOpaque(userData).takeUnretainedValue()
            let file = callbackUserData.file
            guard let queue = callbackUserData.outputQueue else { return }
            
            if queue.isDone { return }
            
            var numBytes = destinationBuffer.pointee.mAudioDataBytesCapacity
            var numPackets = queue.numberOfPacketsToRead

            
        // TODO: !!
            
            /*
            do {
                try file.read(numberOfFrames: 1,
                              buffer: &destinationBuffer.pointee.mAudioData)
                
                if numPackets > 0 {
                    destinationBuffer.pointee.mAudioDataByteSize = numBytes
                    
                    try queue.enqueueBuffer(buffer: destinationBuffer,
                                            numberOfPackages: queue.packetDescriptions == nil ? 0 : numPackets,
                                            packageDescriptions: queue.packetDescriptions)
                    
                    queue.packetPosition += Int64(numPackets)
                    
                } else {
                    try queue.stop(immediate: false)
                    queue.isDone = true
                }
            } catch {
                
            }
                 */
        }
    }
    
}
