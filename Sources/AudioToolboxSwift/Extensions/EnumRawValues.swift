//
//  File.swift
//  
//
//  Created by Christian Beer on 21.11.21.
//

import Foundation
import AudioToolbox

// MARK: - AudioComponents

extension AudioComponentDescription.ComponentType {
    var rawValue: UInt32 {
        switch self {
        case .output:            return kAudioUnitType_Output
        case .musicDevice:       return kAudioUnitType_MusicDevice
        case .musicEffect:       return kAudioUnitType_MusicEffect
        case .formatConverter:   return kAudioUnitType_FormatConverter
        case .effect:            return kAudioUnitType_Effect
        case .mixer:             return kAudioUnitType_Mixer
        case .panner:            return kAudioUnitType_Panner
        case .generator:         return kAudioUnitType_Generator
        case .offlineEffect:     return kAudioUnitType_OfflineEffect
        case .midiProcessor:     return kAudioUnitType_MIDIProcessor
        case .remoteEffect:      return kAudioUnitType_RemoteEffect
        case .remoteGenerator:   return kAudioUnitType_RemoteGenerator
        case .remoteInstrument:  return kAudioUnitType_RemoteInstrument
        case .remoteMusicEffect: return kAudioUnitType_RemoteMusicEffect
        }
    }
}
extension AudioComponentDescription.SubType {
    var rawValue: UInt32 {
        switch self {
        case .genericOutput:     return kAudioUnitSubType_GenericOutput
        case .voiceProcessingIO: return kAudioUnitSubType_VoiceProcessingIO
#if os(macOS)
        case .halOutput:         return kAudioUnitSubType_HALOutput
        case .defaultOutput:     return kAudioUnitSubType_DefaultOutput
        case .systemOutput:      return kAudioUnitSubType_SystemOutput
#else
        case .remoteIO:          return kAudioUnitSubType_RemoteIO
#endif
#if os(macOS)
        case .dlsSynth:          return kAudioUnitSubType_DLSSynth
#endif
        case .sampler:              return kAudioUnitSubType_Sampler
        case .midiSynth:            return kAudioUnitSubType_MIDISynth
        case .auConverter:          return kAudioUnitSubType_AUConverter
        case .varispeed:            return kAudioUnitSubType_Varispeed
        case .deferredRenderer:     return kAudioUnitSubType_DeferredRenderer
        case .splitter:             return kAudioUnitSubType_Splitter
        case .multiSplitter:        return kAudioUnitSubType_MultiSplitter
        case .merger:               return kAudioUnitSubType_Merger
        case .newTimePitch:         return kAudioUnitSubType_NewTimePitch
        case .auiPodTimeOther:      return kAudioUnitSubType_AUiPodTimeOther
        case .roundTripAAC:         return kAudioUnitSubType_RoundTripAAC
        case .timePitch:            return kAudioUnitSubType_TimePitch
            
        case .peakLimiter:          return kAudioUnitSubType_PeakLimiter
        case .dynamicsProcessor:    return kAudioUnitSubType_DynamicsProcessor
        case .lowPassFilter:        return kAudioUnitSubType_LowPassFilter
        case .highPassFilter:       return kAudioUnitSubType_HighPassFilter
        case .bandPassFilter:       return kAudioUnitSubType_BandPassFilter
        case .highShelfFilter:      return kAudioUnitSubType_HighShelfFilter
        case .lowShelfFilter:       return kAudioUnitSubType_LowShelfFilter
        case .parametricEQ:         return kAudioUnitSubType_ParametricEQ
        case .distortion:           return kAudioUnitSubType_Distortion
        case .delay:                return kAudioUnitSubType_Delay
        case .sampleDelay:          return kAudioUnitSubType_SampleDelay
        case .nBandEQ:              return kAudioUnitSubType_NBandEQ
        case .reverb2:              return kAudioUnitSubType_Reverb2
#if os(macOS)
        case .graphicEQ:            return kAudioUnitSubType_GraphicEQ
        case .multiBandCompressor:  return kAudioUnitSubType_MultiBandCompressor
        case .matrixReverb:         return kAudioUnitSubType_MatrixReverb
        case .pitch:                return kAudioUnitSubType_Pitch
        case .aiFilter:             return kAudioUnitSubType_AUFilter
        case .netSend:              return kAudioUnitSubType_NetSend
        case .rogerBeep:            return kAudioUnitSubType_RogerBeep
#endif
        case .multiChannelMixer:    return kAudioUnitSubType_MultiChannelMixer
        case .matrixMixer:          return kAudioUnitSubType_MatrixMixer
        case .spatialMixer:         return kAudioUnitSubType_SpatialMixer
        }
    }
}
extension AudioComponentDescription.Manufacturer {
    public var rawValue: UInt32 {
        switch self {
        case .apple: return kAudioUnitManufacturer_Apple
        }
    }
}

