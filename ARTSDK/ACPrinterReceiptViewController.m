//
//  ACPrinterReceiptViewController.m
//  Pods
//
//  Created by Jobin on 16/05/14.
//
//

#import "ACPrinterReceiptViewController.h"
#import "ArtAPI.h"

@interface ACPrinterReceiptViewController ()

@end

@implementation ACPrinterReceiptViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)finishCheckout:(id)sender
{
    [ArtAPI setCountries:nil];
    [ArtAPI setStates:nil];
    [ArtAPI setCart:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ORDERCOMPLETED" object:nil];
    
    if( self.navigationController.modalPresentationStyle ==  UIModalPresentationFullScreen){
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else if(self.navigationController.modalPresentationStyle ==  UIModalPresentationFormSheet){
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        //NSLog(@"modalPresentationStyle: other");
    }
}

@end
