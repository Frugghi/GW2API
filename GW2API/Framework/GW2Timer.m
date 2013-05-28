//
//  GW2Timer.m
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 25/05/13.
//  Copyright (c) 2013 Tommaso Madonia. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "GW2Timer.h"

@interface GW2Timer ()

@property (nonatomic, strong) dispatch_source_t source;

@end

@implementation GW2Timer

#pragma mark - Init -

- (id)init {
    self = [super init];
    if (self) {
        _suspended = YES;
    }
    
    return self;
}

- (id)initWithObject:(id<GW2Fetching>)object {
    self = [self init];
    if (self) {
        GW2FetchBlock fetchBlock = [object fetchBlock];
        [self setSource:dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))];
        __block GW2Timer *timer = self;
        [self setBlock:^{
            id obj = fetchBlock(nil);
            
            if ([obj conformsToProtocol:@protocol(GW2Caching)]) {
                NSTimeInterval timeout = [obj timeout];
                if (fabs(timeout - [timer timeInterval]) < 0.0001) {
                    [timer setTimeInterval:timeout startInterval:timeout leeway:2];
                }
            }
        }];
    }
    
    return self;
}

- (id)initWithBlock:(dispatch_block_t)block queue:(dispatch_queue_t)queue {
    self = [self init];
    if (self) {
        [self setSource:dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)];
        [self setBlock:block];
    }
    
    return self;
}

+ (GW2Timer *)repeatingTimerWithTimeInterval:(NSTimeInterval)seconds block:(dispatch_block_t)block {
    return [self repeatingTimerWithTimeInterval:seconds block:block queue:dispatch_get_main_queue()];
}

+ (GW2Timer *)repeatingTimerWithTimeInterval:(NSTimeInterval)seconds block:(dispatch_block_t)block queue:(dispatch_queue_t)queue {
    GW2Timer *timer = [[GW2Timer alloc] initWithBlock:block queue:queue];
    [timer setTimeInterval:seconds startInterval:seconds leeway:0];
    
    return timer;
}

+ (GW2Timer *)pollingTimerForObject:(id<GW2Fetching, GW2Caching>)obj {
    GW2Timer *timer = [[GW2Timer alloc] initWithObject:[(NSObject *)obj copy]];
    NSTimeInterval timeout = [obj timeout];
    NSTimeInterval startInterval = [[[obj lastUpdate] dateByAddingTimeInterval:timeout] timeIntervalSinceNow];
    [timer setTimeInterval:timeout
             startInterval:MAX(startInterval, 0)
                    leeway:2];
    [timer start];
    
    return timer;
}

#pragma mark - Properties -

- (void)setBlock:(dispatch_block_t)block {
    _block = [block copy];
    
    if (self.source) {
        dispatch_source_set_event_handler(self.source, self.block);
    }
}

#pragma mark - Public -

- (void)invalidate {
    if (self.source) {
        dispatch_source_cancel(self.source);
        self.source = nil;
    }
    
    self.block = nil;
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval startInterval:(NSTimeInterval)startInterval leeway:(NSTimeInterval)leeway {
    if (self.source) {
        _timeInterval = timeInterval;
        dispatch_source_set_timer(self.source,
                                  dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(startInterval * NSEC_PER_SEC)),
                                  (uint64_t)(timeInterval * NSEC_PER_SEC),
                                  (uint64_t)(leeway * NSEC_PER_SEC));
    }
}

- (void)start {
    if (self.source && _suspended) {
        dispatch_resume(self.source);
        _suspended = NO;
    }
}

- (void)suspend {
    if (self.source && !_suspended) {
        dispatch_suspend(self.source);
        _suspended = YES;
    }
}

- (void)fire {
    self.block();
}

- (void)dealloc {
    [self invalidate];
}

@end