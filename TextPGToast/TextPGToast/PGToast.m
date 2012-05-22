//
//  PGToast.m
//  iToastDemo
//
//  Created by gong Pill on 12-5-21.
//  Copyright (c) 2012年 ceo softcenters. All rights reserved.
//

#import "PGToast.h"
#import <QuartzCore/QuartzCore.h>

#define bottomPadding 50
#define startDisappearSecond 3
#define disappeartDurationSecond 1.5

const CGFloat pgToastTextPadding     = 5;
const CGFloat pgToastLabelWidth      = 180;
const CGFloat pgToastLabelHeight     = 60;

@interface PGToast()

@property (nonatomic, copy) NSString *pgLabelText;
@property (nonatomic, retain) UILabel *pgLabel;

- (id)initWithText:(NSString *)text;    
- (void)deviceOrientationChange;

@end

@implementation PGToast

static UIInterfaceOrientation lastOrientation; 

@synthesize pgLabel;
@synthesize pgLabelText;

- (id)initWithText:(NSString *)text {

    if (self = [super init]) {
        self.pgLabelText = text;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
         
    }    
    return self;
}

- (void)dealloc {

    [pgLabel release];
    [pgLabelText release];
    [super dealloc];
}

+ (PGToast *)makeToast:(NSString *)text {
    PGToast *pgToast = [[PGToast alloc] initWithText:text];
    return [pgToast autorelease];
}


- (void)show {
    
    UIFont *font = [UIFont systemFontOfSize:16];
    CGSize textSize = [pgLabelText sizeWithFont:font constrainedToSize:CGSizeMake(pgToastLabelWidth, pgToastLabelHeight)];
    
    self.pgLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, textSize.width + 2 * pgToastTextPadding, textSize.height + 2 * pgToastTextPadding)];
    
    pgLabel.backgroundColor = [UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:0.9];
    pgLabel.textColor = [UIColor whiteColor];
    pgLabel.layer.cornerRadius = 10;
    pgLabel.layer.borderWidth = 2;
    pgLabel.numberOfLines = 2;
    pgLabel.font = font;
    pgLabel.textAlignment = UITextAlignmentCenter;
    pgLabel.text = self.pgLabelText;
    
    [NSTimer scheduledTimerWithTimeInterval:startDisappearSecond target:self selector:@selector(toastDisappear:) userInfo:nil repeats:NO];
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];

    [window addSubview:self.pgLabel];
    [self deviceOrientationChange];
}

- (void)deviceOrientationChange {
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    CGPoint point = window.center;    
    NSLog(@"point %f, %f", point.x, point.y);
    CGFloat centerX, centerY;
    CGFloat windowCenterX = window.center.x;
    CGFloat windowCenterY = window.center.y;
    CGFloat windowWidth = window.frame.size.width;
    CGFloat windowHeight = window.frame.size.height;
    
    
    UIInterfaceOrientation currentOrient= [UIApplication
                                           sharedApplication].statusBarOrientation;
    
    if (currentOrient == UIInterfaceOrientationLandscapeRight)
    {
        NSLog(@"right ...");
        CGAffineTransform rotateTransform   = CGAffineTransformMakeRotation(M_PI/2);
        pgLabel.transform = CGAffineTransformConcat(window.transform, rotateTransform);
        centerX = bottomPadding;
        centerY = windowCenterY;
    }
    else if(currentOrient == UIInterfaceOrientationLandscapeLeft)
    {
        NSLog(@"left ...");
        CGAffineTransform rotateTransform;
        if (lastOrientation == UIInterfaceOrientationPortrait) {
            rotateTransform   = CGAffineTransformMakeRotation(-M_PI/2);
        } else {
            rotateTransform   = CGAffineTransformMakeRotation(M_PI/2);
        }
        
        pgLabel.transform = CGAffineTransformConcat(pgLabel.transform, rotateTransform);
        centerX = windowWidth - bottomPadding;
        centerY = windowCenterY;
        
    }
    else if(currentOrient == UIInterfaceOrientationPortraitUpsideDown)
    {
        NSLog(@"down ...");
        lastOrientation = currentOrient;
        pgLabel.transform = CGAffineTransformRotate(window.transform, -M_PI);
        
        centerX = windowCenterX;
        centerY = bottomPadding;
        
    }
    else if(currentOrient == UIInterfaceOrientationPortrait)
    {
        NSLog(@"up ...");
        lastOrientation = currentOrient;
        pgLabel.transform = window.transform;
        centerX = windowCenterX;
        centerY = windowHeight - bottomPadding;
        
    }

    self.pgLabel.center = CGPointMake(centerX, centerY);
}

- (void)toastDisappear:(NSTimer *)timer {
    [timer invalidate];
    [NSTimer scheduledTimerWithTimeInterval:1/60.0 target:self selector:@selector(startDisappear:) userInfo:nil repeats:YES];
}

- (void)startDisappear:(NSTimer *)timer {
    static int timeCount = 60 * disappeartDurationSecond;
    if (timeCount >= 0) {
        [self.pgLabel setAlpha:timeCount/60.0];
        if (timeCount == 0) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
        timeCount--;
    } else {
        [timer invalidate];
        timeCount = 60 * disappeartDurationSecond;
    }
}

@end
