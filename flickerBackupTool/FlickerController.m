//
//  FlickerController.m
//  flickerBackupTool
//
//  Created by Jason Lu on 11/3/13.
//  Copyright (c) 2013 Lu Jason. All rights reserved.
//

#import "FlickerController.h"

static NSString *kCallbackURLBaseString = @"oatransdemo://callback";
static NSString *kOAuthAuth = @"OAuth";
static NSString *kFrobRequest = @"Frob";
static NSString *kTryObtainAuthToken = @"TryAuth";
static NSString *kTestLogin = @"TestLogin";
static NSString *kUpgradeToken = @"UpgradeToken";
const NSTimeInterval kTryObtainAuthTokenInterval = 3.0;

@implementation FlickerController

NSString *const apiKey = @"42b8daa9c251314e3737efd371dc7a4d";
NSString *const apiSecret = @"0e702fcbf0e5224b";

- (id)init
{
    context = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_SAMPLE_API_KEY sharedSecret:OBJECTIVE_FLICKR_SAMPLE_API_SHARED_SECRET];
    //- (void)
    _flickrContext = context;

    request = [[OFFlickrAPIRequest alloc] initWithAPIContext:context];

    _flickrRequest = request;
    // set the delegate, here we assume it's the controller that's creating the request object
    [request setDelegate:self];
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleIncomingURL:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    

    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Hi there."];
    //[alert runModal];
    
    return self;
}
- (IBAction)testLoginAction:(id)sender
{
     NSLog(@"btn pushed");
    [self auth];
}

- (void)getPhoto
{
    //Calling flickr.photos.getRecent with the argument per_page = 1:
    [request callAPIMethodWithGET:@"flickr.photos.getRecent" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"per_page", nil]];
    
    //POST method
    /*
    [request callAPIMethodWithPOST:@"flickr.photos.setMeta" arguments:[NSDictionary dictionaryWithObjectsAndKeys:photoID, @"photo_id", newTitle, @"title", newDescription, @"description", nil]];
     */
}

- (BOOL)auth
{
    
    request.sessionInfo = kOAuthAuth;
    _flickrRequest.sessionInfo = kOAuthAuth;
    [_flickrRequest fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:kCallbackURLBaseString]];
    NSLog(@"CALLBACK: %@", kCallbackURLBaseString);
    //NSRunAlertPanel(@"Authenticating", @"...", @"Dismiss", nil, nil);

    //[request callAPIMethodWithGET:@"flickr.auth.getFrob"];
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
    
    NSURL *authURL = [_flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    NSLog(@"Auth URL: %@", [authURL absoluteString]);
    [[NSWorkspace sharedWorkspace] openURL:authURL];
    

}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID
{
    _flickrContext.OAuthToken = inAccessToken;
    _flickrContext.OAuthTokenSecret = inSecret;
    
    NSLog(@"Token: %@, secret: %@", inAccessToken, inSecret);
    
    NSRunAlertPanel(@"Authenticated", [NSString stringWithFormat:@"OAuth access token: %@, secret: %@", inAccessToken, inSecret], @"Dismiss", nil, nil);
}



- (void)handleIncomingURL:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    
    NSURL *callbackURL = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    NSLog(@"Callback URL: %@", [callbackURL absoluteString]);
    
    NSString *requestToken= nil;
    NSString *verifier = nil;
    
    BOOL result = OFExtractOAuthCallback(callbackURL, [NSURL URLWithString:kCallbackURLBaseString], &requestToken, &verifier);
    if (!result) {
        NSLog(@"Invalid callback URL");
    }
    
    [request fetchOAuthAccessTokenWithRequestToken:requestToken verifier:verifier];
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
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"f."];
    [alert runModal];

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
