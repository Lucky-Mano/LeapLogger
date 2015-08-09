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
}

- (void)viewDidLoad {
    [super viewDidLoad];

    listener_ = [[Listener alloc] init];
    [listener_ run];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
