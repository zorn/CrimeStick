//
//  CrimeStickViewController.m
//  CrimeStick
//
//  Created by Michael Zornek on 2/20/11.
//  Copyright 2011 Clickable Bliss. All rights reserved.
//

#import "CrimeStickViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JSON.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define TimerRate 0.1
#define SecondsAllowedToReleaseYellow 5.0


@implementation CrimeStickViewController

#pragma mark -
#pragma mark Initialization

- (id)init
{
	NSLog(@"init");
	return [self initWithNibName:@"CrimeStickController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	NSLog(@"initWithNibName");
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		
	}
	return self;
}

- (void)loadView
{
	NSLog(@"loadView");
	[super loadView];
	
	pastLocations = [[NSMutableArray alloc] init];
	
	secondsSinceButtonReleased = 0.0;
	inDistress = NO;
	
	CLLocationManager *manager = nil;
	manager = [[CLLocationManager alloc] init];
	self.locationManager = manager;
	[manager release];
	
	self.locationManager.purpose = @"Track and publish your location to the server.";
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	self.locationManager.distanceFilter = 10.0; //Distance in meters
	self.locationManager.delegate = self;
	[self.locationManager startUpdatingLocation];
}

- (void)dealloc
{
	// ...
    [self setMainButton:nil];
    [super dealloc];
}

@synthesize mainButton;
@synthesize secondsSinceButtonReleased;
@synthesize locationManager;

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
	
	[self publishLocationToServer:[pastLocations lastObject]];
	
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

- (void)publishLocationToServer:(CLLocation *)loc
{
	SBJsonWriter *writer = [[SBJsonWriter alloc] init];
	
	NSString *status = nil;
	if (inDistress) {
		status = @"In distress";
	} else {
		status = @"Safe for now";
	}
	
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:@"lat", [NSString stringWithFormat:@"%f",loc.coordinate.latitude], @"lon", [NSString stringWithFormat:@"%f",loc.coordinate.longitude], @"status", status, nil];
	
	NSError *e = nil;
	NSString *result = [writer stringWithObject:d error:&e];
	NSLog(@"location as json: %@, %@", result, e);
	
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

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	
	//NSLog(@"newLocation %@", newLocation);
	// store it
	[pastLocations addObject:newLocation];
	[self publishLocationToServer:newLocation];
}

@end
