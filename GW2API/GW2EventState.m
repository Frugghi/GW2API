//
//  GW2EventStatus.m
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 27/05/13.
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

#import "GW2EventState.h"
#import "GW2Protected.h"

@implementation GW2EventState

- (void)setID:(NSString *)ID {
    NSArray *components = [ID componentsSeparatedByString:@"_"];
    [self setWorldID:components[0]];
    [self setZoneID:components[1]];
    [self setEventID:components[2]];
}

- (NSString *)ID {
    return [NSString stringWithFormat:@"%@_%@_%@",
            (self.worldID ? self.worldID : @""), (self.zoneID ? self.zoneID : @""), (self.eventID ? self.eventID : @"")];
}

#pragma mark - NSObject protocol

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: world: %@, zone: %@, event: %@, state: %@>",
            NSStringFromClass([self class]), self.worldID, self.zoneID, self.eventID, [GW2API stateName:self.state]];
}

#pragma mark - GW2Caching protocol

- (NSTimeInterval)timeout {
    return 20; // 20 sec
}

- (NSString *)cacheKey {
    return [NSString stringWithFormat:@"gw2_eventstatus_%@", self.ID];
}

#pragma mark - GW2Fetching protocol

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        return [GW2 eventStateByID:[self ID] error:error];
    };
}

#pragma mark - Protected

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    NSArray *components = [ID componentsSeparatedByString:@"_"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if ([components[0] length] > 0) {
        [params setObject:components[0] forKey:@"world_id"];
    }
    
    if ([components[1] length] > 0) {
        [params setObject:components[1] forKey:@"zone_id"];
    }
    
    if ([components[2] length] > 0) {
        [params setObject:components[2] forKey:@"event_id"];
    }
    
    return [api requestURL:@"events.json" params:params];
}

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSDictionary *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    NSMutableSet *events = [[NSMutableSet alloc] init];
    NSMutableSet *maps = [[NSMutableSet alloc] init];
    NSMutableSet *worlds = [[NSMutableSet alloc] init];
    NSDate *now = [NSDate date];
    GW2Array *gw2Array = [[GW2Array alloc] init];
    for (NSDictionary *dict in json[@"events"]) {
        GW2EventState *obj = [[[self class] alloc] init];
        [obj setEventID:dict[@"event_id"]];
        [obj setZoneID:[dict[@"map_id"] stringValue]];
        [obj setWorldID:[dict[@"world_id"] stringValue]];
        [obj setState:[self stateTypeFromString:dict[@"state"]]];
        [obj setLastUpdate:now];
        [events addObject:obj.eventID];
        [maps addObject:obj.zoneID];
        [worlds addObject:obj.worldID];
        [gw2Array addObject:obj];
    }
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@_%@",
                          ([worlds count] == 1 ? [worlds anyObject] : @""),
                          ([maps count] == 1 ? [maps anyObject] : @""),
                          ([events count] == 1 ? [events anyObject] : @"")];
    
    [gw2Array setLastUpdate:now];
    [gw2Array setTimeout:[[gw2Array lastObject] timeout]];
    [gw2Array setCacheKey:cacheKey];
        
    return gw2Array;
}

+ (NSArray *)notificationNames {
    return @[GW2PveNotification, GW2EventNotification];
}

+ (GW2EventStateType)stateTypeFromString:(NSString *)string {
    NSString *state = [string lowercaseString];
    
    if ([state isEqualToString:@"warmup"]) {
        return GW2EventStateWarmup;
    } else if ([state isEqualToString:@"preparation"]) {
        return GW2EventStatePreparation;
    } else if ([state isEqualToString:@"active"]) {
        return GW2EventStateActive;
    } else if ([state isEqualToString:@"success"]) {
        return GW2EventStateSuccess;
    } else if ([state isEqualToString:@"fail"]) {
        return GW2EventStateFail;
    } else if ([state isEqualToString:@"inactive"]) {
        return GW2EventStateInactive;
    }
    
    return GW2EventStateUnknown;
}

@end
