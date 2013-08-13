//
//  GW2Match.m
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 21/05/13.
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

#import "GW2Match.h"
#import "GW2Protected.h"

@implementation GW2Match

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [self setRedWorld:[decoder decodeObjectForKey:@"redworld"]];
        [self setBlueWorld:[decoder decodeObjectForKey:@"blueworld"]];
        [self setGreenWorld:[decoder decodeObjectForKey:@"greenworld"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.redWorld forKey:@"redworld"];
    [coder encodeObject:self.blueWorld forKey:@"blueworld"];
    [coder encodeObject:self.greenWorld forKey:@"greenworld"];
}

#pragma mark - Properties

- (NSString *)matchDetailsID {
    return [self ID];
}

- (GW2RegionServer)region {
    @try {
        switch ([[[self ID] substringToIndex:1] intValue]) {
            case 1: return GW2RegionNorthAmerica;
            case 2: return GW2RegionEurope;
            default: return GW2RegionUnknown;
        }
    }
    @catch (NSException *exception) {
        return GW2RegionUnknown;
    }
}

- (NSInteger)tier {
    return [[[[self ID] componentsSeparatedByString:@"-"] lastObject] integerValue];
}

#pragma mark - NSObject protocol

- (NSString *)description {
	return [NSString stringWithFormat:@"[%@] R:%@ B:%@ G:%@", self.ID, self.redWorld, self.blueWorld, self.greenWorld];
}

#pragma mark - GW2Caching protocol

- (NSString *)cacheKey {
    return @"gw2_wvwmatches";
}

- (NSTimeInterval)timeout {
    NSTimeInterval europeReset = [GW2API timeIntervalBeforeWvWReset:GW2RegionEurope];
    NSTimeInterval northAmericaReset = [GW2API timeIntervalBeforeWvWReset:GW2RegionNorthAmerica];
    return MIN(europeReset, northAmericaReset);
}

#pragma mark - GW2Fetching protocol

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        return [GW2 matchByID:[self ID] error:error];
    };
}

#pragma mark - Protected

- (void)copyObject:(GW2Object *)object withZone:(NSZone *)zone {
    [super copyObject:object withZone:zone];
    if ([object isKindOfClass:[GW2Match class]]) {
        GW2Match *match = (GW2Match *)object;
        [self setRedWorld:[match.redWorld copyWithZone:zone]];
        [self setBlueWorld:[match.blueWorld copyWithZone:zone]];
        [self setGreenWorld:[match.greenWorld copyWithZone:zone]];
    }
}

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    return [api requestURL:@"wvw/matches.json" params:nil];
}

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSDictionary *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    NSDate *now = [NSDate date];
    GW2Array *gw2Array = [[GW2Array alloc] init];
    for (NSDictionary *dict in [json objectForKey:@"wvw_matches"]) {
        GW2Match *obj = [[[self class] alloc] initWithID:[dict objectForKey:@"wvw_match_id"]];
        [obj setRedWorld:[GW2 worldByID:[[dict objectForKey:@"red_world_id"] stringValue]]];
        [obj setBlueWorld:[GW2 worldByID:[[dict objectForKey:@"blue_world_id"] stringValue]]];
        [obj setGreenWorld:[GW2 worldByID:[[dict objectForKey:@"green_world_id"] stringValue]]];
        [obj setLastUpdate:now];
        [gw2Array addObject:obj];
    }
    
    [gw2Array setLastUpdate:now];
    [gw2Array setTimeout:[[gw2Array lastObject] timeout]];
    [gw2Array setCacheKey:[[gw2Array lastObject] cacheKey]];
        
    return gw2Array;
}

+ (NSArray *)notificationNames {
    return @[GW2WvWNotification, GW2WvWMatchNotification];
}

@end
