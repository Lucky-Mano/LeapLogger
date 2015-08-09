//
//  CsvLoggerTest.m
//  LeapLogger
//
//  Created by Lucky on 2015/08/07.
//  Copyright (c) 2015年 Lucky. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#include "CsvLogger.h"

@interface CsvLoggerTest : XCTestCase

@end

@implementation CsvLoggerTest{
    CsvLogger *logger_;
    NSString *path_;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    logger_ = [[CsvLogger alloc] init];
    
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path_ = [docs[0] stringByAppendingPathComponent:@"LeapLogTest"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    // ディレクトリの削除
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path_ error:&error];
    
    if (!success)
        NSLog(@"Error: %@ %ld %@\n",[error domain],(long)[error code],[[error userInfo] description]);
    
    logger_ = nil;
    [super tearDown];
}

- (void)testPrepareFile {
    // This is an example of a functional test case.
    [logger_ prepareFile:@"LeapLogTest"];
    
    BOOL is_dir;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path_ isDirectory:&is_dir]);
    XCTAssertTrue(is_dir);
}

- (void)testWrite {
    // 呼び出し
    [logger_ prepareFile:@"LeapLogTest"];
    [logger_ write:@"TEST,Message\nSecond,message\n"];
    
    // csv読み込み
    NSString *path = [logger_ valueForKey:@"path_"];
    NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    // 改行区切り
    NSArray *lines = [text componentsSeparatedByString:@"\n"];
    int cnt = (int)lines.count;
    
    XCTAssertEqual(3, cnt);
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    for (NSString *row in lines) {
        // コンマで区切って配列に格納する
        if (row.length == 0)
            continue;
        
        [arr addObject:[row componentsSeparatedByString:@","]];
    }
    XCTAssertEqual(2, [arr count]);
    
    XCTAssertEqual(2, [arr[0] count]);
    XCTAssertTrue([arr[0][0] isEqualToString:@"TEST"]);
    XCTAssertTrue([arr[0][1] isEqualToString:@"Message"]);
    
    XCTAssertEqual(2, [arr[1] count]);
    XCTAssertTrue([arr[1][0] isEqualToString:@"Second"]);
    XCTAssertTrue([arr[1][1] isEqualToString:@"message"]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
