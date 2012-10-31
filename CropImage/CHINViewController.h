//
//  CHINViewController.h
//  CropImage
//
//  Created by Chinthaka Kumarasiri on 31/10/2012.
//  Copyright (c) 2012 Chinthaka Kumarasiri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CropingImageViewControl.h"

@interface CHINViewController : UIViewController <CropingImageViewControllerDelegate>

@property (nonatomic, strong) CropingImageViewControl *cropingImageViewCon;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;


-(IBAction)startToCrop:(id)sender;

@end
