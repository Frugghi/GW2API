//
//  GW2Continent.m
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 02/07/13.
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

#import "GW2Continent.h"
#import "GW2Protected.h"

@implementation GW2Continent

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [self setName:[decoder decodeObjectForKey:@"name"]];
        [self setDimensions:[decoder decodeCGSizeForKey:@"dimensions"]];
        [self setMinZoom:[[decoder decodeObjectForKey:@"minZoom"] integerValue]];
        [self setMaxZoom:[[decoder decodeObjectForKey:@"maxZoom"] integerValue]];
        [self setMapFloors:[decoder decodeObjectForKey:@"floors"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeCGSize:self.dimensions forKey:@"dimensions"];
    [coder encodeObject:@(self.minZoom) forKey:@"minZoom"];
    [coder encodeObject:@(self.maxZoom) forKey:@"maxZoom"];
    [coder encodeObject:self.mapFloors forKey:@"floors"];
}

#pragma mark - NSObject protocol

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %@, name: %@, dimensions: %@, minZoom: %i, maxZoom: %i>",
            NSStringFromClass([self class]), self.ID, self.name, NSStringFromCGSize(self.dimensions), self.minZoom, self.maxZoom];
}

#pragma mark - GW2Caching protocol

- (NSString *)cacheKey {
    return @"gw2_continents";
}

- (NSTimeInterval)timeout {
    return 60 * 60 * 24 * 28; // 28 days
}

#pragma mark - GW2Fetching protocol

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        return [GW2 continentByID:[self ID] error:error];
    };
}

#pragma mark - Protected

- (void)copyObject:(GW2Object *)object withZone:(NSZone *)zone {
    [super copyObject:object withZone:zone];
    if ([object isKindOfClass:[GW2Continent class]]) {
        GW2Continent *continent = (GW2Continent *)object;
        [self setName:[continent.name copyWithZone:zone]];
        [self setDimensions:continent.dimensions];
        [self setMinZoom:continent.minZoom];
        [self setMaxZoom:continent.maxZoom];
        [self setMapFloors:[continent.mapFloors copyWithZone:zone]];
    }
}

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    return [api requestURL:@"continents.json" params:@{@"lang": [api langCode]}];
}

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSDictionary *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    NSDictionary *continents = [json objectForKey:@"continents"];
    NSDate *now = [NSDate date];
    GW2Array *gw2Array = [[GW2Array alloc] init];
    for (NSString *continentID in [continents allKeys]) {
        NSDictionary *continent = [continents objectForKey:continentID];
        GW2Continent *obj = [[[self class] alloc] initWithID:continentID];
        [obj setName:[continent objectForKey:@"name"]];
        NSArray *continentDims = [continent objectForKey:@"continent_dims"];
        [obj setDimensions:CGSizeMake([[continentDims objectAtIndex:0] integerValue], [[continentDims objectAtIndex:1] integerValue])];
        [obj setMinZoom:[[continent objectForKey:@"min_zoom"] integerValue]];
        [obj setMaxZoom:[[continent objectForKey:@"max_zoom"] integerValue]];
        [obj setMapFloors:[continent objectForKey:@"floors"]];
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
