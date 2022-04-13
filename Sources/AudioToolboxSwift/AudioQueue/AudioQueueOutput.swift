//
//  AudioQueueOutput.swift
//  
//
//  Created by Christian Beer on 15.11.21.
//

import Foundation
import AudioToolbox

public protocol AudioQueueOutputSource {
    var dataFormat: AudioStreamBasicDescription { get }
    func readData(buffer: AudioQueueBufferRef) throws -> Bool
}

public class AudioQueueOutput: AudioQueue {
    
    var buffers: [AudioQueueBufferRef]?
    var packetPosition: Int64 = 0
    var numberOfPacketsToRead: UInt32 = 0
    var packetDescriptions: UnsafeMutablePointer<AudioStreamPacketDescription>?
    var userData: Any?

    var isDone: Bool = false

    public init(format: AudioStreamBasicDescription,
                dispatchQueue: DispatchQueue,
                callback: @escaping AudioQueueOutputCallbackBlock) throws {
        // inFlags: Reserved for future use. Pass 0.
        let flags: UInt32 = 0
        var format = format
        var queue: AudioQueueRef?
        try aqAssert(AudioQueueNewOutputWithDispatchQueue(&queue, &format, flags,
                                                          dispatchQueue, callback))
        try super.init(queue!, streamFormat: format)
    }
    public init(format: AudioStreamBasicDescription,
                callback: @escaping AudioQueueOutputCallback,
                userData: UnsafeMutableRawPointer? = nil,
                runLoop: RunLoop? = nil, runLoopMode: RunLoop.Mode = .default) throws {
        // inFlags: Reserved for future use. Pass 0.
        let flags: UInt32 = 0
        var format = format
        var queue: AudioQueueRef?
        try aqAssert(AudioQueueNewOutput(&format,
                                         callback,
                                         userData,
                                         runLoop?.getCFRunLoop(),
                                         runLoopMode.rawValue as CFString,
                                         flags,
                                         &queue))
        try super.init(queue!, streamFormat: format)
    }
    deinit {
        print("deinit Queue")
    }
    
    public convenience init(file: AudioFile, numberOfBuffers: Int = 3, dispatchQueue: DispatchQueue) throws {
        let dataFormat = try file.dataFormat
        let userData = AudioFile.CallbackUserData(file: file, outputQueue: nil)
        let userDataRef = unsafeBitCast(userData, to: UnsafeMutableRawPointer.self)
        try self.init(format: dataFormat,
                      callback: file.callback,
                      userData: userDataRef)
        
        userData.outputQueue = self

        self.userData = userData

        let info = try file.calculateBytes(for: 0.5, format: file.dataFormat)
        numberOfPacketsToRead = info.numberOfPackets
        
        if dataFormat.mBytesPerPacket == 0 || dataFormat.mFramesPerPacket == 0 {
            // variable bit rate formats
            let size = sizeOf(AudioStreamPacketDescription.self)
            packetDescriptions = .allocate(capacity: size * Int(numberOfPacketsToRead))
            
        } else {
            // constant bit rate formats (we don't provide packet descriptions, e.g linear PCM)
            packetDescriptions = nil
        }

        try file.applyMagicCookie(toQueue: self)
        
        isDone = false
        packetPosition = 0
        
        try prepareBuffers(count: numberOfBuffers, size: info.bufferSize, callback: file.callback,
                           userData: userDataRef)
    }
    public convenience init(file: ExtendedAudioFile,
                            format: AudioStreamBasicDescription,
                            numberOfBuffers: Int = 3, dispatchQueue: DispatchQueue) throws {
        try file.setClientDataFormat(format)
        
        let dataFormat = format
        let userData = ExtendedAudioFile.CallbackUserData(file: file, outputQueue: nil)
        let userDataRef = unsafeBitCast(userData, to: UnsafeMutableRawPointer.self)
        try self.init(format: dataFormat,
                      callback: file.callback,
                      userData: userDataRef)
        
        userData.outputQueue = self

        self.userData = userData

        isDone = false
        packetPosition = 0
        
        try prepareBuffers(count: numberOfBuffers, size: 32000, callback: file.callback,
                           userData: userDataRef)
    }
    
    public convenience init(source: AudioQueueOutputSource,
                            numberOfBuffers: Int = 3,
                            bufferSize: UInt32 = 128 * 1024,
                            dispatchQueue: DispatchQueue) throws {
        let dataFormat = source.dataFormat
        let userData = AudioSourceCallbackUserData(source: source)
        let userDataRef = unsafeBitCast(userData, to: UnsafeMutableRawPointer.self)
        try self.init(format: dataFormat,
                      callback: AudioQueueOutput.audioSourceCallback,
                      userData: userDataRef)
        userData.outputQueue = self
        
        self.userData = userData

        isDone = false
        packetPosition = 0
        
        try prepareBuffers(count: numberOfBuffers, size: bufferSize,
                           callback: AudioQueueOutput.audioSourceCallback,
                           userData: userDataRef)
    }
    
    // MARK: -
    
    func prepareBuffers(count: Int, size: UInt32, callback: AudioQueueOutputCallback? = nil, userData: UnsafeMutableRawPointer? = nil) throws {
        guard let queue = queue else { throw AudioQueueError.queueUnitialized }
        buffers = try (0..<count).map({ _ in
            var buffer: AudioQueueBufferRef? = nil
            try aqAssert(AudioQueueAllocateBuffer(queue, size, &buffer))
            callback?(userData, queue, buffer!)
            return buffer!
        })   
    }
    
    // MARK: -
    
    func enqueueBuffer(buffer: AudioQueueBufferRef, numberOfPackages: UInt32, packageDescriptions: UnsafePointer<AudioStreamPacketDescription>?) throws {
        guard let queue = queue else { throw AudioQueueError.queueUnitialized }
        try aqAssert(AudioQueueEnqueueBuffer(queue, buffer, numberOfPackages, packageDescriptions))
    }
    
    // MARK: -
    
    static var audioSourceCallback: AudioQueueOutputCallback = { userData, q, destinationBuffer  in
        guard let userData = userData else { return }
        let callbackUserData = Unmanaged<AudioSourceCallbackUserData>.fromOpaque(userData).takeUnretainedValue()
        guard let queue = callbackUserData.outputQueue else { return }
        do {
            if try callbackUserData.source.readData(buffer: &destinationBuffer.pointee) {
                try queue.enqueueBuffer(buffer: destinationBuffer,
                                        numberOfPackages: queue.packetDescriptions == nil ? 0 : 1,
                                        packageDescriptions: queue.packetDescriptions)
                
                //queue.packetPosition += Int64(numPackets)
                
            } else {
                try queue.stop(immediate: false)
                queue.isDone = true
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    class AudioSourceCallbackUserData {
        let source: AudioQueueOutputSource
        var outputQueue: AudioQueueOutput?
        internal init(source: AudioQueueOutputSource) {
            self.source = source
        }
    }
}
