//
//  Listener.m
//  LeapLogger
//
//  Created by Lucky on 2015/08/07.
//  Copyright (c) 2015年 Lucky. All rights reserved.
//

#import "Listener.h"
#import "CsvLogger.h"

static NSString *const kLogDir = @"LeapLog";

@implementation Listener
{
    LeapController *controller_;
    CsvLogger *logger_;
    
    NSMutableString *data_;
    
    long long pre_frame_id_;
}

@synthesize delegate;

- (void) run
{
    controller_ = [[LeapController alloc] init];
    [controller_ addListener:self];
    
    logger_ = [[CsvLogger alloc] init];
    [logger_ prepareFile:kLogDir];
    
    data_ = [[NSMutableString alloc] initWithString:@""];
    
    if (DEBUG) NSLog(@"run");
}

#pragma mark - LeapListener Callbacks

- (void)onInit:(NSNotification *)notification
{
    if (DEBUG) NSLog(@"Initialized");
    
    NSString *header = [self getHeaderString];
    [logger_ write:header];
    
    pre_frame_id_ = -1;
}

- (void)onConnect:(NSNotification *)notification
{
    if (DEBUG) NSLog(@"Connected");
    LeapController *aController = (LeapController *)[notification object];
    [aController setPolicy:LEAP_POLICY_BACKGROUND_FRAMES];
}

- (void)onDisconnect:(NSNotification *)notification
{
    if (DEBUG) NSLog(@"Disconnected");
}

- (void)onServiceConnect:(NSNotification *)notification
{
    if (DEBUG) NSLog(@"Service Connected");
}

- (void)onServiceDisconnect:(NSNotification *)notification
{
    if (DEBUG) NSLog(@"Service Disconnected");
}

- (void)onDeviceChange:(NSNotification *)notification
{
    if (DEBUG) NSLog(@"Device Changed");
}

- (void)onExit:(NSNotification *)notification
{
    if (DEBUG) NSLog(@"Exited");
}

- (void)onFrame:(NSNotification *)notification
{
    LeapController *aController = (LeapController *)[notification object];
    LeapFrame *frame = [aController frame:0];
    
    if (![frame isValid]) return;
    
    // フレームIDが変わっていない時はデータの更新が無いと考える
    if (pre_frame_id_ == [frame id]) return;
    pre_frame_id_ = [frame id];
    
    // update FPS
    [delegate updateFpsDisplay:[frame currentFramesPerSecond]];
    
    NSArray *hands = [frame hands];
    
    // update hands count
    [delegate updateHandCountLabel:[hands count]];
    
    for (LeapHand *hand in hands) {
        if (![hand isValid]) continue;
        
        // frame
        [data_ appendFormat:@"%qi, %qi, %f, ",
         [frame id], [frame timestamp], [frame currentFramesPerSecond]];
        
        // hand
        [self appendHandDataString:hand];
        
        // arm
        [self appendArmDataString:[hand arm]];
        
        NSArray *fingers = [hand fingers];
        for (LeapFinger *finger in fingers) {
            [self appendFingerDataString:finger];
        }
        
        [data_ appendString:@"\n"];
        
        [logger_ write:data_];
        [data_ setString:@""];
    }
}

- (void)onFocusGained:(NSNotification *)notification
{
    if (DEBUG) NSLog(@"Focus Gained");
}

- (void)onFocusLost:(NSNotification *)notification
{
    if (DEBUG) NSLog(@"Focus Lost");
}

- (void)updateHandCount:(NSArray *)hands
{
    [delegate updateHandCountLabel:[hands count]];
}

#pragma mark - data row

- (void) appendHandDataString:(LeapHand *)hand
{
    [data_ appendFormat:@"%d, %d, %d, %f, %f, "
     "%f, %f, %f, "
     "%f, %f, %f, "
     "%f, %f, %f, "
     "%f, %f, %f, "
     "%f, %f, %f, "
     "%f, "
     "%f, %f, %f, %f, ",
     [hand id], [hand isLeft], [hand isRight], [hand grabStrength], [hand pinchStrength],
     [[hand direction] x], [[hand direction] y], [[hand direction] z],
     [[hand palmPosition] x], [[hand palmPosition] y], [[hand palmPosition] z],
     [[hand palmVelocity] x], [[hand palmVelocity] y], [[hand palmVelocity] z],
     [[hand palmNormal] x], [[hand palmNormal] y], [[hand palmNormal] z],
     [[hand stabilizedPalmPosition] x], [[hand stabilizedPalmPosition] y], [[hand stabilizedPalmPosition] z],
     [hand palmWidth],
     [[hand sphereCenter] x], [[hand sphereCenter] y], [[hand sphereCenter] z], [hand sphereRadius]];
}

