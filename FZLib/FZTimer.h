//
//  FZTimer.h
//  Pods
//
//  Created by 周峰 on 2017/4/24.
//
//

#import <Foundation/Foundation.h>

@interface FZTimer : NSObject

/** 循环定时器触发时间间隔，可以在循环定时器执行过程中进行修改；如果是一次性定时器，返回0，并且无法修改 */
@property(nonatomic,assign) NSTimeInterval interval;


/**
 *  @brief 新建一个定时器
 *
 *  @param fireDate   定时器初次触发时间
 *  @param interval   定时器触发周期
 *  @param repeats    定时器是否周期触发，如果为NO,则interval参数自定设置为0
 *  @param invocation 定时器触发时回调,在默认的 DISPATCH_QUEUE_PRIORITY_DEFAULT 线程上回调
 *
 *  @return 定时器
 */
+ (instancetype)timerWithFireDate:(NSDate *)fireDate interval:(NSTimeInterval) interval repeats:(BOOL)repeats invocation:(void(^)(NSDate *date))invocation;

/**
 *  @brief 可以手动触发定时器。如果是一次性定时器，则触发后立即设置为停止状态，不再触发；如果循环定时器被暂停了，调用fire则恢复循环定时器执行（并且会立即执行一次）
 */
- (void)fire;
/**
 *  @brief 暂停循环定时器（一次性定时器调用无任何状态修改）
 */
- (void)suspend;
/**
 *  @brief 停止定时器（定时器停止后，无法再次触发）
 */
- (void)invalidate;


- (BOOL)isValidate;
- (BOOL)isSuspend;



@end
