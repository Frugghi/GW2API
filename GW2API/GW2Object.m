//
//  GW2Object.m
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 22/05/13.
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

#import "GW2Object.h"
#import "GW2Protected.h"

@implementation GW2Object

@synthesize lastUpdate = _lastUpdate;

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        [self setLastUpdate:[NSDate date]];
    }
    
    return self;
}

- (id)initWithID:(NSString *)ID {
    self = [super init];
    if (self) {
        [self setID:[ID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [self setLastUpdate:[NSDate date]];
    }
    
    return self;
}

#pragma mark - NSObject protocol

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[self class]]) {
		return [self.ID isEqualToString:[(GW2Object *)object ID]];
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [[self description] hash];
}

#pragma mark - GW2Caching protocol

- (NSString *)cacheKey {
    return @"GW2Object";
}

- (void)invalidateCache {
    [GW2 removeObjectForKey:[self cacheKey]];
}

- (NSTimeInterval)timeout {
    return 0;
}

- (BOOL)isExpired {
    if (!self.lastUpdate) {
        return NO;
    }
    
    return [[NSDate date] timeIntervalSinceDate:self.lastUpdate] > [self timeout];
}

#pragma mark - GW2Fetching protocol

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error)  {
        return nil;
    };
}

#pragma mark - Protected

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSError *jsonError;
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
    if (jsonError && error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, [jsonError description]);
        if (error) {
            *error = jsonError;
        }
        
        return nil;
    }
    
    return json;
}

+ (NSArray *)notificationNames {
    return @[];
}

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    return nil;
}

@end