- (void) appendArmDataString:(LeapArm *)arm
{
    [data_ appendFormat:@"%f, %f, %f, "
                                    "%f, %f, %f, "
                                    "%f, %f, %f, "
                                    "%f, %f, %f, "
                                    "%f, ",
     [[arm elbowPosition] x], [[arm elbowPosition] y], [[arm elbowPosition] z],
     [[arm wristPosition] x], [[arm wristPosition] y], [[arm wristPosition] z],
     [[arm center] x], [[arm center] y], [[arm center] z],
     [[arm direction] x], [[arm direction] y], [[arm direction] z],
     [arm width]];
}

- (void) appendFingerDataString:(LeapFinger *)finger
{
    [data_ appendFormat:@"%d, %d, %f, %f, "
                                    "%f, %f, %f, "
                                    "%f, %f, %f, "
                                    "%f, %f, %f, "
                                    "%f, %f, %f, ",
     [finger id], [finger isExtended], [finger length], [finger width],
     [[finger direction] x], [[finger direction] y], [[finger direction] z],
     [[finger tipPosition] x], [[finger tipPosition] y], [[finger tipPosition] z],
     [[finger tipVelocity] x], [[finger tipVelocity] y], [[finger tipVelocity] z],
     [[finger stabilizedTipPosition] x], [[finger stabilizedTipPosition] y], [[finger stabilizedTipPosition] z]];
    
    for (LeapFingerJoint ji = LEAP_FINGER_JOINT_MCP; ji <= LEAP_FINGER_JOINT_TIP; ++ji) {
        LeapVector *joint = [finger jointPosition:ji];
        [data_ appendFormat:@"%f, %f, %f, ",
         [joint x], [joint y], [joint z]];
    }
}

#pragma mark - Header String

