//
//  NSCoder+IOS_Wrapper.m
//  GW2API for ObjC
//
//  Created by Tommaso Madonia on 09/08/13.
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

#import "NSCoder+IOS_Wrapper.h"

@implementation NSCoder (IOS_Wrapper)

- (void)encodeCGSize:(CGSize)size forKey:(NSString *)key {
    [self encodeSize:size forKey:key];
}

- (void)encodeCGPoint:(CGPoint)point forKey:(NSString *)key {
    [self encodePoint:point forKey:key];
}

- (void)encodeCGRect:(CGRect)rect forKey:(NSString *)key {
    [self encodeRect:rect forKey:key];
}

- (CGSize)decodeCGSizeForKey:(NSString *)key {
    return [self decodeSizeForKey:key];
}

- (CGPoint)decodeCGPointForKey:(NSString *)key {
    return [self decodePointForKey:key];
}

- (CGRect)decodeCGRectForKey:(NSString *)key {
    return [self decodeRectForKey:key];
}

@end