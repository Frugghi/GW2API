//
//  GW2World.m
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

#import "GW2World.h"
#import "GW2Protected.h"

@implementation GW2World

#pragma mark - Init

- (id)initWithID:(NSString *)ID name:(NSString *)name {
    self = [super initWithID:ID];
    if (self) {
        [self setName:name];
    }
    
    return self;
}

#pragma mark - Properties

- (GW2RegionServer)region {
    @try {
        switch ([[[self ID] substringToIndex:1] intValue]) {
            case 1:  return GW2RegionNorthAmerica;
            case 2:  return GW2RegionEurope;
            default: return GW2RegionUnknown;
        }
    }
    @catch (NSException *exception) {
        return GW2RegionUnknown;
    }
}

- (GW2Language)language {
    @try {
        switch ([[[self ID] substringWithRange:NSMakeRange(1, 1)] intValue]) {
            case 0:  return GW2LanguageEnglish;
            case 1:  return GW2LanguageFrench;
            case 2:  return GW2LanguageGerman;
            case 3:  return GW2LanguageSpanish;
            default: return GW2LanguageUnknown;
        }
    }
    @catch (NSException *exception) {
        return GW2LanguageUnknown;
    }
}

- (NSString *)nameByTrimmingLangTag {
    NSUInteger index = [self.name rangeOfString:@"[" options:NSBackwardsSearch].location;
    if (index != NSNotFound){
        return [[self.name substringToIndex:index] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    return self.name;
}

#pragma mark - NSObject protocol

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %@, name: %@>", NSStringFromClass([self class]), self.ID, self.name];
}

#pragma mark - GW2Caching protocol

- (NSString *)cacheKey {
    return @"gw2_worlds";
}

- (NSTimeInterval)timeout {
    return 60 * 60 * 24 * 28; // 28 days
}

#pragma mark - GW2Fetching protocol

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        return [GW2 worldByID:[self ID] error:error];
    };
}

#pragma mark - Protected

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    return [api requestURL:@"world_names.json" params:@{@"lang": [api langCode]}];
}

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSArray *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    NSDate *now = [NSDate date];
    GW2Array *gw2Array = [[GW2Array alloc] init];
    for (NSDictionary *dict in json) {
        GW2World *obj = [[[self class] alloc] initWithID:dict[@"id"]
                                                    name:dict[@"name"]];
        [obj setLastUpdate:now];
        [gw2Array addObject:obj];
    }
    
    [gw2Array setLastUpdate:now];
    [gw2Array setTimeout:[[gw2Array lastObject] timeout]];
    [gw2Array setCacheKey:[[gw2Array lastObject] cacheKey]];
    
    return gw2Array;
}

+ (NSArray *)notificationNames {
    return @[GW2PveNotification, GW2EventNotification];
}

@end
