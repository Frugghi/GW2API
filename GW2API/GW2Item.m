//
//  GW2Item.m
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

#import "GW2Item.h"
#import "GW2Protected.h"

@implementation GW2Item

#pragma mark - NSObject protocol

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %@, name: %@, description: %@, rarity: %@, level %li>",
            NSStringFromClass([self class]), self.ID, self.name, self.description, self.rarity, (long)self.level];
}

#pragma mark - GW2Caching protocol

- (NSTimeInterval)timeout {
    return 60 * 60 * 24 * 28; // 28 days
}

- (NSString *)cacheKey {
    return [NSString stringWithFormat:@"gw2_item_%@", self.ID];
}

#pragma mark - GW2Fetching protocol

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        return [GW2 itemByID:[self ID] error:error];
    };
}

#pragma mark - Protected

+ (NSURL *)requestURL:(GW2API *)api withID:(NSString *)ID {
    return [api requestURL:@"item_details.json" params:@{@"item_id": ID}];
}

+ (id)parseJSONData:(NSData *)jsonData requestURL:(NSURL *)requestURL error:(NSError *__autoreleasing *)error {
    NSDictionary *json = [super parseJSONData:jsonData requestURL:requestURL error:error];
    if (!json) {
        return nil;
    }
    
    GW2Item *obj = [[[self class] alloc] initWithID:json[@"item_id"]];    
    [obj setName:json[@"name"]];
    [obj setDescription:json[@"description"]];
    [obj setType:json[@"type"]];
    [obj setLevel:[json[@"level"] integerValue]];
    [obj setRarity:json[@"rarity"]];
    [obj setVendorValue:[json[@"vendor_value"] integerValue]];
    [obj setGameTypes:json[@"game_types"]];
    [obj setFlags:json[@"flags"]];
    [obj setRestrictions:json[@"restrictions"]];
    
    NSString *attributeKey = [self attributeKeyFromType:obj.type];
    if (attributeKey) {
        [obj setAttributes:json[attributeKey]];
    }
    
    return obj;
}

+ (NSArray *)notificationNames {
    return @[GW2PveNotification, GW2ItemNotification];
}

+ (NSString *)attributeKeyFromType:(NSString *)type {
    NSString *attributeKey = [type lowercaseString];
    
    if ([attributeKey isEqualToString:@"craftingmaterial"] || [attributeKey isEqualToString:@"trophy"] || [attributeKey isEqualToString:@"minipet"]) {
        attributeKey = nil;
    } else if ([attributeKey isEqualToString:@"upgradecomponent"]) {
        attributeKey = @"upgrade_component";
    }
    
    return attributeKey;
}

@end
