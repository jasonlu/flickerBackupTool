//
//  FlickerController.m
//  flickerBackupTool
//
//  Created by Jason Lu on 11/3/13.
//  Copyright (c) 2013 Lu Jason. All rights reserved.
//

#import "FlickerController.h"

static NSString *kCallbackURLBaseString = OBJECTIVE_FLICKR_CALLBACK_BASE;
static NSString *kOAuthAuth = OBJECTIVE_FLICKR_AUTH_TYPE;
static NSString *kFrobRequest = @"Frob";
static NSString *kTryObtainAuthToken = @"TryAuth";
static NSString *kTestLogin = @"TestLogin";
static NSString *kUpgradeToken = @"UpgradeToken";

const NSTimeInterval kTryObtainAuthTokenInterval = 3.0;

@implementation FlickerController

@synthesize flickrContext = _flickrContext;
@synthesize flickrRequest = _flickrRequest;


- (void)handleIncomingURL:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSLog(@"callback reached");
    NSURL *callbackURL = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    NSLog(@"Callback URL: %@", [callbackURL absoluteString]);
    
    NSString *requestToken= nil;
    NSString *verifier = nil;
    
    BOOL result = OFExtractOAuthCallback(callbackURL, [NSURL URLWithString:OBJECTIVE_FLICKR_CALLBACK_BASE], &requestToken, &verifier);
    if (!result) {
        NSLog(@"Invalid callback URL");
    }
    [_flickrRequest fetchOAuthAccessTokenWithRequestToken:requestToken verifier:verifier];
}


- (id)init
{
    self = [super init];
    NSLog(@"FlickerCOntroller initialized");
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleIncomingURL:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    NSLog(@"url protocal registered...");
    _flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_SAMPLE_API_KEY sharedSecret:OBJECTIVE_FLICKR_SAMPLE_API_SHARED_SECRET];
    _flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
    [_flickrRequest setDelegate:self];

    return self;
}

- (void)awakeFromNib
{
    //[self performSelector:@selector(checkAuth:) withObject:self afterDelay:0.1];
}

- (IBAction)startAuth:(id)sender
{
    [_authProgress startAnimation:sender];
     NSLog(@"startAuth...");
    [self auth];
}

- (IBAction)checkAuth:(id)sender;
{
    if(true)
    {
        NSLog(@"Checkauth...");
        NSLog(@"%@",_window);
        [NSApp beginSheet:authPromtSheet
           modalForWindow:(NSWindow *)_window
            modalDelegate:self
           didEndSelector:nil
              contextInfo:nil];
    }
    else
    {
        // Do nothing.
    }
}
- (BOOL)auth
{
    _flickrRequest.sessionInfo = @"OAuth";
    NSURL *callBackUrl = [NSURL URLWithString:kCallbackURLBaseString];
    // Post something to Flickr.
    // Then wait for the callback to flickrAPIRequest:didObtainOAuthRequestToken:secret:
    [_flickrRequest fetchOAuthRequestTokenWithCallbackURL:callBackUrl];
    
    
    NSLog(@"Start auth, CALLBACK: %@", callBackUrl);

    return true;
}

- (void)tryObtainAuthToken
{
    _flickrRequest.sessionInfo = kTryObtainAuthToken;
    [_flickrRequest callAPIMethodWithGET:@"flickr.auth.getToken" arguments:[NSDictionary dictionaryWithObjectsAndKeys:_frob, @"frob", nil]];
}


- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret;
{
    _flickrContext.OAuthToken = inRequestToken;
    _flickrContext.OAuthTokenSecret = inSecret;
    // With receieved request toke, open brower to get access token.
    NSURL *authURL = [_flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    NSLog(@"Auth URL: %@", [authURL absoluteString]);
    [[NSWorkspace sharedWorkspace] openURL:authURL];
    NSLog(@"Browser window opened");
    
    // Wait for the callback from browser.

}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID
{
    _flickrContext.OAuthToken = inAccessToken;
    _flickrContext.OAuthTokenSecret = inSecret;
    
    NSLog(@"Token: %@, secret: %@", inAccessToken, inSecret);
    
    NSRunAlertPanel(@"Authenticated", [NSString stringWithFormat:@"OAuth access token: %@, secret: %@", inAccessToken, inSecret], @"Dismiss", nil, nil);
    [_authProgress stopAnimation:nil];
    [authPromtSheet close];
}



- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Hi there."];
    [alert runModal];

    NSLog(@"%s, return: %@", __PRETTY_FUNCTION__, inResponseDictionary);
    
    
    if (inRequest.sessionInfo == kFrobRequest) {
        _frob = [[inResponseDictionary valueForKeyPath:@"frob._text"] copy];
        NSLog(@"%@: %@", kFrobRequest, _frob);
        
        NSURL *authURL = [_flickrContext loginURLFromFrobDictionary:inResponseDictionary requestedPermission:OFFlickrWritePermission];
        [[NSWorkspace sharedWorkspace] openURL:authURL];
        
        [self performSelector:@selector(tryObtainAuthToken) withObject:nil afterDelay:kTryObtainAuthTokenInterval];
        
    
    }
    else if (inRequest.sessionInfo == kTryObtainAuthToken) {
        NSString *authToken = [inResponseDictionary valueForKeyPath:@"auth.token._text"];
        NSLog(@"%@: %@", kTryObtainAuthToken, authToken);
        
        _flickrContext.authToken = authToken;
        _flickrRequest.sessionInfo = nil;
        
    }
    else if (inRequest.sessionInfo == kUpgradeToken) {
        NSString *oat = [inResponseDictionary valueForKeyPath:@"auth.access_token.oauth_token"];
        NSString *oats = [inResponseDictionary valueForKeyPath:@"auth.access_token.oauth_token_secret"];
        
        _flickrContext.authToken = nil;
        _flickrContext.OAuthToken = oat;
        _flickrContext.OAuthTokenSecret = oats;
        NSRunAlertPanel(@"Auth Token Upgraded", [NSString stringWithFormat:@"New OAuth token: %@, secret: %@", oat, oats], @"Dismiss", nil, nil);
        
    }
    else if (inRequest.sessionInfo == kTestLogin) {
        _flickrRequest.sessionInfo = nil;
        NSRunAlertPanel(@"Test OK!", @"API returns successfully", @"Dismiss", nil, nil);
    }
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    NSLog(@"%s, error: %@", __PRETTY_FUNCTION__, inError);
    
    if (inRequest.sessionInfo == kTryObtainAuthToken) {
        [self performSelector:@selector(tryObtainAuthToken) withObject:nil afterDelay:kTryObtainAuthTokenInterval];
    }
    else {
        if (inRequest.sessionInfo == kOAuthAuth || inRequest.sessionInfo == kFrobRequest || inRequest.sessionInfo == kTryObtainAuthToken) {
                    }
        else if (inRequest.sessionInfo == kUpgradeToken) {
            
        }
        else if (inRequest.sessionInfo == kTestLogin) {
            
        }
        
        NSRunAlertPanel(@"API Error", [NSString stringWithFormat:@"An error occurred in the stage \"%@\", error: %@", inRequest.sessionInfo, inError], @"Dismiss", nil, nil);
    }
}

@end
