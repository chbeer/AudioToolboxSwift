//
//  File.swift
//  
//
//  Created by Christian Beer on 20.11.21.
//

import Foundation
import AudioToolbox

public class AudioUnitOutput: AudioUnit {
    
    public init(subType: AudioComponentDescription.SubType = .remoteIO) {
        super.init(audioComponentDescription: .init(
            type: .output,
            subType: subType,
            manufacturer: .apple
        ))
    }
    
}
