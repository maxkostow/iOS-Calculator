//
//  CaclculatorBrain.m
//  Calculator
//
//  Created by Max on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CaclculatorBrain.h"

@interface CaclculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@property (nonatomic, strong) NSMutableDictionary *variables;
@end

@implementation CaclculatorBrain

@synthesize programStack = _programStack;
@synthesize variables = _variables;

- (NSMutableArray *) programStack {
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}
- (NSMutableDictionary *) variables {
    if (!_variables) {
        _variables = [[NSMutableDictionary alloc] init];
    }
    return _variables;
}
- (void)pushOperand:(double)operand {
    NSNumber * operandNSN = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandNSN];
    
}

- (double)performOperation:(NSString *)operation {
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

- (void)clearBrain {
    self.programStack = nil;
    self.variables = nil;
}

- (void)removeLastOp {
    id lastObject = [self.programStack lastObject];
    if (lastObject) {
        [self.programStack removeLastObject];
    }
}

- (void)addVariable:(NSString *)variable withValue:(double)value {
    [self.variables setObject:[NSNumber numberWithDouble:value] forKey:variable];
}

- (void)removeVariable:(NSString *)variable {
    [self.variables removeObjectForKey:variable];
}

- (id)program {
    return [self.programStack copy];
}

- (NSDictionary *)variableValues {
    return [self.variables copy];
}

+ (double)popOffProgramStack:(NSMutableArray *)stack usingVariableValues:(NSDictionary *)variableValues {
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) {
        [stack removeLastObject];
    }
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        NSNumber *operand = topOfStack;
        result = [operand doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString * operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOffProgramStack:stack usingVariableValues:variableValues] + [self popOffProgramStack:stack usingVariableValues:variableValues];
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOffProgramStack:stack usingVariableValues:variableValues] * [self popOffProgramStack:stack usingVariableValues:variableValues];
        } else if ([operation isEqualToString:@"/"]) {
            double div = [self popOffProgramStack:stack usingVariableValues:variableValues];
            if (div) {
                result = [self popOffProgramStack:stack usingVariableValues:variableValues] / div; 
            }
        } else if ([operation isEqualToString:@"-"]) {
            double sub = [self popOffProgramStack:stack usingVariableValues:variableValues];
            result = [self popOffProgramStack:stack usingVariableValues:variableValues] - sub;
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOffProgramStack:stack usingVariableValues:variableValues]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOffProgramStack:stack usingVariableValues:variableValues]);
        } else if ([operation isEqualToString:@"sqrt"]) {
            result = sqrt([self popOffProgramStack:stack usingVariableValues:variableValues]);
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        } else {
            //dictionary lookup
            id variable = [variableValues objectForKey:operation];
            if ([variable isKindOfClass:[NSNumber class]]) {
                result = [variable doubleValue];
            }
        }
    }
    
    return result;
}

+ (double)runProgram:(id)program {
    return [self runProgram:program usingVariableValues:nil];
}
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOffProgramStack:stack usingVariableValues:variableValues];
}
+(NSString *)describeProgramStack:(NSMutableArray *)stack withPreviousOp:(id)previousOp {
    NSString *result = @"0";
    id topOfStack = [stack lastObject];
    if (topOfStack) {
        [stack removeLastObject];
    }
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        NSNumber *operand = topOfStack;
        result = [NSString stringWithFormat:@"%@", operand];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString * operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            NSString *add = [self describeProgramStack:stack withPreviousOp:operation];
            result = [NSString stringWithFormat:@"%@ + %@", [self describeProgramStack:stack withPreviousOp:operation], add];
            if ([previousOp isEqualToString:@"*"] || [previousOp isEqualToString:@"/"]) {
                result = [NSString stringWithFormat:@"(%@)", result];
            }
        } else if ([operation isEqualToString:@"*"]) {
            NSString *mul = [self describeProgramStack:stack withPreviousOp:operation];
            result = [NSString stringWithFormat:@"%@ * %@", [self describeProgramStack:stack withPreviousOp:operation], mul];
        } else if ([operation isEqualToString:@"/"]) {
            NSString *div = [self describeProgramStack:stack withPreviousOp:operation];
            result = [NSString stringWithFormat:@"%@ / %@", [self describeProgramStack:stack withPreviousOp:operation], div];
        } else if ([operation isEqualToString:@"-"]) {
            NSString *sub = [self describeProgramStack:stack withPreviousOp:operation];
            result = [NSString stringWithFormat:@"%@ - %@", [self describeProgramStack:stack withPreviousOp:operation], sub];
            if ([previousOp isEqualToString:@"*"] || [previousOp isEqualToString:@"/"]) {
                result = [NSString stringWithFormat:@"(%@)", result];
            }
        } else if ([operation isEqualToString:@"sin"] || [operation isEqualToString:@"cos"] || [operation isEqualToString:@"sqrt"]) {
            result = [NSString stringWithFormat:@"%@(%@)", operation, [self describeProgramStack:stack withPreviousOp:operation]];
        } else {
            result = [NSString stringWithFormat:@"%@", operation];
        }
    }
    if ([stack count] && previousOp == nil) {
        result = [NSString stringWithFormat:@"%@, %@", [self describeProgramStack:stack withPreviousOp:nil], result];
    }
    return result;
}

+(NSString *)descriptionOfProgram:(id)program {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self describeProgramStack:stack withPreviousOp:nil];
}
+ (BOOL)isOperator:(NSString *)op {
    NSSet *operators = [NSSet setWithObjects:@"+", @"-", @"*", @"/", @"cos", @"sin", @"sqrt", @"π", nil];
    NSEnumerator * enumerator = [operators objectEnumerator];
    id object;
    while ((object = [enumerator nextObject])) {
        if ([op isEqualToString:object]) {
            return YES;
        }
    }
    return NO;
}
+ (NSSet *)variablesUsedInProgram:(id)program {
    NSMutableSet *vars = [[NSMutableSet alloc] init];
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program copy];
    }
    
    for (id op in stack) {
        if ([op isKindOfClass:[NSString class]]) {
            if (![self isOperator:op]) {
                [vars addObject:op];
            }
        }
    }
    
    if ([vars count]) {
        return [vars copy];
    } else {
        return nil;
    }
}
@end
