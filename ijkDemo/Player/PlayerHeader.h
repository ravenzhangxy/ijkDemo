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
    KBPlaybackStateSeekingBackward,
    KBPlaybackStateReadyToPlay,
    KBPlaybackStateFailed
};

typedef NS_ENUM(NSInteger, KBMovieFinishReason) {
    KBMovieFinishReasonPlaybackEnded,
    KBMovieFinishReasonPlaybackError,
    KBMovieFinishReasonUserExited
};

typedef NS_ENUM(NSInteger, KBMovieScalingMode) {
    KBMovieScalingModeNone,       // No scaling
    KBMovieScalingModeAspectFit,  // Uniform scale until one dimension fits
    KBMovieScalingModeAspectFill, // Uniform scale until the movie fills the visible bounds. One dimension may have clipped contents
    KBMovieScalingModeFill        // Non-uniform scale. Both render dimensions will exactly match the visible bounds
};

#endif /* PlayerHeader_h */
