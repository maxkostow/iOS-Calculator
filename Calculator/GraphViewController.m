//
//  GraphViewController.m
//  Calculator
//
//  Created by Max on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CaclculatorBrain.h"

@interface GraphViewController() <GraphViewDataSource>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *programDescriptionBarButtonItem;
@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *programDescriptionLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *drawModeSelector;
@property (weak, nonatomic) NSDictionary *varX;
@end

@implementation GraphViewController

@synthesize toolbar = _toolbar;
@synthesize programDescriptionBarButtonItem = _programDescriptionBarButtonItem;
@synthesize graphView = _graphView;
@synthesize programDescriptionLabel = _programDescriptionLabel;
@synthesize drawModeSelector = _drawModeSelector;
@synthesize program = _program;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize varX = _varX;

- (void)setProgram:(id)program {
    _program = program;
    [self.graphView setNeedsDisplay];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.drawModeSelector.selectedSegmentIndex = self.graphView.drawMode;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self splitViewController]) {
        self.programDescriptionBarButtonItem.title = [NSString stringWithFormat:@"f(x) = %@", [CaclculatorBrain descriptionOfProgram:self.program]];
    } else {
        self.programDescriptionLabel.text = [NSString stringWithFormat:@"f(x) = %@", [CaclculatorBrain descriptionOfProgram:self.program]];
    }
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem {
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) {
            [toolbarItems removeObject:_splitViewBarButtonItem];
        }
        if (splitViewBarButtonItem) {
            [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        }
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (void)setGraphView:(GraphView *)graphView {
    
    _graphView = graphView;
    self.graphView.dataSource = self;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tap:)];
    [tapGestureRecognizer setNumberOfTapsRequired:3];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [self.graphView addGestureRecognizer:tapGestureRecognizer];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tap:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:2];
    [self.graphView addGestureRecognizer:tapGestureRecognizer];
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tap:)];
    [tapGestureRecognizer setNumberOfTapsRequired:2];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [self.graphView addGestureRecognizer:tapGestureRecognizer];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([self splitViewController]) {
        return YES;
    }
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (IBAction)resetGraph:(id)sender {
    self.graphView.scale = 0;
    self.graphView.origin = CGPointMake(0, 0);
    self.drawModeSelector.selectedSegmentIndex = 0;
    [self.graphView setNeedsDisplay];
}

- (float)fOfX:(float)x forGraphView:(GraphView *)sender {
    [self.varX setValue:[NSNumber numberWithFloat:x] forKey:@"x"];
    return [CaclculatorBrain runProgram:self.program usingVariableValues:self.varX];
}

- (IBAction)drawModeSelected {
    self.graphView.drawMode = self.drawModeSelector.selectedSegmentIndex;
}
@end
