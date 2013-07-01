//
//  GW2Cache.m
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 26/05/13.
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

#import "GW2Cache.h"

@interface GW2Cache ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation GW2Cache

#pragma mark - Init -

- (id)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        _dictionary = [[NSMutableDictionary alloc] init];
        
        NSLog(@"Use of <GW2Cache> is discouraged. Please, implement your own cache! (see GW2APICache protocol and [GW2API setCacheClass:] method)");
    }
    
    return self;
}

#pragma mark - Properties -

- (const char *)cacheQueueSpecific {
    static const char *kGW2CacheQueueSpecific = "GW2CacheQueueSpecific";
    return kGW2CacheQueueSpecific;
}

- (dispatch_queue_t)queue {
    static dispatch_queue_t _queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _queue = dispatch_queue_create("com.GW2Cache.queue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_set_specific(_queue, self.cacheQueueSpecific, (__bridge void *)self, NULL);
    });
    
    return _queue;
}

- (NSMutableDictionary *)dictionary {
    __block id dictionary;
    dispatch_block_t block = ^{
        dictionary = _dictionary;
    };
    
    if (dispatch_get_specific(self.cacheQueueSpecific)) {
        block();
    } else {
        dispatch_sync(self.queue, block);
    }
    
    return dictionary;
}

#pragma mark - GW2APICache protocol -

- (id)objectForKey:(NSString *)key {
    __block id object;
    dispatch_block_t block = ^{
        object = [self.dictionary objectForKey:key];
    };
    
    if (dispatch_get_specific(self.cacheQueueSpecific)) {
        block();
    } else {
        dispatch_sync(self.queue, block);
    }
    
    return object;
}

- (void)setObject:(id)object forKey:(NSString *)key {
    dispatch_block_t block = ^{
        [self.dictionary setObject:object forKey:key];
    };
    
    if (dispatch_get_specific(self.cacheQueueSpecific)) {
        block();
    } else {
        dispatch_barrier_sync(self.queue, block);
    }
}

- (void)removeObjectForKey:(NSString *)key {
    dispatch_block_t block = ^{
        [self.dictionary removeObjectForKey:key];
    };
    
    if (dispatch_get_specific(self.cacheQueueSpecific)) {
        block();
    } else {
        dispatch_barrier_sync(self.queue, block);
    }
}

- (void)removeAllObjects {
    dispatch_block_t block = ^{
        [self.dictionary removeAllObjects];
    };
    
    if (dispatch_get_specific(self.cacheQueueSpecific)) {
        block();
    } else {
        dispatch_barrier_sync(self.queue, block);
    }
}

@end
