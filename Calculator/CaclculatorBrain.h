//
//  CaclculatorBrain.h
//  Calculator
//
//  Created by Max on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CaclculatorBrain : NSObject

- (void)pushOperand:(double)operand;

// "+"      -> plus
// "-"      -> minus
// "*"      -> multiply
// "/"      -> divide
// "sin"    -> sine
// "cos"    -> cosine
// "sqrt"   -> square root
// "π"      -> pi
// other    -> variable
- (double)performOperation:(NSString *)operation;
- (void)clearBrain;
- (void)removeLastOp;
- (void)addVariable:(NSString *)variable withValue:(double)value;
- (void)removeVariable:(NSString *)variable;
@property (readonly) id program;
@property (readonly) NSDictionary *variableValues;
+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSString *)descriptionOfProgram:(id)program;
+ (NSSet *)variablesUsedInProgram:(id)program;
@end
