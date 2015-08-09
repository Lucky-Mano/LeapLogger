//
//  CsvLogger.h
//  LeapLogger
//
//  Created by Lucky on 2015/08/07.
//  Copyright (c) 2015年 Lucky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CsvLogger : NSObject

- (void) prepareFile:(NSString *)output_dir;
- (void) write:(NSString *)data;

@end
