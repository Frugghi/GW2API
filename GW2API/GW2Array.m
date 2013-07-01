//
//  GW2Array.m
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

#import "GW2Array.h"
#import "GW2Protected.h"

@interface GW2Array ()

@property (nonatomic, strong) NSMutableArray *objects;

@end

@implementation GW2Array

@synthesize lastUpdate = _lastUpdate;

#pragma mark - Init -

- (id)init {
    self = [super init];
    if (self) {
        [self setObjects:[[NSMutableArray alloc] init]];
        [self setLastUpdate:[NSDate date]];
        [self setTimeout:0];
        [self setCacheKey:@"gw2Array"];
    }
    
    return self;
}

- (id)initWithArray:(NSArray *)array {
    self = [self init];
    if (self) {
        [self.objects addObjectsFromArray:array];
    }
    
    return self;
}

#pragma mark - NSCoding -

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        [self setObjects:[[decoder decodeObjectForKey:@"objects"] mutableCopy]];
        [self setLastUpdate:[decoder decodeObjectForKey:@"lastupdate"]];
        [self setCacheKey:[decoder decodeObjectForKey:@"cacheKey"]];
        [self setTimeout:[[decoder decodeObjectForKey:@"timeout"] doubleValue]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.objects forKey:@"objects"];
    [coder encodeObject:self.lastUpdate forKey:@"lastupdate"];
    [coder encodeObject:@(self.timeout) forKey:@"timeout"];
    [coder encodeObject:self.cacheKey forKey:@"cacheKey"];
}

#pragma mark - Public -

- (NSArray *)array {
    return [self.objects copy];
}

- (NSArray *)arrayID {
    NSMutableArray *arrayID = [[NSMutableArray alloc] init];
    for (GW2Object *obj in self) {
        if ([obj isKindOfClass:[GW2Object class]]) {
            [arrayID addObject:[obj ID]];
        }
    }
    
    return [arrayID copy];
}

- (NSUInteger)count {
    return [self.objects count];
}

- (NSUInteger)indexOfObject:(id)object {
    return [self.objects indexOfObject:object];
}

- (NSUInteger)indexOfObjectWithID:(NSString *)ID {
    id object = [self objectWithID:ID];
    if (object) {
        return [self indexOfObject:object];
    }
    
    return NSNotFound;
}

- (id)objectWithID:(NSString *)ID {
    for (GW2Object *obj in self) {
        if ([obj isKindOfClass:[GW2Object class]] && [[obj ID] isEqualToString:ID]) {
            return obj;
        }
    }
    
    return nil;
}

- (id)objectAtIndex:(NSUInteger)index {
    return [self.objects objectAtIndex:index];
}

- (id)firstObject {
    if ([self count] == 0) {
        return nil;
    }
    
    return [self.objects objectAtIndex:0];
}
- (id)lastObject {
    return [self.objects lastObject];
}

- (void)addObject:(id)obj {
    [self.objects addObject:obj];
}

- (void)addObjectsFromArray:(NSArray *)array {
    [self.objects addObjectsFromArray:array];
}

- (void)addObjectsFromSet:(NSSet *)set {
    [self.objects addObjectsFromArray:[set allObjects]];
}

- (void)removeObject:(id)obj {
    [self.objects removeObject:obj];
}

- (void)removeAllObjects {
    [self.objects removeAllObjects];
}

- (BOOL)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object {
    if (index < [self count]) {
        [self.objects replaceObjectAtIndex:index withObject:object];
        return YES;
    }
    
    return NO;
}

- (void)sortUsingComparator:(NSComparator)cmptr {
    [self.objects sortUsingComparator:cmptr];
}

- (void)filterUsingPredicate:(NSPredicate *)predicate {
    [self.objects filterUsingPredicate:predicate];
}

- (id)filteredArrayUsingPredicate:(NSPredicate *)predicate {
    GW2Array *filteredCollection = [self copy];
    [filteredCollection.objects filterUsingPredicate:predicate];
    
    return filteredCollection;
}

#pragma mark - NSFastEnumeration protocol -

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    return [self.objects countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - NSCopying protocol -

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
		[copy setObjects:[self.objects mutableCopyWithZone:zone]];
        [copy setLastUpdate:[self.lastUpdate copyWithZone:zone]];
        [copy setCacheKey:[self.cacheKey copyWithZone:zone]];
        [copy setTimeout:self.timeout];
    }
    	
    return copy;
}

#pragma mark - NSObject protocol -

- (NSString *)description {
    return [self.objects description];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[self class]]) {
		return [[self objects] isEqualToArray:[(GW2Array *)object objects]];
	}
    
	return NO;
}

- (NSUInteger)hash {
	return [self.objects hash];
}

#pragma mark - GW2Fetching protocol -

- (GW2FetchBlock)fetchBlock {
    return (GW2FetchBlock) ^(NSError **error) {
        GW2Array *array = [[GW2Array alloc] init];
        [array setCacheKey:self.cacheKey];
        [array setTimeout:self.timeout];
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_queue_create("com.GW2.fetchArrayQueue", DISPATCH_QUEUE_CONCURRENT);
        for (id obj in self) {
            if ([obj conformsToProtocol:@protocol(GW2Fetching)]) {
                dispatch_group_async(group, queue, ^{
                    id updatedObject = [GW2 fetch:obj error:error];
                    if (updatedObject) {
                        [array addObject:updatedObject];
                    }
                });
            }
        }
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        [array setLastUpdate:[NSDate date]];
        
        return array;
    };
}

#pragma mark - GW2Caching protocol -

- (BOOL)isExpired {
    if (!self.lastUpdate) {
        return NO;
    }
    
    return [[NSDate date] timeIntervalSinceDate:self.lastUpdate] > [self timeout];
}

- (void)invalidateCache {
    [GW2 removeObjectForKey:[self cacheKey]];
}

@end
