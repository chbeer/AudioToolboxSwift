//
//  File.swift
//  
//
//  Created by Christian Beer on 21.11.21.
//

import Foundation
import CoreAudioTypes

public extension AudioStreamBasicDescription {
    
    enum AudioFormat {
        case linearPCM
        case ac3
        case _60958AC3
        case appleIMA4
        case mpeg4AAC
        case mpeg4CELP
        case mpeg4HVXC
        case mpeg4TwinVQ
        case mace3
        case mace6
        case uLaw
        case aLaw
        case qDesign
        case qDesign2
        case qualcomm
        case mpegLayer1
        case mpegLayer2
        case mpegLayer3
        case timeCode
        case midiStream
        case parameterValueStream
        case appleLossless
        case mpeg4AAC_HE
        case mpeg4AAC_LD
        case mpeg4AAC_ELD
        case mpeg4AAC_ELD_SBR
        case mpeg4AAC_ELD_V2
        case mpeg4AAC_HE_V2
        case mpeg4AAC_Spatial
        case mpegD_USAC
        case amr
        case amr_WB
        case audible
        case iLBC
        case dVIIntelIMA
        case microsoftGSM
        case aes3
        case enhancedAC3
        case flac
        case opus
    }
    
    struct FormatFlags: OptionSet {
        public var rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        public static let isFloat           = FormatFlags(rawValue: kAudioFormatFlagIsFloat)
        public static let isBigEndian       = FormatFlags(rawValue: kAudioFormatFlagIsBigEndian)
        public static let isSignedInteger   = FormatFlags(rawValue: kAudioFormatFlagIsSignedInteger)
        public static let isPacked          = FormatFlags(rawValue: kAudioFormatFlagIsPacked)
        public static let isAlignedHigh     = FormatFlags(rawValue: kAudioFormatFlagIsAlignedHigh)
        public static let isNonInterleaved  = FormatFlags(rawValue: kAudioFormatFlagIsNonInterleaved)
        public static let isNonMixable      = FormatFlags(rawValue: kAudioFormatFlagIsNonMixable)
        public static let flagsAreAllClear  = FormatFlags(rawValue: 0x80000000)
    }
    
    init(sampleRate: Double, format: AudioFormat, formatFlags: FormatFlags, bytesPerPacket: Int, framesPerPacket: Int, bytesPerFrame: Int, channelsPerFrame: Int, bitsPerChannel: Int) {
        self.init(mSampleRate: Float64(sampleRate),
                  mFormatID: format.rawValue,
                  mFormatFlags: formatFlags.rawValue,
                  mBytesPerPacket: UInt32(bytesPerPacket),
                  mFramesPerPacket: UInt32(framesPerPacket),
                  mBytesPerFrame: UInt32(bytesPerFrame),
                  mChannelsPerFrame: UInt32(channelsPerFrame),
                  mBitsPerChannel: UInt32(bitsPerChannel), mReserved: 0)
    }
    
}
