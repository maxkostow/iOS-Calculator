//
//  CaculatorViewController.m
//  Calculator
//
//  Created by Max on 11/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CaculatorViewController.h"
#import "CaclculatorBrain.h"
#import "GraphViewController.h"

@interface CaculatorViewController()

@property (nonatomic) BOOL userIsActive;
@property (nonatomic) BOOL periodUsed;
@property (nonatomic, strong) CaclculatorBrain *brain;

- (void)updateLabels;
- (NSString *)getVariableString;

@end

@implementation CaculatorViewController

@synthesize display = _display;
@synthesize history = _history;
@synthesize userIsActive = _userIsActive;
@synthesize periodUsed = _periodUsed;
@synthesize brain = _brain;

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter {
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = self.title;
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

- (CaclculatorBrain *)brain {
    if (!_brain) {
        _brain = [[CaclculatorBrain alloc] init];
    }
    return _brain;
}

- (void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewBarButtonItemPresenter] splitViewBarButtonItem];
    [[self splitViewBarButtonItemPresenter] setSplitViewBarButtonItem:nil];
    if (splitViewBarButtonItem) {
        [destinationViewController setSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

- (GraphViewController *)splitViewGraphViewController {
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[GraphViewController class]]) {
        gvc = nil;
    }
    return gvc;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([self splitViewController]) {
        return YES;
    }
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)updateLabels {
    self.display.text = [NSString stringWithFormat:@"%g", [CaclculatorBrain runProgram:self.brain.program usingVariableValues:self.brain.variableValues]];
    self.history.text = [CaclculatorBrain descriptionOfProgram:self.brain.program];
}
- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = sender.currentTitle;
    if (self.userIsActive) {
        self.display.text = [self.display.text stringByAppendingFormat:digit];
    } else {
        self.display.text = digit;
        self.userIsActive = YES;
    }
}
- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsActive = NO;
    self.periodUsed = NO;
    [self updateLabels];
}
- (IBAction)clearPressed:(id)sender {
    self.history.text = @"";
    self.display.text = @"0";
    self.userIsActive = NO;
    self.periodUsed = NO;
    [self.brain clearBrain];
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsActive) {
        [self enterPressed];
    }
    NSString *operation = sender.currentTitle;
    [self.brain performOperation:operation];
    [self updateLabels];
}
- (IBAction)periodPressed {
    if (!self.periodUsed) {
        self.periodUsed = YES;
        if (!self.userIsActive) {
            self.userIsActive = YES;
            self.display.text = @"0";
        }
        self.display.text = [self.display.text stringByAppendingFormat:@"."];
    }
}
- (IBAction)undoPressed {
    if (self.userIsActive) {
        if ([[self.display.text substringFromIndex:([self.display.text length] - 1)] isEqualToString:@"."]) {
            self.periodUsed = NO;
        }
        self.display.text = [self.display.text substringToIndex:([self.display.text length] - 1)];
        if (![self.display.text length]) {
            self.userIsActive = NO;
            [self undoPressed];
        }
    } else {
        [self.brain removeLastOp];
        [self updateLabels];
    }
}
- (NSString *)getVariableString {
    NSSet * variablesUsed = [CaclculatorBrain variablesUsedInProgram:self.brain.program];
    NSDictionary *variableValues = self.brain.variableValues;
    NSString *variables = @"";
    NSEnumerator * enumerator = [variablesUsed objectEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        if (![variables isEqualToString:@""]) {
            variables = [variables stringByAppendingFormat:@", "];
        }
        variables = [variables stringByAppendingFormat:@"%@ = %g",key, [[variableValues objectForKey:key] doubleValue]];
    }
    return variables;
}

- (IBAction)varPressed:(UIButton *)sender {
    if (self.userIsActive) {
        [self enterPressed];
    }
    NSString *var = sender.currentTitle;
    [self.brain performOperation:var];
    [self updateLabels];
}
- (IBAction)graphPressed {
    if ([self splitViewController]) {
        [self splitViewGraphViewController].program = self.brain.program;
    } else {
        [self performSegueWithIdentifier:@"Graph" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Graph"]) {
        [segue.destinationViewController setProgram:self.brain.program];
    }
}

@end
