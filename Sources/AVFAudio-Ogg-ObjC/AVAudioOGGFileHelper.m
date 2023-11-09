//
//  NSObject+AVAudioOGGFile_Vorbis.m
//  
//
//  Created by Christian Beer on 13.04.22.
//

#import "AVAudioOGGFileHelper.h"

@implementation AVAudioOGGFileHelper

+ (long) readIntoBuffer:(AVAudioPCMBuffer*)buffer file:(OggVorbis_File*)file channelCount:(int)channelCount
{
    size_t readCount = 0;
    size_t frameCount = buffer.frameCapacity;
    while (readCount < frameCount) {
        float **outChannels;
        int section;
        
        long outNumFrames = ov_read_float(file, &outChannels, (int)(frameCount - readCount), &section);
        if (outNumFrames < 0) {
            return outNumFrames;
        }
        if (outNumFrames == 0) {
            break;
        }
        
        size_t offset = readCount;
        for( size_t ch = 0; ch < channelCount; ch++ ) {
            memcpy(buffer.floatChannelData[ch] + offset, outChannels[ch], outNumFrames * sizeof(float));
        }
        
        readCount += outNumFrames;
    }
    return readCount;
}

@end
