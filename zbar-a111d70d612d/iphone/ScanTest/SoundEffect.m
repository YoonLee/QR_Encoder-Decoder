/*
     File: SoundEffect.m
 Abstract: SoundEffect is a class that loads and plays sound files.
  Version: 1.11
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 Copyright (C) 2010 Mobilityware. All Rights Reserved.
 Modified By Yoon Lee
 Delegate: SoundEffectDelegate
*/

#import "SoundEffect.h"

@implementation SoundEffect
@synthesize tag;
@synthesize delegate;
@synthesize _lockPlay;


// Creates a sound effect object from the specified sound file
+ (id)soundEffectWithContentsOfFile:(NSString *)aPath 
{
    if (aPath) 
	{
        return [[[SoundEffect alloc] initWithContentsOfFile:aPath] autorelease];
    }
    return nil;
}

#if TARGET_OS_IPHONE

+ (void) vibrate
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

#endif

// Initializes a sound effect object with the contents of the specified sound file
- (id)initWithContentsOfFile:(NSString *)path 
{
    self = [super init];
    
	// Gets the file located at the specified path.
    if (self != nil) 
	{
        NSURL *aFileURL = [NSURL fileURLWithPath:path isDirectory:NO];
        
		// If the file exists, calls Core Audio to create a system sound ID.
        if (aFileURL != nil)  
		{
            SystemSoundID aSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)aFileURL, &aSoundID);
            
            if (error == kAudioServicesNoError) 
			{ 
				// success
                _soundID = aSoundID;
            } else 
			{
                NSLog(@"Error %d loading sound at path: %@", error, path);
                [self release], self = nil;
            }
        } 
		else 
		{
            NSLog(@"NSURL is nil for path: %@", path);
            [self release], self = nil;
        }
    }
    return self;
}

void SoundFinished (SystemSoundID soundID, void* context)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	SoundEffect *self = (SoundEffect *)context;
	
	[self->delegate soundFXDidComplete:self];
	[pool release];
}

// Plays the sound associated with a sound effect object.
-(void) play 
{
	if (!_lockPlay) 
    {
		// Calls Core Audio to play the sound for the specified sound ID.
		AudioServicesAddSystemSoundCompletion(_soundID, NULL, NULL, &SoundFinished, self);
		AudioServicesPlaySystemSound(_soundID);
    }
	else
	{
		if (self.delegate)
		{
			[[self delegate] soundFXDidComplete:nil];
		}
	}
}

// Releases resouces when no longer needed.
-(void)dealloc 
{
    AudioServicesDisposeSystemSoundID(_soundID);
    [super dealloc];
}

@end
