//
//  File.swift
//  
//
//  Created by Christian Beer on 22.11.21.
//

import Foundation
import AudioToolbox
import AudioToolboxSwift
import ogg
import vorbis

public class AudioQueueOutputSourceOgg {
    
    struct Const {
        static let vorbisWordSize: Int32 = 2
    }
    
    let file: UnsafeMutablePointer<FILE>?
    var oggVorbisFile: OggVorbis_File

    public var dataFormat: AudioStreamBasicDescription
    
    public init(url: URL) throws {
        file = fopen(url.path, "r")
        oggVorbisFile = OggVorbis_File()
        try ovAssert(ov_open_callbacks(file, &oggVorbisFile, nil, 0, OV_CALLBACKS_NOCLOSE))
        let info = ov_info(&oggVorbisFile, -1)!
        dataFormat = AudioStreamBasicDescription(sampleRate: Double(info.pointee.rate),
                                                 format: .linearPCM,
                                                 formatFlags: [.isPacked, .isSignedInteger],
                                                 bytesPerPacket: Int(info.pointee.channels * Const.vorbisWordSize),
                                                 framesPerPacket: 1,
                                                 bytesPerFrame: Int(info.pointee.channels * Const.vorbisWordSize),
                                                 channelsPerFrame: Int(info.pointee.channels),
                                                 bitsPerChannel: Int(Const.vorbisWordSize) * 8)
    }
    deinit {
        ov_clear(&oggVorbisFile)
    }
    
    var duration: TimeInterval {
        return TimeInterval(ov_time_total(&oggVorbisFile, -1))
    }
}

extension AudioQueueOutputSourceOgg: AudioQueueOutputSource {

    public func readData(buffer: AudioQueueBufferRef) throws -> Bool {
        let bigEndian: Int32 = 0
        let wordSize = Const.vorbisWordSize
        let signedSamples: Int32 = 1
        var currentSection: Int32 = -1
        
        /* See: http://xiph.org/vorbis/doc/vorbisfile/ov_read.html */
        var nTotalBytesRead: UInt32 = 0
        var nBytesRead = 0
        //var readBuf = [CChar](repeating: 0, count: Int(buffer.pointee.mAudioDataBytesCapacity))
        var readBuf = buffer.pointee.mAudioData.assumingMemoryBound(to: CChar.self)
        repeat {
            readBuf = readBuf.advanced(by: nBytesRead)
            nBytesRead = ov_read(&oggVorbisFile,
                                 readBuf,
                                 Int32(Int(buffer.pointee.mAudioDataBytesCapacity - nTotalBytesRead)),
                                 bigEndian, wordSize,
                                 signedSamples, &currentSection)
            if (nBytesRead  <= 0) {
                break
            }
            nTotalBytesRead += UInt32(nBytesRead);
        } while (nTotalBytesRead < buffer.pointee.mAudioDataBytesCapacity)
        
        if (nTotalBytesRead == 0) {
            return false
        }
        if (nBytesRead < 0) {
            return false
        }
        buffer.pointee.mAudioDataByteSize = nTotalBytesRead;
        buffer.pointee.mPacketDescriptionCount = 0;
        return true
    }

}
