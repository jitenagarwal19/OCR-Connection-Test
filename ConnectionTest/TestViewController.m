//
//  TestViewController.m
//  ConnectionTest
//
//  Created by Jiten Agarwal on 07/06/16.
//  Copyright © 2016 Jiten Agarwal. All rights reserved.
//

#import "TestViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"launched the Test StoryBoard");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)testConnectionButtonPressed:(id)sender {
    NSLog(@"Hello Test Connection Button Pressed");
    _responseLabel.text = @"Good Morning Fellas";
}
- (IBAction)selectImageButtonPressed:(id)sender {
    NSLog(@"Hello ImagePressed Button Pressed");
    _responseLabel.text = @"Good Evening Fellas";
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

#pragma mark - ImagePicker Delegate Methods


-(BOOL) startMediaBrowserFromViewController: (UIViewController*) controller usingDelegate: (id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO ) || delegate == nil || controller == nil)
        return NO;
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    //    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeMovie, nil ]
    
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = delegate;
    
    [controller presentModalViewController:mediaUI animated:YES];
    return YES;
}
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage;
    
    //handling image here
    
    if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage = (UIImage*)[info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
        if (editedImage) {
            _imageToUse = editedImage;
        } else {
            _imageToUse = originalImage;
        }
    }
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:^{NSLog(@"Hey There");}];
    _selectedImageVIew.image = _imageToUse;
    
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"Image Picker Cancelled");
}
- (IBAction)uploadImageButtonPressed:(id)sender {
//    [self createAndStartUploadImageRequest];
    [self startOCRImageUpload];
    
}
-(void)startOCRImageUpload
{
    NSURL *url = [NSURL URLWithString:@"https://api.ocr.space/Parse/Image"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---qwesda314123";
    [request addValue:[NSString stringWithFormat:@"multipart/form-data: boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    NSURLSession *session = [NSURLSession sharedSession];
    
    if (_imageToUse) {
        NSData *imageData = UIImageJPEGRepresentation(_imageToUse, 1.0);
        NSDictionary *parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"c81ca5e9c688957", @"apikey",  @"True", @"isOverlayRequired",
                                              @"eng", @"language", nil];
        
        //create multipart form data
        
        NSData *body = [self createBodyWithBoundary:boundary
                                         parameters:parametersDictionary
                                          imageData:imageData
                                           fileName:@"hello.jpeg"];
        
        [request setHTTPBody:body];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSError *myError;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSHTTPURLResponse * httpUrlResponse = (NSHTTPURLResponse*)response;
            if (response) {
                NSLog(@"response received %ld", [httpUrlResponse statusCode]);
                dispatch_async(dispatch_get_main_queue(), ^{
                                _responseLabel.text = [NSString stringWithFormat:@"%ld response code received \n response message",[httpUrlResponse statusCode]];
                            });
            }
            if (result) {
                NSLog(@"response data %@", [result description]);
                
            }
            
            
        }];
        [task resume];
        
    } else {
        _responseLabel.text = @"please choose a image first";
    }
    
    
    
    
}

-(NSData *) createBodyWithBoundary:(NSString*)boundary parameters:(NSDictionary*)parameters imageData:(NSData*)imageData fileName:(NSString *)fileName
{
    
    NSString *doubleDash = @"--";
    NSString *RCNL = @"\r\n";
    
    
    NSMutableData *body = [NSMutableData data];
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"%@%@%@", doubleDash, boundary, RCNL] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"%@", @"file", fileName, RCNL] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg%@%@", RCNL, RCNL] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"%@", RCNL] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    for (id key in parameters.allKeys) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameters[key]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return body;
}


//-(void)createAndStartUploadImageRequest
//{
//    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
//    NSString *path = @"https://api.projectoxford.ai/vision/v1.0/ocr";
////    NSArray *array = @[   @"entities=true",
////                          @"language=unk",
////                          @"detectOrientation=true"];
////    NSString* string = [array componentsJoinedByString:@"&"];
////    path = [path stringByAppendingString:string];
//    NSURL *url = [NSURL URLWithString:path];
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//    
//    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPMethod:@"POST"];
//    [request addValue:@"{53804030c003487b9b96259835a68748}" forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
//    NSURLSessionTask *sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError * error) {
//        NSLog(@"in the handler");
//        if (data) {
//            NSLog(@"data is not null %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//        } else {
//            NSLog(@"data is null");
//        }
//        NSHTTPURLResponse *httpurlResponse = (NSHTTPURLResponse*)response;
//        NSDictionary *responseHeaders = [httpurlResponse allHeaderFields];
//        NSLog(@"response Headers %@", [responseHeaders description]);
//        NSLog(@"response code %ld", [httpurlResponse statusCode]);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _responseLabel.text = [NSString stringWithFormat:@"%ld response code received \n response message",[httpurlResponse statusCode]];
//        });
//        
//    }];
//    [sessionTask resume];
//
//    
//}


@end
