//
//  ViewController.m
//  GW2API
//
//  Created by Tommaso Madonia on 27/05/13.
//  Copyright (c) 2013 Tommaso Madonia. All rights reserved.
//

#import "ViewController.h"
#import "GW2.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self performSelector:@selector(example) withObject:nil afterDelay:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)example
{
    // List of server
    NSLog(@"%@", [GW2 worlds]);
    
    // List of WvW matches
    NSLog(@"%@", [GW2 matches]);
}

@end
