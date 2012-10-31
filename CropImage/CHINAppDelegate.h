//
//  CHINAppDelegate.h
//  CropImage
//
//  Created by Chinthaka Kumarasiri on 31/10/2012.
//  Copyright (c) 2012 Chinthaka Kumarasiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHINViewController;

@interface CHINAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) CHINViewController *viewController;

@end
