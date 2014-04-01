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

// const NSTimeInterval kTryObtainAuthTokenInterval = 3.0;

@implementation FlickerController

@synthesize flickrContext = _flickrContext;
@synthesize flickrRequest = _flickrRequest;
@synthesize photosets = _photosets;


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
    _photosets = [[NSMutableArray alloc] init];
    //NSLog(@"FlickerController initialized");
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleIncomingURL:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    //NSLog(@"url protocal registered...");
    _flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_SAMPLE_API_KEY
                                                   sharedSecret:OBJECTIVE_FLICKR_SAMPLE_API_SHARED_SECRET];
    _flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
    [_flickrRequest setDelegate:self];
    //NSLog(@"Flickr request object initialzed...");
    if([self isAuthenticated]) {
        [self getPhotoSets];
    }
    [arrayController addObserver:self
                      forKeyPath:@"selectionIndexes"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
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
    if([self isAuthenticated]) {
        [self getPhotoSets];
    }
}


- (void)getPhotoSets
{
    if (![_flickrRequest isRunning]) {
        FlickrSession *session = [[FlickrSession alloc] init];
        session.complete = @selector(didReceivePhotosetList:);
        session.delegate = self;
        _flickrRequest.sessionInfo = session;
		[_flickrRequest callAPIMethodWithGET:@"flickr.photosets.getList" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"100", @"per_page", @"url_m", @"primary_photo_extras", nil]];
	}
}

- (void)getPhotosInSetId: (NSString *)photosetId {
    // http://www.flickr.com/services/api/flickr.photosets.getPhotos.html
    
    //NSLog(@"photosetId: %@", photosetId);
    if (![_flickrRequest isRunning]) {
        FlickrSession *session = [[FlickrSession alloc] init];
        session.complete = @selector(didReceivePhotoset:);
        session.delegate = self;
        _flickrRequest.sessionInfo = session;
        NSString *perPage = [NSString stringWithFormat:@"%d", 500];
        NSString *page = [NSString stringWithFormat:@"%d", 1];
        NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:photosetId, @"photoset_id", perPage, @"per_page", page, @"page", @"url_o", @"extras",nil];
		[_flickrRequest callAPIMethodWithGET:@"flickr.photosets.getPhotos" arguments: args];
	}
}

- (void)didReceivePhotosetList:(NSArray *)params
{
    //NSLog(@"Selector called,");
    //[_photosets removeAllObjects];

    NSDictionary *dict = [params objectAtIndex:1];
    NSArray *photosets = [dict valueForKeyPath:@"photosets.photoset"];
    //NSLog(@"Sets: %@", sets);
    
    //NSLog(@"[before] photosets %@",  _photosets);
    for (NSDictionary *set in photosets) {
        //NSLog(@"set: %@", set);
        FlickrPhotoSet *photoset = [[FlickrPhotoSet alloc] initWithPhotoSet: set];
        // Add to array controller instead of array itself.
        [arrayController addObject:photoset];
    }
    //NSLog(@"[after] photosets %@",  _photosets);
}

- (void)didReceivePhotoset:(NSArray *)params
{
    NSDictionary *dict = [params objectAtIndex:1];
    NSLog(@"Response: %@", dict);
}


- (BOOL)isAuthenticated
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"accessToken"];
    NSString *accessSecret = [[NSUserDefaults standardUserDefaults] valueForKey:@"accessSecret"];
    
    if(accessToken == nil) {
        [NSApp beginSheet:authPromtSheet
           modalForWindow:(NSWindow *)_window
            modalDelegate:self
           didEndSelector:nil
              contextInfo:nil];
        return false;
    } else {
        _flickrContext.OAuthToken = accessToken;
        _flickrContext.OAuthTokenSecret = accessSecret;
        return true;
    }
}

- (BOOL)auth
{
    NSURL *callBackUrl = [NSURL URLWithString:kCallbackURLBaseString];
    // Post something to Flickr.
    // Then wait for the callback to flickrAPIRequest:didObtainOAuthRequestToken:secret:
    [_flickrRequest fetchOAuthRequestTokenWithCallbackURL:callBackUrl];
    
    NSLog(@"Start auth, CALLBACK: %@", callBackUrl);
    return true;
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
    
    [[NSUserDefaults standardUserDefaults] setValue:inAccessToken forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] setValue:inSecret forKey:@"accessSecret"];
    [[NSUserDefaults standardUserDefaults] setValue:inFullName forKey:@"fullname"];
    [[NSUserDefaults standardUserDefaults] setValue:inUserName forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setValue:inNSID forKey:@"NSID"];
    
    _flickrContext.OAuthToken = inAccessToken;
    _flickrContext.OAuthTokenSecret = inSecret;
    
    //NSLog(@"Token: %@, secret: %@", inAccessToken, inSecret);
    
    NSRunAlertPanel(@"Authenticated", [NSString stringWithFormat:@"OAuth access token: %@, secret: %@", inAccessToken, inSecret], @"Dismiss", nil, nil);
    [_authProgress stopAnimation:nil];
    [authPromtSheet close];
}



- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    FlickrSession *session = inRequest.sessionInfo;
    //NSLog(@"Callback Session: %@", session);
    NSArray *params = [NSArray arrayWithObjects:inRequest, inResponseDictionary, nil];
    [session.delegate performSelector:session.complete
                           withObject:params];
    return;
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    
    FlickrSession *session = inRequest.sessionInfo;
    NSLog(@"Callback Session: %@", session);
    NSArray *params = [NSArray arrayWithObjects:inRequest, inError, nil];
    [session.delegate performSelector:session.error
                           withObject:params];
    return;
}

@end
