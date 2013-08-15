//
//  GW2Map.m
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 05/07/13.
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

#import "GW2Map.h"
#import "GW2Protected.h"

@implementation GW2Map

#pragma mark - NSObject protocol

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %@, name: %@, minLevel: %li, maxLevel: %li, defaultFloor: %li, region: %@, continent: %@, mapRect: %@, continentRect: %@>",
            NSStringFromClass([self class]), self.ID, self.name, (long)self.minLevel, (long)self.maxLevel, (long)[self.defaultFloor integerValue], self.regionName, self.continentName, NSStringFromCGRect(self.mapRect), NSStringFromCGRect(self.continentRect)];
}

#pragma mark - GW2Caching protocol

- (NSString *)cacheKey {
    return @"gw2_maps";
}

- (NSTimeInterval)timeout {
    return 60 * 60 * 24 * 28; // 28 days
}

#pragma mark - GW2Fetching protocol

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        return [GW2 mapByID:[self ID] error:error];
    };
}

#pragma mark - Protected

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    NSDictionary *params;
    if (ID) {
        params = @{@"lang": [api langCode], @"map_id": ID};
    } else {
        params = @{@"lang": [api langCode]};
    }
    
    return [api requestURL:@"maps.json" params:params];
}

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSDictionary *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    NSDictionary *maps = json[@"maps"];
    NSDate *now = [NSDate date];
    GW2Array *gw2Array = [[GW2Array alloc] init];
    for (NSString *mapID in maps) {
        NSDictionary *map = maps[mapID];
        GW2Map *obj = [[[self class] alloc] initWithID:mapID];
        [obj setName:map[@"map_name"]];
        [obj setMinLevel:[map[@"min_level"] integerValue]];
        [obj setMaxLevel:[map[@"max_level"] integerValue]];
        [obj setDefaultFloor:map[@"default_floor"]];
        [obj setFloors:map[@"floors"]];
        [obj setRegionID:[map[@"region_id"] stringValue]];
        [obj setRegionName:map[@"region_name"]];
        [obj setContinentID:[map[@"continent_id"] stringValue]];
        [obj setContinentName:map[@"continent_name"]];
        [obj setMapRect:CGRectFromArray(map[@"map_rect"])];
        [obj setContinentRect:CGRectFromArray(map[@"continent_rect"])];
        [obj setLastUpdate:now];
        [gw2Array addObject:obj];
    }
    
    [gw2Array setLastUpdate:now];
    [gw2Array setTimeout:[[gw2Array lastObject] timeout]];
    [gw2Array setCacheKey:[[gw2Array lastObject] cacheKey]];
    
    return gw2Array;
}

+ (NSArray *)notificationNames {
    return @[GW2PveNotification, GW2WvWNotification, GW2MapNotification];
}

@end
