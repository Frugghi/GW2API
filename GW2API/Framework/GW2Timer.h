//
//  GW2Timer.h
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

#import <Foundation/Foundation.h>
#import "GW2Protocols.h"

@interface GW2Timer : NSObject

@property (nonatomic, copy) dispatch_block_t block;
@property (nonatomic, readonly) NSTimeInterval timeInterval;
@property (nonatomic, readonly, getter = isSuspended) BOOL suspended;

- (id)initWithBlock:(dispatch_block_t)block queue:(dispatch_queue_t)queue;
+ (GW2Timer *)repeatingTimerWithTimeInterval:(NSTimeInterval)seconds block:(dispatch_block_t)block;
+ (GW2Timer *)repeatingTimerWithTimeInterval:(NSTimeInterval)seconds block:(dispatch_block_t)block queue:(dispatch_queue_t)queue;

+ (GW2Timer *)pollingTimerForObject:(id<GW2Fetching, GW2Caching>)obj;

- (void)setTimeInterval:(NSTimeInterval)timeInterval startInterval:(NSTimeInterval)startInterval leeway:(NSTimeInterval)leeway;

- (void)start;
- (void)suspend;
- (void)fire;
- (void)invalidate;

@end
