//
//  CsvLogger.m
//  LeapLogger
//
//  Created by Lucky on 2015/08/07.
//  Copyright (c) 2015年 Lucky. All rights reserved.
//

#import "CsvLogger.h"

@implementation CsvLogger
{
    NSString *path_;
    NSFileHandle *file_handle_;
}

- (void) prepareFile:(NSString *)output_dir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document_path = paths[0];
    
    NSString *output_path = [document_path stringByAppendingPathComponent:output_dir];
    if (![[NSFileManager defaultManager] fileExistsAtPath:output_path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:output_path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    NSString *file_name = [self createLogFileName];
    path_ = [output_path stringByAppendingPathComponent:file_name];
    
    [[NSFileManager defaultManager] createFileAtPath:path_ contents:[NSData data] attributes:nil];
    
    file_handle_ = [NSFileHandle fileHandleForWritingAtPath:path_];
    
    if (!file_handle_)
        NSLog(@"ファイルハンドルの作成に失敗\n");
}

- (void) write:(NSString *)data_str
{
    NSData *data = [NSData dataWithBytes:data_str.UTF8String length:data_str.length];
    
    @synchronized(file_handle_) {
        [file_handle_ writeData:data];
    }
}

#pragma mark - private method

- (NSString *)createLogFileName
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMdd_HHmmss"];
    
    NSDate *now = [NSDate date];
    return [[formatter stringFromDate:now] stringByAppendingPathExtension:@"csv"];
}

@end
