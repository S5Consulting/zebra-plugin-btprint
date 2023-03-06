/********* ZebraPluginBtPrint.m Cordova Plugin Implementation *******/

@import ExternalAccessory;
@import UIKit;
#import <Cordova/CDVPlugin.h>
#import "MfiBtPrinterConnection.h"

@interface ZebraPluginBtPrint : NSObject 

 //   - (void)print:(CDVInvokedUrlCommand*)command;

@end

@implementation ZebraPluginBtPrint 


//Sends the printing content to the printer controller and opens them.
- (void)print:(CDVInvokedUrlCommand*)command
{

     NSString *serialNumber = @"";
    NSString* mac = [command.arguments objectAtIndex:0];
    NSString* data = [command.arguments objectAtIndex:1];
//Find the Zebra Bluetooth Accessory
    EAAccessoryManager *sam = [EAAccessoryManager sharedAccessoryManager];
    NSArray *connectedAccessories = [sam connectedAccessories];
    for (EAAccessory *accessory in connectedAccessories) {
        if([accessory.protocolStrings indexOfObject:@"com.zebra.rawport"] != NSNotFound) {
            serialNumber = accessory.serialNumber;
            break;
//Note: This will find the first printer connected! If you have multiple Zebra printers connected, you should display a list to the user and have him select the one they wish to use
        }
    }
// Instantiate connection to Zebra Bluetooth accessory
 /*   id<ZebraPrinterConnection, NSObject> thePrinterConn = [[MfiBtPrinterConnection alloc] initWithSerialNumber:serialNumber];
// Open the connection - physical connection is established here.
    BOOL success = [thePrinterConn open];
    NSError *error = nil;
// Send the data to printer as a byte array.
success = success && [thePrinterConn write:[data dataUsingEncoding:NSUTF8StringEncoding] error:&error];
  if (success != YES || error != nil) {
      UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
      [errorAlert show];
     // [errorAlert release];
   }
// Close the connection to release resources.
    [thePrinterConn close]; */
    //[thePrinterConn release];
} 

@end  