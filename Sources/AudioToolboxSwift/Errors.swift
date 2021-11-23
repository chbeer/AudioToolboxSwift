//
//  File.swift
//  
//
//  Created by Christian Beer on 15.11.21.
//

import Foundation
import AudioToolbox

// MARK: - Audio Queue

func aqAssert(_ status: OSStatus) throws {
    guard status == noErr else { throw AudioQueueError(status: status) }
}

enum AudioQueueError: Error {
    case invalidBuffer
    case bufferEmpty
    case disposalPending
    case invalidProperty
    case invalidPropertySize
    case invalidParameter
    case cannotStart
    case invalidDevice
    case bufferInQueue
    case invalidRunState
    case invalidQueueType
    case permissions
    case invalidPropertyValue
    case primeTimedOut
    case codecNotFound
    case invalidCodecAccess
    case queueInvalidated
    case tooManyTaps
    case invalidTapContext
    case recordUnderrun
    case invalidTapType
    case bufferEnqueuedTwice
    case cannotStartYet
    case enqueueDuringReset
    case invalidOfflineMode
    
    case queueUnitialized
    
    case unknown(OSStatus)
    
    init(status: OSStatus) {
        switch status {
        case kAudioQueueErr_InvalidBuffer: self = .invalidBuffer
        case kAudioQueueErr_BufferEmpty: self = .bufferEmpty
        case kAudioQueueErr_DisposalPending: self = .disposalPending
        case kAudioQueueErr_InvalidProperty: self = .invalidProperty
        case kAudioQueueErr_InvalidPropertySize: self = .invalidPropertySize
        case kAudioQueueErr_InvalidParameter: self = .invalidParameter
        case kAudioQueueErr_CannotStart: self = .cannotStart
        case kAudioQueueErr_InvalidDevice: self = .invalidDevice
        case kAudioQueueErr_BufferInQueue: self = .bufferInQueue
        case kAudioQueueErr_InvalidRunState: self = .invalidRunState
        case kAudioQueueErr_InvalidQueueType: self = .invalidQueueType
        case kAudioQueueErr_Permissions: self = .permissions
        case kAudioQueueErr_InvalidPropertyValue: self = .invalidPropertyValue
        case kAudioQueueErr_PrimeTimedOut: self = .primeTimedOut
        case kAudioQueueErr_CodecNotFound: self = .codecNotFound
        case kAudioQueueErr_InvalidCodecAccess: self = .invalidCodecAccess
        case kAudioQueueErr_QueueInvalidated: self = .queueInvalidated
        case kAudioQueueErr_TooManyTaps: self = .tooManyTaps
        case kAudioQueueErr_InvalidTapContext: self = .invalidTapContext
        case kAudioQueueErr_RecordUnderrun: self = .recordUnderrun
        case kAudioQueueErr_InvalidTapType: self = .invalidTapType
        case kAudioQueueErr_BufferEnqueuedTwice: self = .bufferEnqueuedTwice
        case kAudioQueueErr_CannotStartYet: self = .cannotStartYet
        case kAudioQueueErr_EnqueueDuringReset: self = .enqueueDuringReset
        case kAudioQueueErr_InvalidOfflineMode: self = .invalidOfflineMode
        default: self = .unknown(status)
        }
    }
}

// MARK: - AudioUnit

func auAssert(_ status: OSStatus) throws {
    guard status == noErr else { throw AudioUnitError(status: status) }
}

enum AudioUnitError: Error {
    
    case invalidProperty
    case invafeedfeedfeddfedlidParameter
    case invalidElement
    case noConnection
    case failedInitialization
    case zooManyFramesToProcess
    case invalidFile
    case unknownFileType
    case fileNotSpecified
    case formatNotSupported
    case uninitialized
    case invalidScope
    case propertyNotWritable
    case cannotDoInCurrentContext
    case invalidPropertyValue
    case propertyNotInUse
    case initialized
    case invalidOfflineRender
    case unauthorized
    case midiOutputBufferFull
    case renderTimeout
    case extensionNotFound
    case invalidParameterValue
    case invalidFilePath
    case missingKey

    case nodeUnitialized
    case unitUnitialized
    
    case unknown(OSStatus)
    
