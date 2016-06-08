//
//  TestViewController.h
//  ConnectionTest
//
//  Created by Jiten Agarwal on 07/06/16.
//  Copyright © 2016 Jiten Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController<NSURLSessionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *responseLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageVIew;
@property UIImage *imageToUse;
@end