- (NSString *)getHeaderString
{
    NSString *header = @"frame_id, timestamp, fps, "
    
                        // hand
                        "hand_id, isLeft, isRight, grabStrength, pinchStrength, "
                        "hand_direction_x, hand_direction_y, hand_direction_z, "
                        "palmPosition_x, palmPosition_y, palmPosition_z, "
                        "palmVelocity_x, palmVelocity_y, palmVelocity_z, "
                        "palmNormal_x, palmNormal_y, palmNormal_z, "
                        "stabilizedPalmPosition_x, stabilizedPalmPosition_y, stabilizedPalmPosition_z, "
                        "palmWidth, "
                        "sphereCenter_x, sphereCenter_y, sphereCenter_z, sphereRadius, "
    
                        // arm
                        "elbowPosition_x, elbowPosition_y, elbowPosition_z, "
                        "wristPosition_x, wristPosition_y, wristPosition_z, "
                        "center_x, center_y, center_z, "
                        "direction_x, direction_y, direction_z, "
                        "width, "
    
                        // thumb
                        "thumb_id, thumb_isExtended, thumb_length, thumb_width, "
                        "thum_direction_x, thum_direction_y, thum_direction_z, "
                        "thumb_tipPosition_x, thumb_tipPosition_y, thumb_tipPosition_z, "
                        "thumb_tipVelocity_x, thumb_tipVelocity_y, thumb_tipVelocity_z, "
                        "thumb_stabilizedTipPosition_x, thumb_stabilizedTipPosition_y, thumb_stabilizedTipPosition_z, "
                        "thumb_MCP_jointPosition_x, thumb_MCP_jointPosition_y, thumb_MCP_jointPosition_z, "
                        "thumb_PIP_jointPosition_x, thumb_PIP_jointPosition_y, thumb_PIP_jointPosition_z, "
                        "thumb_DIP_jointPosition_x, thumb_DIP_jointPosition_y, thumb_DIP_jointPosition_z, "
                        "thumb_TIP_jointPosition_x, thumb_TIP_jointPosition_y, thumb_TIP_jointPosition_z, "
    
                        // index
                        "index_id, index_isExtended, index_length, index_width, "
                        "index_direction_x, index_direction_y, index_direction_z, "
                        "index_tipPosition_x, index_tipPosition_y, index_tipPosition_z, "
                        "index_tipVelocity_x, index_tipVelocity_y, index_tipVelocity_z, "
                        "index_stabilizedTipPosition_x, index_stabilizedTipPosition_y, index_stabilizedTipPosition_z, "
                        "index_MCP_jointPosition_x, index_MCP_jointPosition_y, index_MCP_jointPosition_z, "
                        "index_PIP_jointPosition_x, index_PIP_jointPosition_y, index_PIP_jointPosition_z, "
                        "index_DIP_jointPosition_x, index_DIP_jointPosition_y, index_DIP_jointPosition_z, "
                        "index_TIP_jointPosition_x, index_TIP_jointPosition_y, index_TIP_jointPosition_z, "
    
                        // middle
                        "middle_id, middle_isExtended, middle_length, middle_width, "
                        "middle_direction_x, middle_direction_y, middle_direction_z, "
                        "middle_tipPosition_x, middle_tipPosition_y, middle_tipPosition_z, "
                        "middle_tipVelocity_x, middle_tipVelocity_y, middle_tipVelocity_z, "
                        "middle_stabilizedTipPosition_x, middle_stabilizedTipPosition_y, middle_stabilizedTipPosition_z, "
                        "middle_MCP_jointPosition_x, middle_MCP_jointPosition_y, middle_MCP_jointPosition_z, "
                        "middle_PIP_jointPosition_x, middle_PIP_jointPosition_y, middle_PIP_jointPosition_z, "
                        "middle_DIP_jointPosition_x, middle_DIP_jointPosition_y, middle_DIP_jointPosition_z, "
                        "middle_TIP_jointPosition_x, middle_TIP_jointPosition_y, middle_TIP_jointPosition_z, "
    
                        // ring
                        "ring_id, ring_isExtended, ring_length, ring_width, "
                        "ring_direction_x, ring_direction_y, ring_direction_z, "
                        "ring_tipPosition_x, ring_tipPosition_y, ring_tipPosition_z, "
                        "ring_tipVelocity_x, ring_tipVelocity_y, ring_tipVelocity_z, "
                        "ring_stabilizedTipPosition_x, ring_stabilizedTipPosition_y, ring_stabilizedTipPosition_z, "
                        "ring_MCP_jointPosition_x, ring_MCP_jointPosition_y, ring_MCP_jointPosition_z, "
                        "ring_PIP_jointPosition_x, ring_PIP_jointPosition_y, ring_PIP_jointPosition_z, "
                        "ring_DIP_jointPosition_x, ring_DIP_jointPosition_y, ring_DIP_jointPosition_z, "
                        "ring_TIP_jointPosition_x, ring_TIP_jointPosition_y, ring_TIP_jointPosition_z, "
    
                        // pinky
                        "pinky_id, pinky_isExtended, pinky_length, pinky_width, "
                        "pinky_direction_x, pinky_direction_y, pinky_direction_z, "
                        "pinky_tipPosition_x, pinky_tipPosition_y, pinky_tipPosition_z, "
                        "pinky_tipVelocity_x, pinky_tipVelocity_y, pinky_tipVelocity_z, "
                        "pinky_stabilizedTipPosition_x, pinky_stabilizedTipPosition_y, pinky_stabilizedTipPosition_z, "
                        "pinky_MCP_jointPosition_x, pinky_MCP_jointPosition_y, pinky_MCP_jointPosition_z, "
                        "pinky_PIP_jointPosition_x, pinky_PIP_jointPosition_y, pinky_PIP_jointPosition_z, "
                        "pinky_DIP_jointPosition_x, pinky_DIP_jointPosition_y, pinky_DIP_jointPosition_z, "
                        "pinky_TIP_jointPosition_x, pinky_TIP_jointPosition_y, pinky_TIP_jointPosition_z\n";
    
    return header;
}

@end
