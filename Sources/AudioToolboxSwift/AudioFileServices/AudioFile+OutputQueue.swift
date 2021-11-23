//
//  File.swift
//  
//
//  Created by Christian Beer on 21.11.21.
//

import Foundation
import AudioToolbox

extension AudioFile {
    
    class CallbackUserData {
        var file: AudioFile
        var outputQueue: AudioQueueOutput?
        internal init(file: AudioFile, outputQueue: AudioQueueOutput? = nil) {
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
               
            let callbackUserData = Unmanaged<AudioFile.CallbackUserData>.fromOpaque(userData).takeUnretainedValue()
            let file = callbackUserData.file
            guard let queue = callbackUserData.outputQueue else { return }
            
            if queue.isDone { return }
            
            var numBytes = destinationBuffer.pointee.mAudioDataBytesCapacity
            var numPackets = queue.numberOfPacketsToRead
            
            do {
                try file.readPacketData(numberOfBytes: &numBytes,
                                        packetDescriptions: &queue.packetDescriptions,
                                        startingPacket: queue.packetPosition,
                                        numberOfPackets: &numPackets,
                                        buffer: destinationBuffer.pointee.mAudioData)
                
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
                print("Error: \(error)")
            }
        }
    }
    
}
