//
//  CrimeStickViewController.h
//  CrimeStick
//
//  Created by Michael Zornek on 2/20/11.
//  Copyright 2011 Clickable Bliss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "PINViewController.h"

@interface CrimeStickViewController : UIViewController <PINViewControllerDelegate, CLLocationManagerDelegate>
{
    UIButton *mainButton;
	NSTimer *timer;
	
	float secondsSinceButtonReleased;
	BOOL inDistress;
	
	NSMutableArray *pastLocations;
}
@property (nonatomic, retain) IBOutlet UIButton *mainButton;
@property (nonatomic, assign) float secondsSinceButtonReleased; 
@property (nonatomic, retain) CLLocationManager *locationManager;

- (void)setupDefaultButtonState;
- (IBAction)startTracking:(id)sender;
- (IBAction)buttonReleased:(id)sender;
- (void)distressCall;
- (void)publishLocationToServer:(CLLocation *)loc;
- (void)timerFireMethod:(NSTimer*)theTimer;
- (void)updateUI;

// private
- (void)themeButton:(UIButton *)button withColor:(UIColor *)color;


@end

