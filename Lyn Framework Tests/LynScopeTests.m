//
//  LynScopeTests.m
//  Lyn
//
//  Created by Programmieren on 11.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Lyn Framework/Lyn Framework.h>

@interface LynScopeTests : XCTestCase

@end

@implementation LynScopeTests{
    LynScope *scope;
    
    LynVariableBoolean *boolean;
    LynVariableInteger *integer;
    LynVariableString *string;
}

- (void)setUp{
    [super setUp];
    scope = [[LynScope alloc] init];
    
    boolean = [[LynVariableBoolean alloc] init];
    integer = [[LynVariableInteger alloc] init];
    string = [[LynVariableString alloc] init];
    
    [scope.variables addObjectsFromArray:@[boolean, integer, string]];
}

- (void)tearDown{
    boolean = nil;
    integer = nil;
    string = nil;
    [super tearDown];
}

- (void)testArchiving{
    boolean.name = @"t";
    integer.value = @42;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:scope];
    LynScope *unarchivedScope = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertTrue(unarchivedScope.variables.count == scope.variables.count,
                  @"Archives Variables of Scopes not properly.");
    LynVariableBoolean *unarchivedBoolean = unarchivedScope.variables[0];
    LynVariableInteger *unarchivedInteger = unarchivedScope.variables[1];
    XCTAssertEqualObjects(boolean.name, unarchivedBoolean.name,
                          @"Archives Variable Names in Scopes not properly.");
    XCTAssertEqualObjects(integer.value, unarchivedInteger.value,
                          @"Archives Variable Values in Scopes not properly.");
    XCTAssertEqualObjects(unarchivedBoolean, [unarchivedScope variableNamed:@"t" inSuperScopes:NO],
                          @"After unarchiving querrying for variables doesn't work anymore in Scopes.");
}

- (void)testCopying{
    boolean.name = @"t";
    integer.value = @42;
    XCTAssertThrows(scope.copy, @"Nameless variables can be copied");
    integer.name = @"u";
    string.name = @"v";
    LynScope *copiedScope = scope.copy;
    XCTAssertTrue(copiedScope.variables.count == scope.variables.count,
                  @"Copies Variables of Scopes not properly.");
    LynVariableBoolean *copiedBoolean = copiedScope.variables[0];
    LynVariableInteger *copiedInteger = copiedScope.variables[1];
    XCTAssertEqualObjects(boolean.name, copiedBoolean.name,
                          @"Copies Variable Names in Scopes not properly.");
    XCTAssertEqualObjects(integer.value, copiedInteger.value,
                          @"Copies Variable Values in Scopes not properly.");
    XCTAssertEqualObjects(copiedBoolean, [copiedScope variableNamed:@"t" inSuperScopes:NO],
                          @"After copying querrying for variables doesn't work anymore in Scopes.");
}

- (void)testSuperScopes{
    LynScope *superScope = [[LynScope alloc] init];
    LynScope *hyperScope = [[LynScope alloc] init];
    boolean.name = @"a";
    integer.name = @"b";
    string.name = @"c";
    [scope.variables removeObject:integer];
    [superScope.variables addObject:integer];
    [scope.variables removeObject:string];
    [hyperScope.variables addObject:string];
    XCTAssertNil([scope variableNamed:@"b"],
                 @"Variables arn't removed from Scopes properly.");
    superScope.scopeOwner = (id<LynScopeOwner>) self;
    scope.superScope = superScope;
    XCTAssertEqual(scope.superScope, superScope, @"Scopes don't add superscopes properly.");
    XCTAssertEqual(scope.superScope.scopeOwner, self, @"Scopes don't set owners properly");
    XCTAssertEqual(integer, [scope variableNamed:@"b" inSuperScopes:YES],
                   @"Scopes don't find variables in superscopes.");
    XCTAssertNil([scope variableNamed:@"b" inSuperScopes:NO],
                 @"Scopes querry superscopes whitout permission.");
    superScope.superScope = hyperScope;
    XCTAssertEqualObjects(string, [scope variableNamed:@"c" inSuperScopes:YES],
                          @"Scopes don't find variables in higher superscopes.");
    scope.superScope = nil;
    XCTAssertNil([scope variableNamed:@"c" inSuperScopes:YES],
                 @"Superscopes don't get removed properly.");
    XCTAssertNil([scope variableNamed:@"b" inSuperScopes:YES],
                 @"Superscopes don't get removed properly.");
}

- (void)testVariablesArray{
    XCTAssertThrows([scope.variables addObject:[NSNull null]],
                    @"The Scope's Variable Array accepts non Variable objects.");
}

@end
