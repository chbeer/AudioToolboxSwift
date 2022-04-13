//
//  File.swift
//  
//
//  Created by Christian Beer on 10.04.22.
//

import Foundation
import AVFoundation
import AudioToolboxSwift_Ogg
import ogg
import vorbis
import Accelerate

public class AVAudioOGGFile {
    
    struct Const {
        static let vorbisWordSize: Int32 = 2
    }
    
    enum Error: Swift.Error {
        case generalError
    }
    
    public let url: URL
    public let processingFormat: AVAudioFormat
    public let length: AVAudioFramePosition
    
    var file: UnsafeMutablePointer<FILE>?
    var oggVorbisFile: OggVorbis_File
    
    public init(forReading url: URL) throws {
        self.url = url

        file = fopen(url.path, "r")
        oggVorbisFile = OggVorbis_File()
        try ovAssert(ov_open_callbacks(file, &oggVorbisFile, nil, 0, OV_CALLBACKS_NOCLOSE))
        let info = ov_info(&oggVorbisFile, -1)!
        // Standard-Format is Float32
        
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: Double(info.pointee.rate),
                                   channels: AVAudioChannelCount(info.pointee.channels), interleaved: false)!
        self.processingFormat = format
        
        let length = Int32(ov_pcm_total(&oggVorbisFile, -1))
        self.length = AVAudioFramePosition(length)
    }
    deinit {
        ov_clear(&oggVorbisFile)
        fclose(file)
    }
    
    public func readIntoBuffer(buffer: AVAudioPCMBuffer) throws {
        let wordSize = Const.vorbisWordSize
        var currentSection: Int32 = -1

        /* See: http://xiph.org/vorbis/doc/vorbisfile/ov_read.html */
        var nTotalBytesRead: UInt32 = 0
        var nBytesRead = 0
        
        let bufferSize = Int(UInt32(length) * processingFormat.channelCount)
        let bufferByteSize = bufferSize * MemoryLayout<Float>.size
        
//        var nFramesRead: Int
//
//        var buf = [buffer.floatChannelData!.pointee]
//        repeat {
//            nFramesRead = ov_read_float(&oggVorbisFile, &buf, 4096, &currentSection)
//            if (nFramesRead  <= 0) {
//                break
//            }
//
//            pcmInt8Data.append(contentsOf: buf.prefix(nBytesRead))
//
//                    nTotalBytesRead += UInt32(nBytesRead);
//                } while (nTotalBytesRead < bufferByteSize)
        
        var pcmInt16Data = [Int16].init(repeating: 0, count: bufferSize)
//        var buf = [Int8].init(repeating: 0, count: 4096)
//        repeat {
//            //            pcmInt16Data = pcmInt16Data.advanced(by: nBytesRead)
//            nBytesRead = ov_read(&oggVorbisFile,
//                                 &buf,
//                                 4096,
//                                 0, wordSize,
//                                 1, &currentSection)
//            if (nBytesRead  <= 0) {
//                break
//            }
//
//            pcmInt16Data.append(contentsOf: buf.prefix(nBytesRead))
//
//            nTotalBytesRead += UInt32(nBytesRead);
//        } while (nTotalBytesRead < bufferByteSize)
        
        pcmInt16Data.withUnsafeMutableBytes { ptr in
            var readBuf = ptr.baseAddress!.assumingMemoryBound(to: CChar.self)
            repeat {
                readBuf = readBuf.advanced(by: nBytesRead)
                nBytesRead = ov_read(&oggVorbisFile,
                                     readBuf,
                                     4096,
                                     0, wordSize,
                                     1, &currentSection)
                if (nBytesRead  <= 0) {
                    break
                }
                nTotalBytesRead += UInt32(nBytesRead)
            } while (nTotalBytesRead < bufferByteSize)
        }
                                     
        if (nTotalBytesRead == 0) {
            throw Error.generalError
        }
        if (nBytesRead < 0) {
            throw VorbisError(status: Int32(nBytesRead))
        }

        var pcmFloatData = [Float](repeating: 0.0, count: bufferSize) // allocate once and reuse

        // Int16 ranges from -32768 to 32767 -- we want to convert and scale these to Float values between -1.0 and 1.0
        var scale = Float(Int16.max) + 1.0
        vDSP_vflt16(pcmInt16Data, 1, &pcmFloatData, 1, vDSP_Length(bufferSize)) // Int16 to Float
        vDSP_vsdiv(pcmFloatData, 1, &scale, &pcmFloatData, 1, vDSP_Length(bufferSize)) // divide by scale

        if processingFormat.channelCount == 2 {
            let leftChannel = buffer.floatChannelData![0]
            let rightChannel = buffer.floatChannelData![1]

            var output = DSPSplitComplex(realp: leftChannel, imagp: rightChannel)

            // Split the data.  The left (even) samples will end up in leftSampleData, and the right (odd) will end up in rightSampleData
            pcmFloatData.withUnsafeBufferPointer { buffPtr in
                buffPtr.baseAddress?.withMemoryRebound(to: DSPComplex.self, capacity: bufferSize) { ptr in
                    vDSP_ctoz(ptr, 2, &output, 1, vDSP_Length(bufferSize / 2))
                }
            }
        } else {
            let monoChannel = buffer.floatChannelData![0]
            memcpy(monoChannel, pcmFloatData, bufferByteSize)
        }
    }
}

public extension AVAudioPlayerNode {
    
    func scheduleFile(_ file: AVAudioOGGFile, at when: AVAudioTime?, options: AVAudioPlayerNodeBufferOptions = [], completionHandler: AVAudioNodeCompletionHandler? = nil) throws {
        let buff = AVAudioPCMBuffer(pcmFormat: file.processingFormat,
                                    frameCapacity: UInt32(file.length))!
        try file.readIntoBuffer(buffer: buff)
        scheduleBuffer(buff, at: when, options: options, completionHandler: completionHandler)
    }
    
}