public extension AudioStreamBasicDescription.AudioFormat {
    var rawValue: UInt32 {
        switch self {
        case .linearPCM: return kAudioFormatLinearPCM
        case .ac3: return kAudioFormatAC3
        case ._60958AC3: return kAudioFormat60958AC3
        case .appleIMA4: return kAudioFormatAppleIMA4
        case .mpeg4AAC: return kAudioFormatMPEG4AAC
        case .mpeg4CELP: return kAudioFormatMPEG4CELP
        case .mpeg4HVXC: return kAudioFormatMPEG4HVXC
        case .mpeg4TwinVQ: return kAudioFormatMPEG4TwinVQ
        case .mace3: return kAudioFormatMACE3
        case .mace6: return kAudioFormatMACE6
        case .uLaw: return kAudioFormatULaw
        case .aLaw: return kAudioFormatALaw
        case .qDesign: return kAudioFormatQDesign
        case .qDesign2: return kAudioFormatQDesign2
        case .qualcomm: return kAudioFormatQUALCOMM
        case .mpegLayer1: return kAudioFormatMPEGLayer1
        case .mpegLayer2: return kAudioFormatMPEGLayer2
        case .mpegLayer3: return kAudioFormatMPEGLayer3
        case .timeCode: return kAudioFormatTimeCode
        case .midiStream: return kAudioFormatMIDIStream
        case .parameterValueStream: return kAudioFormatParameterValueStream
        case .appleLossless: return kAudioFormatAppleLossless
        case .mpeg4AAC_HE: return kAudioFormatMPEG4AAC_HE
        case .mpeg4AAC_LD: return kAudioFormatMPEG4AAC_LD
        case .mpeg4AAC_ELD: return kAudioFormatMPEG4AAC_ELD
        case .mpeg4AAC_ELD_SBR: return kAudioFormatMPEG4AAC_ELD_SBR
        case .mpeg4AAC_ELD_V2: return kAudioFormatMPEG4AAC_ELD_V2
        case .mpeg4AAC_HE_V2: return kAudioFormatMPEG4AAC_HE_V2
        case .mpeg4AAC_Spatial: return kAudioFormatMPEG4AAC_Spatial
        case .mpegD_USAC: return kAudioFormatMPEGD_USAC
        case .amr: return kAudioFormatAMR
        case .amr_WB: return kAudioFormatAMR_WB
        case .audible: return kAudioFormatAudible
        case .iLBC: return kAudioFormatiLBC
        case .dVIIntelIMA: return kAudioFormatDVIIntelIMA
        case .microsoftGSM: return kAudioFormatMicrosoftGSM
        case .aes3: return kAudioFormatAES3
        case .enhancedAC3: return kAudioFormatEnhancedAC3
        case .flac: return kAudioFormatFLAC
        case .opus: return kAudioFormatOpus
        }
    }
}

// MARK: - AudioFile

extension AudioFileType {
    var rawValue: UInt32 {
        switch self {
        case .aiffType: return kAudioFileAIFFType
        case .aifcType: return kAudioFileAIFCType
        case .waveType: return kAudioFileWAVEType
        case .rf64Type: return kAudioFileRF64Type
        case .bw64Type: return kAudioFileBW64Type
        case .wave64Type: return kAudioFileWave64Type
        case .soundDesigner2Type: return kAudioFileSoundDesigner2Type
        case .nextType: return kAudioFileNextType
        case .mp3Type: return kAudioFileMP3Type
        case .mp2Type: return kAudioFileMP2Type
        case .mp1Type: return kAudioFileMP1Type
        case .ac3Type: return kAudioFileAC3Type
        case .aac_ADTSType: return kAudioFileAAC_ADTSType
        case .mpeg4Type: return kAudioFileMPEG4Type
        case .m4aType: return kAudioFileM4AType
        case .m4bType: return kAudioFileM4BType
        case .cafType: return kAudioFileCAFType
        case .threeGPType: return kAudioFile3GPType
        case .threeGP2Type: return kAudioFile3GP2Type
        case .amrType: return kAudioFileAMRType
        case .flacType: return kAudioFileFLACType
        case .latmInLOASType: return kAudioFileLATMInLOASType
        }
    }
}

