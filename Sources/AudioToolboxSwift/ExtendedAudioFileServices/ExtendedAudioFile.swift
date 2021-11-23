//
//  ExtendedAudioFile.swift
//  
//
//  Created by Christian Beer on 21.11.21.
//

import Foundation
import AudioToolbox

open class ExtendedAudioFile {
    
    var extAudioFile: ExtAudioFileRef!
    
    public enum Property {
        case fileDataFormat
        case fileChannelLayout
        case clientDataFormat
        case clientChannelLayout
        case codecManufacturer
        case audioConverter
        case audioFile
        case fileMaxPacketSize
        case clientMaxPacketSize
        case fileLengthFrames
        case converterConfig
        case ioBufferSizeBytes
        case ioBuffer
        case packetTable
    }
    
    public init(url: URL) throws {
        try eafAssert(ExtAudioFileOpenURL(url as CFURL, &extAudioFile))
    }
    public init(url: URL, fileType: AudioFileType,
         streamDescription: AudioStreamBasicDescription,
         channelLayout: AudioChannelLayout,
         flags: UInt32 = 0) throws {
        var streamDescription = streamDescription
        var channelLayout = channelLayout
        try eafAssert(ExtAudioFileCreateWithURL(url as CFURL,
                                                fileType.rawValue,
                                                &streamDescription,
                                                &channelLayout,
                                                flags,
                                                &extAudioFile))
    }
    deinit {
        ExtAudioFileDispose(extAudioFile)
    }
    
    // MARK: - Properties
    
    public var clientDataFormat: AudioStreamBasicDescription {
        get throws { try getProperty(.clientDataFormat, default: AudioStreamBasicDescription()) }
    }
    public func setClientDataFormat(_ value: AudioStreamBasicDescription) throws {
        try setProperty(.clientDataFormat, value: clientDataFormat)
    }
    
    // MARK: -

    open func read(numberOfFrames: UInt32, buffer: inout AudioBufferList) throws -> UInt32 {
        var numberOfFrames = numberOfFrames
        try eafAssert(ExtAudioFileRead(extAudioFile,
                                       &numberOfFrames,
                                       &buffer))
        return numberOfFrames
    }
    
    // MARK: -
    
    public func getProperty<T>(_ property: Property, default value: [T]) throws -> [T] {
        var size: UInt32 = UInt32(MemoryLayout<T>.size * value.count)
        var data: [T] = value
        try afAssert(ExtAudioFileGetProperty(extAudioFile,
                                             property.rawValue,
                                             &size,
                                             &data))
        return data
    }
    public func getProperty<T>(_ property: Property, default value: T) throws -> T {
        var size: UInt32 = UInt32(MemoryLayout<T>.size)
        var data: T = value
        try afAssert(ExtAudioFileGetProperty(extAudioFile,
                                             property.rawValue,
                                             &size,
                                             &data))
        return data
    }
    
    public func setProperty<T>(_ property: Property, value: T) throws {
        var value = value
        try aqAssert(ExtAudioFileSetProperty(extAudioFile,
                                             property.rawValue,
                                             UInt32(MemoryLayout<T>.size),
                                             &value))
    }
    public func setProperty<T>(_ property: Property, value: [T]) throws {
        var value = value
        try aqAssert(ExtAudioFileSetProperty(extAudioFile,
                                             property.rawValue,
                                             UInt32(MemoryLayout<T>.size * value.count),
                                             &value))
    }
    
    public func getPropertyInfo(_ property: Property) throws -> (size: UInt32, writeable: Bool) {
        var size: UInt32 = 0
        var writeable: DarwinBoolean = false
        try afAssert(ExtAudioFileGetPropertyInfo(extAudioFile,
                                                 property.rawValue,
                                                 &size,
                                                 &writeable))
        return (size, writeable.boolValue)
    }
    public func getPropertySize(_ property: Property) throws -> UInt32 {
        var size: UInt32 = 0
        try afAssert(ExtAudioFileGetPropertyInfo(extAudioFile,
                                                 property.rawValue,
                                                 &size,
                                                 nil))
        return size
    }
    public func getPropertyWriteable(_ property: Property) throws -> Bool {
        var writeable: DarwinBoolean = false
        try afAssert(ExtAudioFileGetPropertyInfo(extAudioFile,
                                                 property.rawValue,
                                                 nil,
                                                 &writeable))
        return writeable.boolValue
    }
}
