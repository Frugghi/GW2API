//
//  GW2RecipeID.m
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 12/08/13.
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

#import "GW2RecipeID.h"
#import "GW2Protected.h"

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

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSDictionary *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    NSDate *now = [NSDate date];
    GW2Array *gw2Array = [[GW2Array alloc] init];
    [gw2Array setLastUpdate:now];
    for (NSNumber *ID in [json objectForKey:@"recipes"]) {
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
