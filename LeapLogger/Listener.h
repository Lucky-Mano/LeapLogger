//
//  Listener.h
//  LeapLogger
//
//  Created by Lucky on 2015/08/07.
//  Copyright (c) 2015年 Lucky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeapObjectiveC.h"

@protocol ListenerDelegate <NSObject>

@optional

- (void) updateHandCountLabel:(NSUInteger)count;

- (void) updateFpsDisplay:(float)fps;

@end

@interface Listener : NSObject<LeapListener>

@property (strong, nonatomic) id<ListenerDelegate> delegate;

- (void) run;

@end
