//
//  ViewController.h
//  ConnectionTest
//
//  Created by Jiten Agarwal on 03/06/16.
//  Copyright © 2016 Jiten Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<NSURLSessionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableData *_responseData;
}

@property (weak, nonatomic) IBOutlet UILabel *responseLabel;


@end

