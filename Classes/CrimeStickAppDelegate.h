//
//  CrimeStickAppDelegate.h
//  CrimeStick
//
//  Created by Michael Zornek on 2/20/11.
//  Copyright 2011 Clickable Bliss. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CrimeStickViewController;

@interface CrimeStickAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CrimeStickViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CrimeStickViewController *viewController;

@end

