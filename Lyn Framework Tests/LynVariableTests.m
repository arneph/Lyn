//
//  LynVariableTests.m
//  Lyn
//
//  Created by Programmieren on 27.09.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lyn Framework/Lyn Framework.h>

@interface LynVariableTests : XCTestCase

@end

@implementation LynVariableTests{
    LynVariable *variable;
    
    LynVariableBoolean *boolean;
    LynVariableInteger *integer;
    LynVariableString *string;
}

- (void)setUp{
    [super setUp];
    variable = [[LynVariable alloc] init];
    boolean = [[LynVariableBoolean alloc] init];
    integer = [[LynVariableInteger alloc] init];
    string = [[LynVariableString alloc] init];
}

- (void)tearDown{
    variable = nil;
    boolean = nil;
    integer = nil;
    string = nil;
    [super tearDown];
}

- (void)testArchiving{
    variable.name = @"abcd";
    variable.value = @123;
    [variable addReference:self];
    NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:variable];
    LynVariable *unarchivedVariable = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
    XCTAssertTrue([variable.name isEqualToString:unarchivedVariable.name],
                   @"Archives Variable Names not properly.");
    XCTAssertTrue([variable.value isEqualTo:unarchivedVariable.value],
                   @"Archives Variable Values not properly.");
    XCTAssertFalse((unarchivedVariable.referenceCount > 0),
                  @"Variables archvie Referencers.");
}

- (void)testCopying{
    variable.name = @"abcd";
    variable.value = @123;
    [variable addReference:self];
    LynVariable *copiedVariable = [variable copy];
    XCTAssertTrue([variable.name isEqualToString:copiedVariable.name],
                   @"Copies Variable Names not properly.");
    XCTAssertTrue([variable.value isEqualTo:copiedVariable.value],
                   @"Copies Variable Values not properly.");
    XCTAssertFalse((copiedVariable.referenceCount > 0),
                  @"Variables copies Referencers.");
}

- (void)testNaming{
    XCTAssertNoThrow([variable setName:@"test123!=?"],
                     @"Variable throws unexpected exception on renaming.");
    XCTAssert([variable.name isEqualToString:@"test123!=?"],
              @"Variable doesn't take new name.");
    XCTAssertThrows([variable setName:@""],
                    @"Variable accepts empty name.");
    XCTAssertThrows([variable setName:@"oi<g oyjg"],
                    @"Variable accepts name with ' '.");
    XCTAssertThrows([variable setName:@"pogrkm/123prm"],
                    @"Variable accepts name with '/'.");
}

- (void)testReferencing{
    XCTAssert(variable.referenceCount < 1,
              @"Variable gets initialized with refernce counts");
    XCTAssertNoThrow([variable addReference:self],
                     @"Variable isn't referneceable by new referencers.");
    XCTAssert(variable.referenceCount == 1,
              @"Variable didn't add new referencer");
    XCTAssertThrows([variable addReference:self],
                    @"Variable is refernceable twice.");
    XCTAssertNoThrow([variable removeReference:self],
                     @"Variable isn't derefernceable by existing referencers.");
    XCTAssert(variable.referenceCount < 1,
              @"Variable didn't remove old referencer.");
    XCTAssertThrows([variable removeReference:self],
                    @"Variable is dereferencable twice.");
}

@end
