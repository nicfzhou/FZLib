//
//  FZLibDemoTests.m
//  FZLibDemoTests
//
//  Created by 周峰 on 2017/4/24.
//
//

#import <XCTest/XCTest.h>
#import "FZTimer.h"

@interface FZLibDemoTests : XCTestCase

@end

@implementation FZLibDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


- (void)testTimerOnce{
    NSDate *now = [NSDate date];
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    FZTimer *timer = [FZTimer timerWithFireDate:nil interval:1 repeats:YES invocation:^(NSDate *time){
        NSLog(@"fire time = %@",@([time timeIntervalSinceDate:now]));
//        dispatch_semaphore_signal(sema);
    }];
    
//    [timer fire];
    while ([[NSDate date] timeIntervalSinceDate:now] < 30) {
        [NSThread sleepForTimeInterval:1];
    }
//    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 5*NSEC_PER_SEC));
//    [timer fire];
    
//    dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC));
    
}

@end
