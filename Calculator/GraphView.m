//
//  GraphView.m
//  Calculator
//
//  Created by Max on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize dataSource = _dataSource;
@synthesize origin = _origin;
@synthesize scale = _scale;
@synthesize drawMode = _drawMode;

- (void)awakeFromNib {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.origin = CGPointMake([[defaults objectForKey:@"origin.x"] floatValue], [[defaults objectForKey:@"origin.y"] floatValue]);
    self.scale = [[defaults objectForKey:@"scale"] floatValue];
    self.drawMode = [defaults integerForKey:@"drawMode"];
    
    [super awakeFromNib];
}

- (void)setDrawMode:(int)drawMode {
    if (drawMode != _drawMode) {
        _drawMode = drawMode;
        
        [self setNeedsDisplay];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:drawMode forKey:@"drawMode"];
        [defaults synchronize];
    }
}

- (void)setScale:(CGFloat)scale {
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithFloat:scale] forKey:@"scale"];
        [defaults synchronize];
    }
}

#define DEFAULT_SCALE 1
- (CGFloat)scale {
    if (!_scale) {
        return DEFAULT_SCALE;
    } else {
        return _scale;
    }
}

- (void)setOrigin:(CGPoint)origin {
    if (origin.x != _origin.x || origin.y != _origin.y) {
        _origin = origin;
        [self setNeedsDisplay];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithFloat:origin.x] forKey:@"origin.x"];
        [defaults setObject:[NSNumber numberWithFloat:origin.y] forKey:@"origin.y"];
        [defaults synchronize];
    }
}

- (CGPoint)origin {
    if (!_origin.x && !_origin.y) {
        CGPoint origin;
        origin.x = self.bounds.origin.x + self.bounds.size.width / 2;
        origin.y = self.bounds.origin.y + self.bounds.size.height / 2;
        return origin;
    } else {
        return _origin;
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded) {
        self.scale *= gesture.scale;
        gesture.scale = 1;
    }
}

#define PAN_DAMPING 0.1
- (void)pan:(UIPanGestureRecognizer *)gesture {
    self.origin = CGPointMake(self.origin.x + [gesture translationInView:self].x * PAN_DAMPING, self.origin.y + [gesture translationInView:self].y * PAN_DAMPING);
}
#define TAP_ZOOM_IN 1.50
#define TAP_ZOOM_OUT 0.50
- (void)tap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if ([gesture numberOfTouchesRequired] == 2) {
            self.scale *= TAP_ZOOM_OUT;
        } else {
            if ([gesture numberOfTapsRequired] == 2) {
                self.scale *= TAP_ZOOM_IN;
            } else {
                self.origin = [gesture locationInView:[gesture view]];
            }
        }
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (float)untranslateX:(float)x {
    float transformX = x - self.origin.x;
    float scaleX = transformX / self.scale;
    return scaleX;
}

- (float)translateY:(float)y {
    float scaleY = y * self.scale;
    float transformY = self.origin.y - scaleY;
    return transformY;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    [[UIColor blackColor] setStroke];
    
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
    
    
    if (self.drawMode) {
        // lines
        [[UIColor blueColor] setStroke];
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, [self translateY:[self.dataSource fOfX:[self untranslateX:0] forGraphView:self]]);
        for (int i = 0; i < self.bounds.size.width * [self contentScaleFactor]; i++) {
            CGContextAddLineToPoint(context, i, [self translateY:[self.dataSource fOfX:[self untranslateX:i] forGraphView:self]]);
        }
    } else {
        // points
        [[UIColor blueColor] setFill];
        CGContextBeginPath(context);
        for (int i = 0; i < self.bounds.size.width * [self contentScaleFactor]; i++) {
            CGRect r = CGRectMake(i, [self translateY:[self.dataSource fOfX:[self untranslateX:i] forGraphView:self]], 1, 1);
            CGContextAddRect(context, r);
            CGContextFillRect(context, r);
        }
    }
    CGContextStrokePath(context);
}

@end
