//
//  AudioQueue.swift
//  
//
//  Created by Christian Beer on 15.11.21.
//

import Foundation
import AudioToolbox

public class AudioQueue {
    
    var queue: AudioQueueRef?
    let streamFormat: AudioStreamBasicDescription
    
    enum Property {
        case isRunning
        case currentDevice
        case magicCookie
        case maximumOutputPacketSize
        case streamDescription
        case channelLayout
        case enableLevelMetering
        case currentLevelMeter
        case currentLevelMeterDB
        case decodeBufferSizeFrames
        case converterError
        case enableTimePitch
        case timePitchAlgorithm
        case timePitchBypass
    }
    enum DeviceProperty {
        case sampleRate
        case numberChannels
    }
    enum TimePitchAlgorithm: String {
        case spectral   = "spec"
        case timeDomain = "tido"
        case variSpeed  = "vspd"
    }
    
    public init(_ queue: AudioQueueRef, streamFormat: AudioStreamBasicDescription) throws {
        self.queue = queue
        self.streamFormat = streamFormat
        var ref = self
        try aqAssert(AudioQueueAddPropertyListener(queue,
                                                   kAudioQueueProperty_IsRunning,
                                                   aqPropertyListener, &ref))
    }
    deinit {
        if let queue = queue {
            AudioQueueDispose(queue, true)
        }
    }
    
    // MARK: - Buffer Management
    
    // MARK: - Queue Control
    
    public func start(at startTime: AudioTimeStamp? = nil) throws {
        guard let queue = queue else { throw AudioQueueError.queueUnitialized }
        if startTime != nil {
            var startTime = startTime
            try aqAssert(AudioQueueStart(queue, &startTime!))
        } else {
            try aqAssert(AudioQueueStart(queue, nil))
        }
    }
    
    @discardableResult
    public func prime(numberOfFrames: Int? = nil) throws -> Int {
        guard let queue = queue else { throw AudioQueueError.queueUnitialized }
        var resultFrames: UInt32 = 0
        try aqAssert(AudioQueuePrime(queue, numberOfFrames.map({ UInt32($0) }) ?? 0,
                                     &resultFrames))
        return Int(resultFrames)
    }
    
    public func stop(immediate: Bool) throws {
        guard let queue = queue else { throw AudioQueueError.queueUnitialized }
        try aqAssert(AudioQueueStop(queue, immediate))
    }
    
    public func pause() throws {
        guard let queue = queue else { throw AudioQueueError.queueUnitialized }
        try aqAssert(AudioQueuePause(queue))
    }
    
    public func flush() throws {
        guard let queue = queue else { throw AudioQueueError.queueUnitialized }
        try aqAssert(AudioQueueFlush(queue))
    }
    
    public func reset() throws {
        guard let queue = queue else { throw AudioQueueError.queueUnitialized }
        try aqAssert(AudioQueueReset(queue))
    }
    
    // MARK: - Parameter Management
    
    // MARK: - Property Management

    func getProperty<T>(_ property: Property, default value: [T]) throws -> [T] {
        guard let queue = queue else { throw AudioQueueError.queueUnitialized }
        var size: UInt32 = UInt32(MemoryLayout<T>.size * value.count)
        var data: [T] = value
        try aqAssert(AudioQueueGetProperty(queue,
                                           property.rawValue,
                                           &data,
                                           &size))
        return data
    }
    func getProperty<T>(_ property: Property, default value: T) throws -> T {
        guard let queue = queue else { throw AudioQueueError.queueUnitialized }
        var size: UInt32 = UInt32(MemoryLayout<T>.size)
        var data: T = value
        try aqAssert(AudioQueueGetProperty(queue,
                                           property.rawValue,
                                           &data,
                                           &size))
        return data
    }
    
    func setProperty<T>(_ property: Property, value: T) throws {
        guard let queue = queue else { throw AudioQueueError.queueUnitialized }
        var value = value
        try aqAssert(AudioQueueSetProperty(queue, property.rawValue, &value, UInt32(MemoryLayout<T>.size)))
    }
    func setProperty<T>(_ property: Property, value: [T]) throws {
        guard let queue = queue else { throw AudioQueueError.queueUnitialized }
        var value = value
        try aqAssert(AudioQueueSetProperty(queue, property.rawValue, &value, UInt32(MemoryLayout<T>.size * value.count)))
    }
    
    public var isRunning: Bool? {
        get {
            do {
                let running: UInt32 = try getProperty(.isRunning, default: 0)
                return running == 1
            } catch {
                return nil
            }
        }
    }
    /*var currentDevice: String? {
        get {
            
        }
        set {}
    }
    var magicCookie: Data? {
        get {
            
        }
        set {}
    }
    var maximumOutputPacketSize: Int? {
        get {
            
        }
        set {}
    }
    var streamDescription: AudioStreamBasicDescription? {
        get {
            
        }
        set {}
    }
    var channelLayout: AudioChannelLayout? {
        get {
            
        }
        set {}
    }
    var enableLevelMetering: Int? {
        get {}
        set {}
    }
    var currentLevelMeter: [AudioQueueLevelMeterState]? {
        get {}
        set {}
    }
    var currentLevelMeterDB: [AudioQueueLevelMeterState]? {
        get {}
        set {}
    }
    var decodeBufferSizeFrames: Int? {
        get {}
        set {}
    }
    var converterError: Int? {
        get {}
        set {}
    }
    var enableTimePitch : Bool? {
        get {}
        set {}
    }
    var timePitchAlgorithm: TimePitchAlgorithm? {
        get {}
        set {}
    }
    var timePitchBypass: Bool? {
        get {}
        set {}
    }*/
}

func aqPropertyListener(userData: UnsafeMutableRawPointer?, queue: AudioQueueRef, propertyId: AudioQueuePropertyID) {
}
