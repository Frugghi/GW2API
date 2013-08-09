# GW2API

GW2API is an Objective-C framework for iOS and OS X that wraps the Guild Wars 2 API.

## Requirements

- **OS X**: Not tested
- **iOS**: 6.0+
- **ARC**: Yes

## Installation

1. Download the framework from the [framework branch](https://github.com/Frugghi/GW2API/tree/framework) or compile it
2. Drag `GW2.framework` into your project
3. Import the GW2 header `#import <GW2/GW2.h>`

## How does it work?

### The cache

GW2API automatically cache your requests for a certain amount of time. Insted of using the default cache implementation (`GW2Cache`)
you should provide your own implementation. The cache must conform to `GW2APICache` protocol.

**Example:** ([TMCache](https://github.com/tumblr/TMCache))
```objective-c
    [[GW2 api] setCacheClass:[TMCache class]];
```

### Synchronous or Asynchronous?

The framework implements both synchronous and asynchronous methods, you can recognize an asynchronous method from the completitionBlock: param.

```objective-c
    // asynchronous, return the world with ID 2002 (Desolation EU)
    [GW2 worldByID:@"2002" completitionBlock:^(GW2Object *obj, NSError *error) {
        NSLog(@"%@", obj);
    }];

    // synchronous, return the list of wvw matches
    NSLog(@"%@", [GW2 matches]);
```

## Questions

Feel free to contact me if you need any help with GW2API framework.

Email: frugghi@gmail.com<br />Gw2: [Frugghi.9046](https://forum-en.guildwars2.com/members/frugghi-9046)

## License

Copyright (c) 2013 Tommaso Madonia. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
