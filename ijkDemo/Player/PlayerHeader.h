//
//  PlayerHeader.h
//  ijkDemo
//
//  Created by raven on 2018/1/23.
//  Copyright © 2018年 raven. All rights reserved.
//

#ifndef PlayerHeader_h
#define PlayerHeader_h

typedef NS_ENUM(NSUInteger, KBPlayerType) {
    KBPlayerTypeIJK = 0,
    KBPlayerTypeAVPlayer,
    KBPlayerTypeUnknown,
};

typedef NS_ENUM(NSInteger, KBPlaybackState) {
    KBPlaybackStateStopped,
    KBPlaybackStatePlaying,
    KBPlaybackStatePaused,
    KBPlaybackStateInterrupted,
    KBPlaybackStateSeekingForward,
    KBPlaybackStateSeekingBackward
};

typedef NS_ENUM(NSInteger, KBMovieFinishReason) {
    KBMovieFinishReasonPlaybackEnded,
    KBMovieFinishReasonPlaybackError,
    KBMovieFinishReasonUserExited
};

#endif /* PlayerHeader_h */