extension AudioFile.Property {
    var rawValue: AudioFilePropertyID {
        switch self {
        case .fileFormat: return kAudioFilePropertyFileFormat
        case .dataFormat: return kAudioFilePropertyDataFormat
        case .isOptimized: return kAudioFilePropertyIsOptimized
        case .magicCookieData: return kAudioFilePropertyMagicCookieData
        case .audioDataByteCount: return kAudioFilePropertyAudioDataByteCount
        case .audioDataPacketCount: return kAudioFilePropertyAudioDataPacketCount
        case .maximumPacketSize: return kAudioFilePropertyMaximumPacketSize
        case .dataOffset: return kAudioFilePropertyDataOffset
        case .channelLayout: return kAudioFilePropertyChannelLayout
        case .deferSizeUpdates: return kAudioFilePropertyDeferSizeUpdates
        case .dataFormatName: return kAudioFilePropertyDataFormatName
        case .markerList: return kAudioFilePropertyMarkerList
        case .regionList: return kAudioFilePropertyRegionList
        case .packetToFrame: return kAudioFilePropertyPacketToFrame
        case .frameToPacket: return kAudioFilePropertyFrameToPacket
        case .restrictsRandomAccess: return kAudioFilePropertyRestrictsRandomAccess
        case .packetToRollDistance: return kAudioFilePropertyPacketToRollDistance
        case .previousIndependentPacket: return kAudioFilePropertyPreviousIndependentPacket
        case .nextIndependentPacket: return kAudioFilePropertyNextIndependentPacket
        case .packetToDependencyInfo: return kAudioFilePropertyPacketToDependencyInfo
        case .packetToByte: return kAudioFilePropertyPacketToByte
        case .byteToPacket: return kAudioFilePropertyByteToPacket
        case .chunkIDs: return kAudioFilePropertyChunkIDs
        case .infoDictionary: return kAudioFilePropertyInfoDictionary
        case .packetTableInfo: return kAudioFilePropertyPacketTableInfo
        case .formatList: return kAudioFilePropertyFormatList
        case .packetSizeUpperBound: return kAudioFilePropertyPacketSizeUpperBound
        case .packetRangeByteCountUpperBound: return kAudioFilePropertyPacketRangeByteCountUpperBound
        case .reserveDuration: return kAudioFilePropertyReserveDuration
        case .estimatedDuration: return kAudioFilePropertyEstimatedDuration
        case .bitRate: return kAudioFilePropertyBitRate
        case .id3Tag: return kAudioFilePropertyID3Tag
        case .id3TagOffset: return kAudioFilePropertyID3TagOffset
        case .sourceBitDepth: return kAudioFilePropertySourceBitDepth
        case .albumArtwork: return kAudioFilePropertyAlbumArtwork
        case .audioTrackCount: return kAudioFilePropertyAudioTrackCount
        case .useAudioTrack: return kAudioFilePropertyUseAudioTrack
        }
    }
}

// MARK: - ExtendedAudioFile

extension ExtendedAudioFile.Property {
    var rawValue: AudioQueuePropertyID {
        switch self {
        case .fileDataFormat: return kExtAudioFileProperty_FileDataFormat
        case .fileChannelLayout: return kExtAudioFileProperty_FileChannelLayout
        case .clientDataFormat: return kExtAudioFileProperty_ClientDataFormat
        case .clientChannelLayout: return kExtAudioFileProperty_ClientChannelLayout
        case .codecManufacturer: return kExtAudioFileProperty_CodecManufacturer
        case .audioConverter: return kExtAudioFileProperty_AudioConverter
        case .audioFile: return kExtAudioFileProperty_AudioFile
        case .fileMaxPacketSize: return kExtAudioFileProperty_FileMaxPacketSize
        case .clientMaxPacketSize: return kExtAudioFileProperty_ClientMaxPacketSize
        case .fileLengthFrames: return kExtAudioFileProperty_FileLengthFrames
        case .converterConfig: return kExtAudioFileProperty_ConverterConfig
        case .ioBufferSizeBytes: return kExtAudioFileProperty_IOBufferSizeBytes
        case .ioBuffer: return kExtAudioFileProperty_IOBuffer
        case .packetTable: return kExtAudioFileProperty_PacketTable
        }
    }
}

// MARK: - AudioQueue

extension AudioQueue.Property {
    var rawValue: AudioQueuePropertyID {
        switch self {
        case .isRunning:                return kAudioQueueProperty_IsRunning
        case .currentDevice:            return kAudioQueueProperty_CurrentDevice
        case .magicCookie:              return kAudioQueueProperty_MagicCookie
        case .maximumOutputPacketSize:  return kAudioQueueProperty_MaximumOutputPacketSize
        case .streamDescription:        return kAudioQueueProperty_StreamDescription
        case .channelLayout:            return kAudioQueueProperty_ChannelLayout
        case .enableLevelMetering:      return kAudioQueueProperty_EnableLevelMetering
        case .currentLevelMeter:        return kAudioQueueProperty_CurrentLevelMeter
        case .currentLevelMeterDB:      return kAudioQueueProperty_CurrentLevelMeterDB
        case .decodeBufferSizeFrames:   return kAudioQueueProperty_DecodeBufferSizeFrames
        case .converterError:           return kAudioQueueProperty_ConverterError
        case .enableTimePitch:          return kAudioQueueProperty_EnableTimePitch
        case .timePitchAlgorithm:       return kAudioQueueProperty_TimePitchAlgorithm
        case .timePitchBypass:          return kAudioQueueProperty_TimePitchBypass
        }
    }
}

