//
//  File.swift
//  
//
//  Created by Christian Beer on 22.11.21.
//

import Foundation
import vorbis

enum VorbisError: Error {
    case `false`
    case eof
    case hole

    case read
    case fault
    case impl
    case inval
    case notvorbis
    case badheader
    case version
    case notaudio
    case badpacket
    case badlink
    case noseek
    
    case unknown(Int32)

    init(status: Int32) {
        switch status {
        case OV_FALSE: self = .false
        case OV_EOF: self = .eof
        case OV_HOLE: self = .hole

        case OV_EREAD: self = .read
        case OV_EFAULT: self = .fault
        case OV_EIMPL: self = .impl
        case OV_EINVAL: self = .inval
        case OV_ENOTVORBIS: self = .notvorbis
        case OV_EBADHEADER: self = .badheader
        case OV_EVERSION: self = .version
        case OV_ENOTAUDIO: self = .notaudio
        case OV_EBADPACKET: self = .badpacket
        case OV_EBADLINK: self = .badlink
        case OV_ENOSEEK: self = .noseek
        default: self = .unknown(status)
        }
    }
}

func ovAssert(_ status: Int32) throws {
    guard status == 0 else { throw VorbisError(status: status) }
}
