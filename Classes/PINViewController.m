    //
//  PINViewController.m
//  CrimeStick
//
//  Created by Michael Zornek on 2/20/11.
//  Copyright 2011 Clickable Bliss. All rights reserved.
//

#import "PINViewController.h"

@implementation PINViewController

#pragma mark -
#pragma mark Initialization

- (id)init
{
	self = [super initWithNibName:@"PINView" bundle:nil];
    if (self) {
		
	}
	return self;
}

- (void)dealloc
{
	// ...
    [super dealloc];
}

@synthesize delegate;
@synthesize pinTextField;

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.pinTextField becomeFirstResponder];
}

#pragma mark -
#pragma mark Actions

- (IBAction)validatePIN:(id)sender
{
	if (![self isValidPIN:self.pinTextField.text]) {
		UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Incorrect PIN" message:@"Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[someError show];
		[someError release];
	} else {
		[self.delegate pinViewControllerDidEndWithValidCodeEntry:YES];
	}
}

- (BOOL)isValidPIN:(NSString *)someString
{
	if ([someString isEqualToString:@"1234"]) {
		return YES;
	} else {
		return NO;
	}
}

- (IBAction)doneButtonPressed:(id)sender
{
	[self.delegate pinViewControllerDidEndWithValidCodeEntry:[self isValidPIN:self.pinTextField.text]];
}

-(IBAction)hideKeyboard:(id)sender
{
	[self.pinTextField resignFirstResponder];
}

@end
