//
//  CropingImageViewControl.h
//  iCrop
//
//  Created by Chinthaka Kumarasiri on 25/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CropingArea.h"

@protocol CropingImageViewControllerDelegate <NSObject>

- (void)resultingImage:(UIImage *)image;

@end

@interface CropingImageViewControl : UIViewController

@property (nonatomic, strong) UIImage *cropedImg;
@property (nonatomic, strong) UIImage *originalImg;
@property (nonatomic, strong) NSString *uniquePath;
@property (nonatomic, strong) CropingArea *cropView;

@property (nonatomic, strong) id<CropingImageViewControllerDelegate> delegate;

- (IBAction)selectForCrop:(id) sender;

@end
