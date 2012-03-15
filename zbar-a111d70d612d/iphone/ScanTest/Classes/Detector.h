//
//  Detector.h
//  QR
//
//  Created by Yoon Lee on 9/13/11.
//  Copyright 2011 University of California, Irvine. All rights reserved.
//

@protocol DetectorDelegate;


@interface Detector : NSObject 
{
	NSString *sentence;
	id<DetectorDelegate> delegate;
}

@property(nonatomic, retain) NSString *sentence;
@property(nonatomic, assign) id<DetectorDelegate> delegate;

- (id) initWithEncryption:(NSString *)input;

- (void) setSentenceForDearchive:(NSString *)_sentence;

@end

@protocol DetectorDelegate
@optional

- (void) didParseComple:(Detector *)detector isMessageHTML:(BOOL)isHTML;

@end