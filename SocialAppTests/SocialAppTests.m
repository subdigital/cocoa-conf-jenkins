//
//  SocialAppTests.m
//  SocialAppTests
//
//  Created by ben on 3/3/13.
//  Copyright (c) 2013 NSScreencast. All rights reserved.
//

#import "SocialAppTests.h"

@implementation SocialAppTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testMath {
    STAssertEquals(1+1, 2, @"Math is broken");
}

- (void)testExample
{
    STAssertEquals(1, 1, @"yep");
//    STFail(@"Unit tests are not implemented yet in SocialAppTests");
}

@end
