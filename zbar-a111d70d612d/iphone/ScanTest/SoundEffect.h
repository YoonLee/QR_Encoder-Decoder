/*
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 Copyright (C) 2010 Mobilityware. All Rights Reserved.
 Modified By Yoon Lee
 Delegate: SoundEffectDelegate
*/

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

@protocol SoundEffectDelegate;


@interface SoundEffect : NSObject 
{
	BOOL _lockPlay;
	NSInteger tag;
	id<SoundEffectDelegate> delegate;
    SystemSoundID _soundID;
	BOOL _hasCallback;
}

#if TARGET_OS_IPHONE
+ (void) vibrate; //iPhone only
#endif
+ (id)soundEffectWithContentsOfFile:(NSString *)aPath;
- (id)initWithContentsOfFile:(NSString *)path;
- (void)play;

@property(nonatomic, assign) NSInteger tag;
@property(nonatomic, assign) id<SoundEffectDelegate> delegate;
@property(assign) BOOL _lockPlay;

@end

@protocol SoundEffectDelegate<NSObject>
@required
- (void) soundFXDidComplete:(SoundEffect *)soundFX;

@end