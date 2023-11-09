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
import AVFAudio_Ogg_ObjC
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
        
        //        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: Double(info.pointee.rate),
        //                                   channels: AVAudioChannelCount(info.pointee.channels), interleaved: false)!
        let format = AVAudioFormat(standardFormatWithSampleRate: Double(info.pointee.rate),
                                   channels: AVAudioChannelCount(info.pointee.channels))!
        self.processingFormat = format
        
        let length = Int32(ov_pcm_total(&oggVorbisFile, -1))
        self.length = AVAudioFramePosition(length)
    }
    deinit {
        ov_clear(&oggVorbisFile)
        fclose(file)
    }
    
    public func readIntoBuffer(buffer: AVAudioPCMBuffer) throws {
        
        let nTotalBytesRead = AVAudioOGGFileHelper.read(into: buffer, file: &oggVorbisFile, channelCount: Int32(processingFormat.channelCount))
        
        if (nTotalBytesRead == 0) {
            throw Error.generalError
        }
        if (nTotalBytesRead < 0) {
            throw VorbisError(status: Int32(nTotalBytesRead))
        }
        
        buffer.frameLength = AVAudioFrameCount(nTotalBytesRead)
    }
    
    static func printSamples(buffer: AVAudioPCMBuffer, format: AVAudioFormat, range: Range<Int>) {
        var samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0] + range.startIndex, count:Int(range.count)))
        var a = samples.min() ?? 0
        var b = samples.max() ?? 0
        
        print("> min: \(a), max: \(b)")
        print(samples.map({ String(format: "%0.4f", $0) }).joined(separator: ", "))
        
        if format.channelCount == 2 {
            samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData![1] + 100000, count:Int(500)))
            a = samples.min() ?? 0
            b = samples.max() ?? 0
            
            print("< min: \(a), max: \(b)")
            print(samples.map({ String(format: "%0.4f", $0) }).joined(separator: ", "))
        }
    }
}

public extension AVAudioPlayerNode {
    
    @discardableResult
    func scheduleFile(_ file: AVAudioOGGFile, at when: AVAudioTime?, options: AVAudioPlayerNodeBufferOptions = []) async throws -> AVAudioPCMBuffer {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let buff = AVAudioPCMBuffer(pcmFormat: file.processingFormat,
                                            frameCapacity: UInt32(file.length))!
                try file.readIntoBuffer(buffer: buff)
                scheduleBuffer(buff, at: when, options: options) { }
                continuation.resume(returning: buff)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
}

