//
//  ViewController.m
//  xlight-ios
//
//  Created by Felix on 12/12/2016.
//  Copyright © 2016 数言. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic,strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    dispatch_queue_t centralQueue = dispatch_queue_create("com.manmanlai", DISPATCH_QUEUE_SERIAL);
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];
    
    
    [self.centralManager scanForPeripheralsWithServices:@[] options:nil];
//    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"name:%@",peripheral);
    if (!peripheral || !peripheral.name || ([peripheral.name isEqualToString:@""])) {
        return;
    }
    
    if (!self.peripheral || (self.peripheral.state == CBPeripheralStateDisconnected)) {
        self.peripheral = peripheral;
        self.peripheral.delegate = self;
        NSLog(@"connect peripheral");
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
    
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (!peripheral) {
        return;
    }
    
    [self.centralManager stopScan];
    
    NSLog(@"peripheral did connect");
    [self.peripheral discoverServices:nil];
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray *services = nil;
    
    if (peripheral != self.peripheral) {
        NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    services = [peripheral services];
    if (!services || ![services count]) {
        NSLog(@"No Services");
        return ;
    }
    
    for (CBService *service in services) {
        NSLog(@"service:%@",service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
        
    }
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"characteristics:%@",[service characteristics]);
    NSArray *characteristics = [service characteristics];
    
    if (peripheral != self.peripheral) {
        NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    self.characteristic = [characteristics firstObject];
    //[self.peripheral readValueForCharacteristic:self.characteristic];
    [self.peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
}
@end
