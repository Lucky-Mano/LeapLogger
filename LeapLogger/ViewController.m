//
//  ViewController.m
//  LeapLogger
//
//  Created by Lucky on 2015/08/07.
//  Copyright (c) 2015年 Lucky. All rights reserved.
//

#import "ViewController.h"
#import "Listener.h"

@implementation ViewController
{
    Listener *listener_;
    NSUInteger hand_count_;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    hand_count_ = 0;
    
    listener_ = [[Listener alloc] init];
    [listener_ setDelegate:self];
    [listener_ run];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - delegate

- (void) updateHandCountLabel:(NSUInteger)count {
    if (hand_count_ == count) return;
    hand_count_ = count;
    
    @synchronized(_hand_count_label){
        [[self hand_count_label] setStringValue:[NSString stringWithFormat:@"%lu", (unsigned long)count]];
    }
}

- (void) updateFpsDisplay:(float)fps {
    @synchronized(_fps_label) {
        [[self fps_label] setStringValue:[NSString stringWithFormat:@"%.5f", fps]];
    }
}

@end
