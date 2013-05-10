//
//  WMPAppDelegate.m
//  AudioEngineDemo
//
//  Created by Will Pragnell on 10/05/2013.
//  Copyright (c) 2013 Will Pragnell. All rights reserved.
//

#import "WMPAppDelegate.h"
#import "WMPViewController.h"
#import "AEPlaythroughChannel.h"

@interface WMPAppDelegate ()

@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) AEPlaythroughChannel *playthroughChannel;
@property (nonatomic, strong) AEAudioUnitFilter *filter;
@property (nonatomic, assign) AEChannelGroupRef inputChannelGroup;

@end

@implementation WMPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self bootstrapAudio];
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.viewController = [[WMPViewController alloc] initWithNibName:@"WMPViewController" bundle:nil];
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)bootstrapAudio
{
  [self configureAudioController];
  [self configureAndAddPlaythroughChannel];
  [self addFilter];
  [self startAudioController];
}

- (void)configureAudioController
{
  AudioStreamBasicDescription audioDescription = [AEAudioController interleaved16BitStereoAudioDescription];
  self.audioController = [[AEAudioController alloc] initWithAudioDescription:audioDescription inputEnabled:YES];
}

- (void)configureAndAddPlaythroughChannel
{
  self.playthroughChannel = [[AEPlaythroughChannel alloc] initWithAudioController:self.audioController];
  [self.audioController addInputReceiver:self.playthroughChannel];
  self.inputChannelGroup = [self.audioController createChannelGroup];
  [self.audioController addChannels:@[self.playthroughChannel] toChannelGroup:self.inputChannelGroup];
}

- (void)addFilter
{
  AudioComponentDescription componentDescription = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_Effect, kAudioUnitSubType_Reverb2);
  NSError *error = NULL;
  self.filter = [[AEAudioUnitFilter alloc] initWithComponentDescription:componentDescription audioController:self.audioController error:&error];
  if (self.filter)
  {
    [self.audioController addFilter:self.filter];
  }
  else
  {
    NSLog(@"%@", error);
  }
}

- (void)startAudioController
{
  NSError *error = NULL;
  if (![self.audioController start:&error])
  {
    NSLog(@"Error starting audio controller: %@", error);
  }
}

@end