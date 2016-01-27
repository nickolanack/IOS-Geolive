//
//  IOS-GeoliveTests.m
//  IOS-GeoliveTests
//
//  Created by nickolanack on 01/26/2016.
//  Copyright (c) 2016 nickolanack. All rights reserved.
//
#import "GeoliveServer.h"

@import XCTest;

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    
    GeoliveServer *system=[[GeoliveServer alloc] initWithName:@"Test_"];
    
    
}

@end

