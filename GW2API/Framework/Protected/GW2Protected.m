//
//  GW2Protected.m
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

#import "GW2Protected.h"

#pragma mark - GW2ReceipeID -

@implementation GW2RecipeID

- (NSString *)cacheKey {
    return @"gw2_recipes";
}

- (NSTimeInterval)timeout {
    return 60 * 60 * 24 * 28; // 28 days
}

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        [GW2 recipesWithError:error];
        return [self ID];
    };
}

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    return [api requestURL:@"recipes.json" params:nil];
}

+ (id)parseJSONData:(NSData *)jsonData error:(NSError *__autoreleasing *)error {
    NSError *error_;
    NSArray *json = [[NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error_] objectForKey:@"recipes"];
    if (error_ && error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, [error_ description]);
        *error = error_;
        return nil;
    }
    
    NSDate *now = [NSDate date];
    GW2Array *gw2Array = [[GW2Array alloc] init];
    [gw2Array setLastUpdate:now];
    for (NSNumber *ID in json) {
        GW2RecipeID *obj = [[GW2RecipeID alloc] initWithID:[ID stringValue]];
        [obj setLastUpdate:nil];
        [gw2Array addObject:obj];
    }
    
    return gw2Array;
}

+ (NSArray *)notificationNames {
    return @[GW2PveNotification];
}

@end

#pragma mark - GW2ItemID

@implementation GW2ItemID

- (NSString *)cacheKey {
    return @"gw2_items";
}

- (NSTimeInterval)timeout {
    return 60 * 60 * 24 * 28; // 28 days
}

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        [GW2 itemsWithError:error];
        return [self ID];
    };
}

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    return [api requestURL:@"items.json" params:nil];
}

+ (id)parseJSONData:(NSData *)jsonData error:(NSError *__autoreleasing *)error {
    NSError *error_;
    NSArray *json = [[NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error_] objectForKey:@"items"];
    if (error_ && error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, [error_ description]);
        *error = error_;
        return nil;
    }
    
    NSDate *now = [NSDate date];
    GW2Array *gw2Array = [[GW2Array alloc] init];
    [gw2Array setLastUpdate:now];
    for (NSNumber *ID in json) {
        GW2ItemID *obj = [[GW2ItemID alloc] initWithID:[ID stringValue]];
        [obj setLastUpdate:nil];
        [gw2Array addObject:obj];
    }
    
    return gw2Array;
}

+ (NSArray *)notificationNames {
    return @[GW2PveNotification];
}

@end

#pragma mark - GW2_ID NSString category -

@implementation NSString (GW2_ID)

- (NSString *)stringValue {
    return self;
}

@end