    init(status: OSStatus) {
        switch status {
        case kAudioUnitErr_InvalidProperty: self = .invalidProperty
        case kAudioUnitErr_InvalidParameter: self = .invafeedfeedfeddfedlidParameter
        case kAudioUnitErr_InvalidElement: self = .invalidElement
        case kAudioUnitErr_NoConnection: self = .noConnection
        case kAudioUnitErr_FailedInitialization: self = .failedInitialization
        case kAudioUnitErr_TooManyFramesToProcess: self = .zooManyFramesToProcess
        case kAudioUnitErr_InvalidFile: self = .invalidFile
        case kAudioUnitErr_UnknownFileType: self = .unknownFileType
        case kAudioUnitErr_FileNotSpecified: self = .fileNotSpecified
        case kAudioUnitErr_FormatNotSupported: self = .formatNotSupported
        case kAudioUnitErr_Uninitialized: self = .uninitialized
        case kAudioUnitErr_InvalidScope: self = .invalidScope
        case kAudioUnitErr_PropertyNotWritable: self = .propertyNotWritable
        case kAudioUnitErr_CannotDoInCurrentContext: self = .cannotDoInCurrentContext
        case kAudioUnitErr_InvalidPropertyValue: self = .invalidPropertyValue
        case kAudioUnitErr_PropertyNotInUse: self = .propertyNotInUse
        case kAudioUnitErr_Initialized: self = .initialized
        case kAudioUnitErr_InvalidOfflineRender: self = .invalidOfflineRender
        case kAudioUnitErr_Unauthorized: self = .unauthorized
        case kAudioUnitErr_MIDIOutputBufferFull: self = .midiOutputBufferFull
        case kAudioUnitErr_RenderTimeout: self = .renderTimeout
        case kAudioUnitErr_ExtensionNotFound: self = .extensionNotFound
        case kAudioUnitErr_InvalidParameterValue: self = .invalidParameterValue
        case kAudioUnitErr_InvalidFilePath: self = .invalidFilePath
        case kAudioUnitErr_MissingKey: self = .missingKey
            
        default: self = .unknown(status)
        }
    }
}

// MARK: - AudioComponent

enum AudioComponentError: Error {
    case kAudioComponentErr_InstanceTimedOut
    case kAudioComponentErr_InstanceInvalidated
}

// MARK: AudioFile

func afAssert(_ status: OSStatus) throws {
    guard status == noErr else { throw AudioFileError(status: status) }
}

enum AudioFileError: Error {
    
    case unspecified
    case unsupportedFileType
    case unsupportedDataFormat
    case unsupportedProperty
    case badPropertySize
    case permissions
    case notOptimized
    case invalidChunk
    case doesNotAllow64BitDataSize
    case invalidPacketOffset
    case invalidPacketDependency
    case invalidFile
    case operationNotSupported
    case notOpen
    case endOfFile
    case position
    case fileNotFound
    
    case unknown(OSStatus)
    
    init(status: OSStatus) {
        switch status {
        case kAudioFileUnspecifiedError: self = .unspecified
        case kAudioFileUnsupportedFileTypeError: self = .unsupportedFileType
        case kAudioFileUnsupportedDataFormatError: self = .unsupportedDataFormat
        case kAudioFileUnsupportedPropertyError: self = .unsupportedProperty
        case kAudioFileBadPropertySizeError: self = .badPropertySize
        case kAudioFilePermissionsError: self = .permissions
        case kAudioFileNotOptimizedError: self = .notOptimized
        case kAudioFileInvalidChunkError: self = .invalidChunk
        case kAudioFileDoesNotAllow64BitDataSizeError: self = .doesNotAllow64BitDataSize
        case kAudioFileInvalidPacketOffsetError: self = .invalidPacketOffset
        case kAudioFileInvalidPacketDependencyError: self = .invalidPacketDependency
        case kAudioFileInvalidFileError: self = .invalidFile
        case kAudioFileOperationNotSupportedError: self = .operationNotSupported
        case kAudioFileNotOpenError: self = .notOpen
        case kAudioFileEndOfFileError: self = .endOfFile
        case kAudioFilePositionError: self = .position
        case kAudioFileFileNotFoundError: self = .fileNotFound
        default: self = .unknown(status)
        }
    }
}

// MARK: ExtAudioFile

func eafAssert(_ status: OSStatus) throws {
    guard status == noErr else { throw ExtendedAudioFileError(status: status) }
}

enum ExtendedAudioFileError: Error {
    case invalidProperty
    case invalidPropertySize
    case nonPCMClientFormat
    case invalidChannelMap
    case invalidOperationOrder
    case invalidDataFormat
    case maxPacketSizeUnknown
    case invalidSeek
    case asyncWriteTooLarge
    case asyncWriteBufferOverflow
#if os(iOS)
    case codecUnavailableInputConsumed
    case codecUnavailableInputNotConsumed
#endif
    
    case unknown(OSStatus)
    
    init(status: OSStatus) {
        switch status {
        case kExtAudioFileError_InvalidProperty: self = .invalidProperty
        case kExtAudioFileError_InvalidPropertySize: self = .invalidPropertySize
        case kExtAudioFileError_NonPCMClientFormat: self = .nonPCMClientFormat
        case kExtAudioFileError_InvalidChannelMap: self = .invalidChannelMap
        case kExtAudioFileError_InvalidOperationOrder: self = .invalidOperationOrder
        case kExtAudioFileError_InvalidDataFormat: self = .invalidDataFormat
        case kExtAudioFileError_MaxPacketSizeUnknown: self = .maxPacketSizeUnknown
        case kExtAudioFileError_InvalidSeek: self = .invalidSeek
        case kExtAudioFileError_AsyncWriteTooLarge: self = .asyncWriteTooLarge
        case kExtAudioFileError_AsyncWriteBufferOverflow: self = .asyncWriteBufferOverflow
#if os(iOS)
        case kExtAudioFileError_CodecUnavailableInputConsumed:    self = .codecUnavailableInputConsumed
        case kExtAudioFileError_CodecUnavailableInputNotConsumed: self = .codecUnavailableInputNotConsumed
#endif
                
        default: self = .unknown(status)
        }
    }
}

