//
//  AudioFile.swift
//  
//
//  Created by Christian Beer on 21.11.21.
//

import Foundation
import AudioToolbox

public enum AudioFileType {
    case aiffType
    case aifcType
    case waveType
    case rf64Type
    case bw64Type
    case wave64Type
    case soundDesigner2Type
    case nextType
    case mp3Type
    case mp2Type
    case mp1Type
    case ac3Type
    case aac_ADTSType
    case mpeg4Type
    case m4aType
    case m4bType
    case cafType
    case threeGPType
    case threeGP2Type
    case amrType
    case flacType
    case latmInLOASType
}

open class AudioFile {
    
    var audioFileID: AudioFileID!
    
    enum Property {
        case fileFormat
        case dataFormat
        case isOptimized
        case magicCookieData
        case audioDataByteCount
        case audioDataPacketCount
        case maximumPacketSize
        case dataOffset
        case channelLayout
        case deferSizeUpdates
        case dataFormatName
        case markerList
        case regionList
        case packetToFrame
        case frameToPacket
        case restrictsRandomAccess
        case packetToRollDistance
        case previousIndependentPacket
        case nextIndependentPacket
        case packetToDependencyInfo
        case packetToByte
        case byteToPacket
        case chunkIDs
        case infoDictionary
        case packetTableInfo
        case formatList
        case packetSizeUpperBound
        case packetRangeByteCountUpperBound
        case reserveDuration
        case estimatedDuration
        case bitRate
        case id3Tag
        case id3TagOffset
        case sourceBitDepth
        case albumArtwork
        case audioTrackCount
        case useAudioTrack
    }
    
    public init(url: URL,
                permission: AudioFilePermissions = .readPermission,
                fileType: AudioFileType) throws {
        try afAssert(AudioFileOpenURL(url as CFURL, permission, fileType.rawValue, &audioFileID))
    }
    deinit {
        print("deinit File")
    }
 
    // MARK: -
    
    public var dataFormat: AudioStreamBasicDescription {
        get throws { try getProperty(.dataFormat, default: AudioStreamBasicDescription()) }
    }
    public var packetSizeUpperBound: UInt32 {
        get throws { try getProperty(.packetSizeUpperBound, default: 0) }
    }
    
    // MARK: -
    
    open func calculateBytes(for seconds: Double, format: AudioStreamBasicDescription) throws -> (bufferSize: UInt32, numberOfPackets: UInt32) {
        let maxPacketSize = try packetSizeUpperBound
        let maxBufferSize: UInt32 = 0x10000
        let minBufferSize: UInt32 = 0x4000

        var bufferSize: UInt32
        
        if format.mFramesPerPacket != 0 {
            let numPacketsForTime = UInt32(format.mSampleRate / Double(format.mFramesPerPacket) * seconds)
            bufferSize = numPacketsForTime * maxPacketSize
        } else {
            bufferSize = maxBufferSize > maxPacketSize ? maxBufferSize : maxPacketSize
        }

        if (bufferSize > maxBufferSize && bufferSize > maxPacketSize) {
            bufferSize = maxBufferSize
        } else if (bufferSize < minBufferSize) {
            bufferSize = minBufferSize
        }
        let numberOfPackets = bufferSize / maxPacketSize
        return (bufferSize, numberOfPackets)
    }
    
    open func applyMagicCookie(toQueue queue: AudioQueue) throws {
        guard let size = try? getPropertySize(.magicCookieData), size > 0 else { return }
        let cookie = try getProperty(.magicCookieData,
                                     default: [UInt8](repeating: 0, count: Int(size)))
        try queue.setProperty(.magicCookie, value: cookie)
    }
    
    open func readPacketData(useCache: Bool = false, numberOfBytes: inout UInt32,
                             packetDescriptions: inout UnsafeMutablePointer<AudioStreamPacketDescription>?,
                             startingPacket: Int64, numberOfPackets: inout UInt32,
                             buffer: UnsafeMutableRawPointer) throws {
        try afAssert(AudioFileReadPacketData(audioFileID, useCache, &numberOfBytes,
                                             packetDescriptions,
                                             startingPacket, &numberOfPackets, buffer))
    }
    
    // MARK: -
    
    func getProperty<T>(_ property: Property, default value: [T]) throws -> [T] {
        var size: UInt32 = UInt32(MemoryLayout<T>.size * value.count)
        var data: [T] = value
        try afAssert(AudioFileGetProperty(audioFileID,
                                          property.rawValue,
                                          &size,
                                          &data))
        return data
    }
    func getProperty<T>(_ property: Property, default value: T) throws -> T {
        var size: UInt32 = UInt32(MemoryLayout<T>.size)
        var data: T = value
        try afAssert(AudioFileGetProperty(audioFileID,
                                          property.rawValue,
                                          &size,
                                          &data))
        return data
    }
    
    func getPropertyInfo(_ property: Property) throws -> (size: UInt32, writeable: Bool) {
        var size: UInt32 = 0
        var writeable: UInt32 = 0
        try afAssert(AudioFileGetPropertyInfo(audioFileID,
                                              property.rawValue,
                                              &size,
                                              &writeable))
        return (size, writeable == 1 ? true : false)
    }
    func getPropertySize(_ property: Property) throws -> UInt32 {
        var size: UInt32 = 0
        try afAssert(AudioFileGetPropertyInfo(audioFileID,
                                              property.rawValue,
                                              &size,
                                              nil))
        return size
    }
    func getPropertyWriteable(_ property: Property) throws -> Bool {
        var writeable: UInt32 = 0
        try afAssert(AudioFileGetPropertyInfo(audioFileID,
                                              property.rawValue,
                                              nil,
                                              &writeable))
        return writeable == 1 ? true : false
    }
}
