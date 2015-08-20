//
//  EnvironmentSettingsViewController.m
//  Pods
//
//  Created by Jobin on 8/11/15.
//
//

#import "ACAdminViewController.h"
#import "ACConstants.h"
#import "ArtAPI.h"

@interface ACAdminViewController ()

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSArray *environmentsArray;
@property(nonatomic,strong) NSIndexPath *selectedIndexPath;
@property(nonatomic,strong) UITextField *cutomEnvironmentTextField;
@property(nonatomic,strong) UILabel *tokenLabel;

@end

@implementation ACAdminViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.environmentsArray = @[@"api.art.com",@"developer-api.art.com",@"qa1-api.art.com",@"rel1-api.art.com",/*@"rel2-api.art.com",*/@"dev-api.art.com"];
    
    self.title = @"Environment Settings";
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = closeItem;
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    
    NSString *deviceToken = [ACConstants getPushToken];
    
    if(!deviceToken) deviceToken = @"No Device Token";

    // ============== Header ==================
    UILabel *tokenLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 250, 60)];
    tokenLabel.text = deviceToken;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    [headerView addSubview: tokenLabel];
    self.tokenLabel = tokenLabel;
    UIButton *copyButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(tokenLabel.frame)+2, 10, 50, 40)];
    [copyButton setTitle:@"Copy" forState:UIControlStateNormal];
    [copyButton addTarget:self action:@selector(copyTokenString:) forControlEvents:UIControlEventTouchUpInside];
    [copyButton setTitleColor:UIColorFromRGB(0x32ccff) forState:UIControlStateNormal];
    [headerView addSubview: copyButton];
    self.tableView.tableHeaderView = headerView;

    // ============== Footer ==================

    UITextField *environmentTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 250, 40)];
    environmentTextField.borderStyle = UITextBorderStyleLine;
    environmentTextField.placeholder = @" Enter the custom Environment";
    self.cutomEnvironmentTextField = environmentTextField;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    [footerView addSubview: environmentTextField];
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(environmentTextField.frame)+10, 10, 40, 40)];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveCustomEnvironment:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitleColor:UIColorFromRGB(0x32ccff) forState:UIControlStateNormal];
    [footerView addSubview: saveButton];

    self.tableView.tableFooterView = footerView;
    
    
    NSString *currentEnvironment = [ACConstants getEnvironment];
    int index = [self.environmentsArray indexOfObject:currentEnvironment];
    if(index >= 0 && index < self.environmentsArray.count)
    {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    }
    else
    {
        self.cutomEnvironmentTextField.text = currentEnvironment;
    }

    // Do any additional setup after loading the view from its nib.
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UITableView *tableView = [[UITableView alloc] initWithFrame:view.bounds];
    [view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorInset = UIEdgeInsetsZero;
    [tableView setLayoutMargins:UIEdgeInsetsZero];

    self.tableView = tableView;
    self.view = view;
}


-(void)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)doneAction:(id)sender
{
    if(self.selectedIndexPath)
    {
        [ACConstants setEnvironment:[self.environmentsArray objectAtIndex:self.selectedIndexPath.row]];
    }

    [ArtAPI logoutAndReset];
    [ArtAPI startAPI] ;

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)saveCustomEnvironment:(id)sender
{
    NSString *customEnv = self.cutomEnvironmentTextField.text;
    if(customEnv.length)
    {
        self.selectedIndexPath = nil;
        [ACConstants setEnvironment:self.cutomEnvironmentTextField.text];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Environment" message:@"Custom Environment has been set" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)copyTokenString:(id)sender
{
    [UIPasteboard generalPasteboard].string = self.tokenLabel.text;
    
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Device Token"
                                                     message:@"Copied to Clipboard"
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles: nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    
//}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.environmentsArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"  Pre-Defined Environments";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"  Custom Environment ?";
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"ACLoginCustomCell";
    UITableViewCell * cell = (UITableViewCell*)[tableView
                                                    dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier];
        cell.separatorInset = UIEdgeInsetsMake(0, -15, 0, 0);
    }
    if ([indexPath compare:self.selectedIndexPath] == NSOrderedSame)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Make cell unselectable
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.text = [self.environmentsArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    
    [self.tableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
