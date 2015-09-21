//
//  ViewController.h
//  LeapLogger
//
//  Created by Lucky on 2015/08/07.
//  Copyright (c) 2015年 Lucky. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Listener.h"

@interface ViewController : NSViewController<ListenerDelegate>

@property (weak) IBOutlet NSTextField *hand_count_label;
@property (weak) IBOutlet NSTextField *fps_label;

@end

