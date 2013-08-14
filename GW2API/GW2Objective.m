//
//  GW2WvWObjective.m
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

#import "GW2Objective.h"
#import "GW2Protected.h"

@implementation GW2Objective

#pragma mark - Init

- (id)initWithID:(NSString *)ID name:(NSString *)name {
    self = [super initWithID:ID];
    if (self) {
        [self setName:name];
    }
    
    return self;
}

#pragma mark - Properties

- (GW2ObjectiveType)type {
    @try {
        switch ([[self ID] intValue]) {
            case 1:
            case 2:
            case 3:
            case 10:
            case 23:
            case 27:
            case 31:
            case 32:
            case 33:
            case 37:
            case 41:
            case 44:
            case 46:
                return GW2ObjectiveKeep;
            case 4:
            case 5:
            case 6:
            case 7:
            case 8:
            case 24:
            case 29:
            case 34:
            case 39:
            case 43:
            case 48:
            case 49:
            case 50:
            case 51:
            case 52:
            case 53:
            case 54:
            case 55:
            case 56:
            case 58:
            case 59:
            case 60:
            case 61:
                return GW2ObjectiveCamp;
            case 11:
            case 12:
            case 13:
            case 14:
            case 15:
            case 16:
            case 17:
            case 18:
            case 19:
            case 20:
            case 21:
            case 22:
            case 25:
            case 26:
            case 28:
            case 30:
            case 35:
            case 36:
            case 38:
            case 40:
            case 42:
            case 45:
            case 47:
            case 57:
                return GW2ObjectiveTower;
            case 9:
                return GW2ObjectiveCastle;
            default:
                return GW2ObjectiveUnknown;
        }
    }
    @catch (NSException *exception) {
        return GW2ObjectiveUnknown;
    }
}

- (NSUInteger)points {
    switch ([self type]) {
        case GW2ObjectiveUnknown: return  0;
        case GW2ObjectiveCamp:    return  5;
        case GW2ObjectiveTower:   return 10;
        case GW2ObjectiveKeep:    return 25;
        case GW2ObjectiveCastle:  return 35;
    }
}

#pragma mark - NSObject protocol

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %@, name: %@, team: %li, guild: %@>", NSStringFromClass([self class]), self.ID, self.name, (long)self.ownerTeam, self.ownerGuild];
}

#pragma mark - GW2Caching protocol

- (NSString *)cacheKey {
    return @"gw2_wvwobjective";
}

- (NSTimeInterval)timeout {
    return 60 * 60 * 24 * 28; // 28 days
}

#pragma mark - GW2Fetching protocol

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        return [GW2 objectiveByID:[self ID] error:error];
    };
}

#pragma mark - Protected

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    return [api requestURL:@"wvw/objective_names.json" params:@{@"lang": [api langCode]}];
}

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSArray *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    NSDate *now = [NSDate date];
    GW2Array *gw2Array = [[GW2Array alloc] init];
    for (NSDictionary *dict in json) {
        GW2Objective *obj = [[[self class] alloc] initWithID:dict[@"id"]
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
    return @[GW2WvWNotification, GW2WvWObjectiveNotification];
}

@end
