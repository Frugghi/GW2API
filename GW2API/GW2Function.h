//
//  GW2Function.h
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

#ifndef GW2API_iOS_GW2Function_h
#define GW2API_iOS_GW2Function_h

static inline CGPoint CGPointFromArray(NSArray *array) {
    return CGPointMake([array[0] integerValue], [array[1] integerValue]);
}

static inline CGSize CGSizeFromArray(NSArray *array) {
    return CGSizeMake([array[0] integerValue], [array[1] integerValue]);
}

static inline CGRect CGRectFromArray(NSArray *array) {
    return CGRectMake([array[0][0] integerValue], [array[0][1] integerValue], [array[1][0] integerValue], [array[1][0] integerValue]);
}

#if !(TARGET_OS_IPHONE)

static inline NSString *NSStringFromCGPoint(CGPoint point) {
    return NSStringFromPoint(point);
}

static inline NSString *NSStringFromCGSize(CGSize size) {
    return NSStringFromSize(size);
}

static inline NSString *NSStringFromCGRect(CGRect rect) {
    return NSStringFromRect(rect);
}

#endif

#endif
