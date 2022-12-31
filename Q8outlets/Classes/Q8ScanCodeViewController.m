//
//  Q8ScanCodeViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8ScanCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Q8ResultViewController.h"

@interface Q8ScanCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>
@end

@implementation Q8ScanCodeViewController {
    AVCaptureDevice *device;
    AVCaptureDeviceInput *input;
    AVCaptureSession *session;
    AVCaptureMetadataOutput *output;
    
    AVCaptureVideoPreviewLayer *preview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup session
    [self setupScanner];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startScanning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    for(AVMetadataObject *current in metadataObjects) {
        if([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            
            NSString *scannedValue = [((AVMetadataMachineReadableCodeObject *) current) stringValue];
            WLDebLog(@"%@",scannedValue);
            [self moveToRedeemCode:scannedValue];
            [self stopScanning];
        }
    }
}

#pragma mark - Scanner logic

- (void) setupScanner {
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    session = [[AVCaptureSession alloc] init];
    
    output = [[AVCaptureMetadataOutput alloc] init];
    [session addOutput:output];
    [session addInput:input];
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    AVCaptureConnection *con = preview.connection;
    
    con.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [self.previewView.layer addSublayer:preview];
}

- (void)startScanning; {
    [session startRunning];
}

- (void) stopScanning; {
    [session stopRunning];
}

#pragma mark - Button actions

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

- (void)moveToRedeemCode:(NSString *)code {
    Q8ResultViewController *scanResultController = (Q8ResultViewController *)[WLUtilityHelper viewControllerFromStoryboard:@"Business" controllerIdentifier:Q8ResultControllerIdentifier];
    scanResultController.couponQrToken = code;
    
    NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
    [viewControllers removeObject:self];
    [viewControllers addObject:scanResultController];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController setViewControllers:viewControllers animated:YES];
}
@end
