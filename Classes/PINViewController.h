//
//  PINViewController.h
//  CrimeStick
//
//  Created by Michael Zornek on 2/20/11.
//  Copyright 2011 Clickable Bliss. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PINViewControllerDelegate;

@interface PINViewController : UIViewController
{
	UITextField *pinTextField;
}

@property (readwrite, assign) id <PINViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextField *pinTextField;

- (IBAction)validatePIN:(id)sender;
- (BOOL)isValidPIN:(NSString *)someString;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)hideKeyboard:(id)sender;

@end

@protocol PINViewControllerDelegate 
- (void)pinViewControllerDidEndWithValidCodeEntry:(BOOL)wasVaildPIN;
@end