//
//  CrimeStickViewController.m
//  CrimeStick
//
//  Created by Michael Zornek on 2/20/11.
//  Copyright 2011 Clickable Bliss. All rights reserved.
//

#import "CrimeStickViewController.h"

#import <QuartzCore/QuartzCore.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define TimerRate 0.1
#define SecondsAllowedToReleaseYellow 5.0


@implementation CrimeStickViewController

#pragma mark -
#pragma mark Initialization

- (id)init
{
	self = [super initWithNibName:@"CrimeStickController" bundle:nil];
    if (self) {
		secondsSinceButtonReleased = 0.0;
		inDistress = NO;
	}
	return self;
}

- (void)dealloc
{
	// ...
    [self setMainButton:nil];
    [super dealloc];
}

@synthesize mainButton;
@synthesize secondsSinceButtonReleased;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self setupDefaultButtonState];
}

- (void)viewDidUnload 
{
    [self setMainButton:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark View actions

- (void)setupDefaultButtonState
{
	[self themeButton:self.mainButton withColor:UIColorFromRGB(0xB1FBC3)];
	[self.mainButton setTitle:@"Press and Hold" forState:UIControlStateNormal];
}
 
- (IBAction)startTracking:(id)sender 
{
    if (inDistress == YES) {
		
		// show them pin view to edit distress
		PINViewController *pinVC = [[PINViewController alloc] init];
		[pinVC setDelegate:self];
		[self presentModalViewController:pinVC animated:YES];
		[pinVC release];
		
	} else {
		NSLog(@"startTracking");
		// if they were in "yellow" state remove the timer
		if (timer) {
			[timer invalidate]; [timer release]; timer = nil;
		}
		[self themeButton:self.mainButton withColor:UIColorFromRGB(0x00ff00)];
		[self.mainButton setTitle:@"Don't Let Go" forState:UIControlStateNormal];
		secondsSinceButtonReleased = 0;
	}
	
	
	
	
}

- (IBAction)buttonReleased:(id)sender 
{
    NSLog(@"buttonReleased");
	[self themeButton:self.mainButton withColor:UIColorFromRGB(0xFFF82D)];
	if (!timer) {
		timer = [[NSTimer scheduledTimerWithTimeInterval:TimerRate target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES] retain];
	}
}

- (void)distressCall
{
    NSLog(@"distressCall");
	// cancel the timer
	if (timer) {
		[timer invalidate]; [timer release]; timer = nil;
	}
	
	inDistress = YES;
	
	[self.mainButton setTitle:@"Distress Mode. Press to Cancel." forState:UIControlStateNormal];
	
	// start playing noise
	// start modifiying loc notification with distress call
	// turn on lock so that only way to exit distress is to use PIN
	[self themeButton:self.mainButton withColor:UIColorFromRGB(0xFF0000)];
}

- (void)timerFireMethod:(NSTimer*)theTimer
{
	secondsSinceButtonReleased = secondsSinceButtonReleased + TimerRate;
	if (secondsSinceButtonReleased > 5.0) {
		[self distressCall];
	}
	
	[self updateUI];
}

- (void)updateUI
{
	if (timer) {
		NSInteger secondsLeft = lroundl(SecondsAllowedToReleaseYellow - secondsSinceButtonReleased);
		[self.mainButton setTitle:[NSString stringWithFormat:@"Resume Holding! Distress in %i.", secondsLeft] forState:UIControlStateNormal];
	}
}

- (void)themeButton:(UIButton *)button withColor:(UIColor *)color
{
    
    [[button layer] setCornerRadius:8.0f];
	[[button layer] setMasksToBounds:YES];
	[[button layer] setBorderWidth:1.0f];
	[[button layer] setBackgroundColor:[color CGColor]];
	[[button layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark PINViewController delegate methods

- (void)pinViewControllerDidEndWithValidCodeEntry:(BOOL)wasVaildPIN;
{
	if (wasVaildPIN == YES) {
		inDistress = NO;
		[self setupDefaultButtonState];
	}
	[self dismissModalViewControllerAnimated:YES];
}

@end
