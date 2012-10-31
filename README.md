ImageCrop for iPhone
=============
Chinthaka Kumarasiri

This simple iOS custom view controller allows user to crop an image



Overview
--
This is a simple library for crop an image by selecting the area using your finger. ImageCrop is a Apache Licensed iOS library support deployment to iOS 5.0, and has a simpler interface.

**Objective-C ARC enabled**

Quick Start

1. Copy the `CropImage` folder into your project
2. Add iOS `CoreGraphics framework` from Xcode > Targets > Build Phases > Link Binary With Library 
3. Import headers
Include the following line to make the library available to your code

        #import "CropingImageViewControl.h"

4. Create `CropingImageViewControl` object on your header file

        @property (nonatomic, strong) CropingImageViewControl *cropingImageViewCon;

5. Add `CropingImageViewControllerDelegate` to your header file

6. Add following code in to the implementation file 

    The following will initiate `CropingImageViewControl` object, assign the delegate to the .m file and pass the image you want to crop.

        _cropingImageViewCon = [[CropingImageViewControl alloc]initWithNibName:@"CropingImageView" bundle:nil];
        _cropingImageViewCon.delegate = self;
        _cropingImageViewCon.originalImg = [UIImage imageNamed:@"Apple"];
        [self.navigationController presentModalViewController:_cropingImageViewCon animated:YES];

7. Delegate method

    By calling following delegate you will be able to get the cropped image.

        - (void)resultingImage:(UIImage *)image

LICENSE

Except as otherwise noted, this library for iOS is licensed under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.html).