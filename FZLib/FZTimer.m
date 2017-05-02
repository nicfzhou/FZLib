//
//  FZTimer.m
//  Pods
//
//  Created by 周峰 on 2017/4/24.
//
//

#import "FZTimer.h"


static NSMutableArray *runingTimers;

@interface FZTimer ()
@property(nonatomic,copy) void(^onFireInvocation)(NSDate *date);
@property(nonatomic,assign) BOOL isSuspend;
@property(nonatomic,assign) BOOL isStop;
@property(nonatomic,assign) BOOL isRepeat;
@property(nonatomic,strong) dispatch_source_t timer;
@property(nonatomic,strong) NSDate *nextFireDate;
@property(nonatomic,strong) dispatch_queue_t fireQueue;
@property(nonatomic,assign) dispatch_time_t fireStartTime;
@end
@implementation FZTimer

+ (void)initialize{
    if (self == [FZTimer class]) {
        runingTimers = [NSMutableArray array];
    }
}

/**
 *  @brief 新建一个定时器
 *
 *  @param fireDate   定时器初次触发时间
 *  @param interval   定时器触发周期
 *  @param repeats    定时器是否周期触发，如果为NO,则interval参数自定设置为0
 *  @param invocation 定时器触发时回调
 *
 *  @return 定时器
 */
+ (instancetype)timerWithFireDate:(NSDate *)fireDate interval:(NSTimeInterval) interval repeats:(BOOL)repeats invocation:(void(^)(NSDate *date))invocation{
    
    fireDate = fireDate?:[NSDate date];//fireDate = nil 表示立即触发
    
    FZTimer *timer = [[FZTimer alloc] init];
    __weak FZTimer *target = timer;
    
    timer.fireQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    timer.nextFireDate = fireDate;
    timer.isRepeat = repeats;
    timer.onFireInvocation = ^(NSDate *date){
        
        __strong FZTimer *self = target;
        if (self && self.isValidate && invocation) {
            dispatch_sync(self.fireQueue, ^{invocation(date);});
        }
    };
    
    
    if (!repeats) {//一次性timer
        timer.interval = 0;
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, fireDate.timeIntervalSinceNow * NSEC_PER_SEC);
        dispatch_after(delay, timer.fireQueue, ^{
            __strong FZTimer *timer = target;
            [timer fire];
        });
    }else{
        //循环timer
        timer.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timer.fireQueue);
        timer.fireStartTime = dispatch_walltime(NULL, fireDate.timeIntervalSinceNow * NSEC_PER_SEC);//立即开始
        timer.interval = interval;
        
        dispatch_source_set_event_handler(timer.timer, ^{
            __strong FZTimer *timer = target;
            [timer fire];
        });
    
        //启动timer
        timer.isSuspend = YES;
        [timer resume];
    }
    
    [runingTimers addObject:timer];//避免timer没有被强引用，造成提前释放
    return timer;
    
}


- (void)setInterval:(NSTimeInterval)interval{
    if(_timer){
        //间隔时间
        uint64_t nsecond = interval * NSEC_PER_SEC;
        dispatch_source_set_timer(_timer, self.fireStartTime, nsecond, 0);
    }
    _interval = self.isRepeat?interval:0;
}



/**
 *  @brief 可以手动触发定时器。如果是一次性定时器，则触发后立即设置为停止状态，不再触发；如果循环定时器被暂停了，调用fire则恢复循环定时器执行（并且会立即执行一次）
 */
- (void)fire{
    self.onFireInvocation([NSDate date]);
    if (!self.isRepeat) {
        [self invalidate];
    }else{
        //循环定时器，并不会干扰既定的定时任务;如果timer暂停了，重启timer
        [self resume];
    }
}

- (void)resume{
    if (self.isSuspend && self.timer) {
        dispatch_resume(self.timer);
        self.isSuspend = NO;
    }
}

/**
 *  @brief 暂停循环定时器（一次性定时器调用无任何状态修改）
 */
- (void)suspend{
    if(_timer && !_isSuspend){
        dispatch_suspend(_timer);
        _isSuspend = YES;
    }
}

/**
 *  @brief 停止定时器（定时器停止后，无法再次触发）
 */
- (void)invalidate{
    if (_timer) {
        if (_isSuspend) {
            [self resume];
        }
        dispatch_source_cancel(_timer);
        _isStop = YES;
    }
    [runingTimers removeObject:self];
}


- (BOOL)isValidate{
    return _isStop != YES;
}

@end
