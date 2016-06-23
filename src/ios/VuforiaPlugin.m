#import "VuforiaPlugin.h"
#import "ViewController.h"

@interface VuforiaPlugin()

@property CDVInvokedUrlCommand *command;
@property ViewController *imageRecViewController;
@property BOOL startedVuforia;

@end

@implementation VuforiaPlugin

- (void) cordovaStartVuforia:(CDVInvokedUrlCommand *)command {

    NSLog(@"Vuforia Plugin :: Start plugin");

    NSLog(@"Arguments: %@", command.arguments);
    NSLog(@"KEY: %@", [command.arguments objectAtIndex:3]);

    NSDictionary *overlayOptions =  [[NSDictionary alloc] initWithObjectsAndKeys: [command.arguments objectAtIndex:2], @"overlayText", [NSNumber numberWithBool:[[command.arguments objectAtIndex:5] integerValue]], @"showDevicesIcon", nil];


    [self startVuforiaWithImageTargetFile:[command.arguments objectAtIndex:0] imageTargetNames: [command.arguments objectAtIndex:1] overlayOptions: overlayOptions vuforiaLicenseKey: [command.arguments objectAtIndex:3]];
    self.command = command;

    self.startedVuforia = true;
}

#pragma mark - Util_Methods
- (void) startVuforiaWithImageTargetFile:(NSString *)imageTargetfile imageTargetNames:(NSArray *)imageTargetNames overlayOptions:(NSDictionary *)overlayOptions vuforiaLicenseKey:(NSString *)vuforiaLicenseKey {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ImageMatched" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageMatched:) name:@"ImageMatched" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CloseRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeRequest:) name:@"CloseRequest" object:nil];

    UINavigationController *nc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    self.imageRecViewController = [[ViewController alloc] initWithFileName:imageTargetfile targetNames:imageTargetNames overlayOptions:overlayOptions vuforiaLicenseKey:vuforiaLicenseKey];

    [nc pushViewController:self.imageRecViewController animated:YES];
}


- (void)imageMatched:(NSNotification *)notification {

    NSDictionary* userInfo = notification.userInfo;

    NSLog(@"Vuforia Plugin :: image matched");
    NSDictionary* jsonObj = @{@"status": @{@"imageFound": @true, @"message": @"Image Found."}, @"result": @{@"imageName": userInfo[@"result"][@"imageName"]}};

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: jsonObj];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
    [self VP_closeView];
}

- (void)closeRequest:(NSNotification *)notification {

    NSDictionary* jsonObj = @{@"status": @{@"manuallyClosed": @true, @"message": @"User manually closed the plugin."}};

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: jsonObj];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
    [self VP_closeView];
}

- (void) cordovaStopVuforia:(CDVInvokedUrlCommand *)command {
    self.command = command;

    NSDictionary *jsonObj = [NSDictionary alloc];

    if(self.startedVuforia == true){
        NSLog(@"Vuforia Plugin :: Stopping plugin");

        jsonObj = [ [NSDictionary alloc] initWithObjectsAndKeys :
                     @"true", @"success",
                     nil
                   ];
    }else{
        NSLog(@"Vuforia Plugin :: Cannot stop the plugin because it wasn't started");

        jsonObj = [ [NSDictionary alloc] initWithObjectsAndKeys :
                     @"false", @"success",
                     @"No Vuforia session running", @"message",
                     nil
                   ];
    }

    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                    ];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];

    [self VP_closeView];
}


- (void) VP_closeView {
    if(self.startedVuforia == true){
        UINavigationController *nc = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [nc popToRootViewControllerAnimated:YES];

        self.startedVuforia = false;
    }
}

@end
