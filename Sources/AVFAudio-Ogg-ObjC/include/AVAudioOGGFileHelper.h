//
//  AVAudioOGGFileHelper.h
//  
//
//  Created by Christian Beer on 13.04.22.
//

#import <Foundation/Foundation.h>

@import AVFAudio;
@import vorbis;

NS_ASSUME_NONNULL_BEGIN

@interface AVAudioOGGFileHelper : NSObject

+ (long) readIntoBuffer:(AVAudioPCMBuffer*)buffer file:(OggVorbis_File*)file channelCount:(int)channelCount;

@end

NS_ASSUME_NONNULL_END
