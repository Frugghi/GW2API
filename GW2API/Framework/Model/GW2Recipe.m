//
//  GW2Recipe.m
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

#import "GW2Recipe.h"
#import "GW2Protected.h"

@implementation GW2Recipe

NSString *const GW2RecipeInputItemIDKey = @"item_id";
NSString *const GW2RecipeInputItemCountKey = @"count";

#pragma mark - NSCoding protocol -

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [self setType:[decoder decodeObjectForKey:@"type"]];
        [self setOutputItemID:[decoder decodeObjectForKey:@"outputID"]];
        [self setOutputCount:[[decoder decodeObjectForKey:@"outputCount"] integerValue]];
        [self setMinRating:[[decoder decodeObjectForKey:@"minRating"] integerValue]];
        [self setTimeToCraft:[[decoder decodeObjectForKey:@"timeToCraft"] integerValue]];
        [self setIngredients:[decoder decodeObjectForKey:@"ingredients"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.outputItemID forKey:@"outputID"];
    [coder encodeObject:@(self.outputCount) forKey:@"outputCount"];
    [coder encodeObject:@(self.minRating) forKey:@"minRating"];
    [coder encodeObject:@(self.timeToCraft) forKey:@"timeToCraft"];
    [coder encodeObject:self.ingredients forKey:@"ingredients"];
}

#pragma mark - NSObject -

- (NSString *)description {
	return [NSString stringWithFormat:@"[%@] x%i %@ %@", self.ID, self.outputCount, self.outputItemID, self.type];
}

#pragma mark - GW2Caching protocol -

- (NSTimeInterval)timeout {
    return 60 * 60 * 24 * 28; // 28 days
}

- (NSString *)cacheKey {
    return [NSString stringWithFormat:@"gw2_recipe_%@", self.ID];
}

#pragma mark - GW2Fetching protocol

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        return [GW2 recipeByID:[self ID] error:error];
    };
}

#pragma mark - Protected -

- (void)copyObject:(GW2Object *)object withZone:(NSZone *)zone {
    [super copyObject:object withZone:zone];
    if ([object isKindOfClass:[GW2Recipe class]]) {
        GW2Recipe *recipe = (GW2Recipe *)object;
        [self setType:[recipe.type copyWithZone:zone]];
        [self setOutputItemID:[recipe.outputItemID copyWithZone:zone]];
        [self setOutputCount:recipe.outputCount];
        [self setMinRating:recipe.minRating];
        [self setTimeToCraft:recipe.timeToCraft];
        [self setIngredients:[recipe.ingredients copyWithZone:zone]];
    }
}

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    return [api requestURL:@"recipe_details.json" params:@{@"recipe_id": ID}];
}

+ (id)parseJSONData:(NSData *)jsonData error:(NSError *__autoreleasing *)error {
    NSError *error_;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error_];
    if (error_ && error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, [error_ description]);
        *error = error_;
        return nil;
    }

    GW2Recipe *obj = [[[self class] alloc] initWithID:[json objectForKey:@"recipe_id"]];
    [obj setLastUpdate:[NSDate date]];
    
    [obj setType:[json objectForKey:@"type"]];
    [obj setOutputItemID:[json objectForKey:@"output_item_id"]];
    [obj setOutputCount:[[json objectForKey:@"output_item_count"] integerValue]];
    [obj setMinRating:[[json objectForKey:@"min_rating"] integerValue]];
    [obj setTimeToCraft:[[json objectForKey:@"time_to_craft_ms"] integerValue]];
    [obj setIngredients:[json objectForKey:@"ingredients"]];
    
    return obj;
}

+ (NSArray *)notificationNames {
    return @[GW2PveNotification, GW2RecipeNotification];
}

@end
