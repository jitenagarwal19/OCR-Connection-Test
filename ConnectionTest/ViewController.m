//
//  ViewController.m
//  ConnectionTest
//
//  Created by Jiten Agarwal on 03/06/16.
//  Copyright © 2016 Jiten Agarwal. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)urlButtonClicked:(id)sender {

    NSError *error;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSString* path= @"https://api.projectoxford.ai/vision/v1.0/ocr";
    NSArray* array = @[
                       @"entities=true",
                       @"language=unk",
                       @"detectOrientation=true",
                       ];
    NSString* string = [array componentsJoinedByString:@"&"];
    path = [path stringByAppendingFormat:@"?%@", string];
    
    NSLog(@"path %@", path);
    
    
    NSURL *url = [NSURL URLWithString:path];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request addValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"{53804030c003487b9b96259835a68748}" forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
    NSURLSessionTask *sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError * error) {
        NSLog(@"in the handler");
        NSHTTPURLResponse *httpurlResponse = (NSHTTPURLResponse*)response;
        NSLog(@"response code %ld", [httpurlResponse statusCode]);
        dispatch_async(dispatch_get_main_queue(), ^{
            _responseLabel.text = [NSString stringWithFormat:@"%ld response code received ",[httpurlResponse statusCode]];
        });
       
    }];
    [sessionTask resume];
    
    
    
    
}

-(BOOL) startMediaBrowserFromViewController: (UIViewController*) controller usingDelegate: (id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO ) || delegate == nil || controller == nil)
        return NO;
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
//    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeMovie, nil ]

    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = delegate;
    
    [controller presentModalViewController:mediaUI animated:YES];
    return YES;
}
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    //handling image here
    
    if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage = (UIImage*)[info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
    }
    
}
- (IBAction)showImagePickerUI:(UIButton *)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}


@end

