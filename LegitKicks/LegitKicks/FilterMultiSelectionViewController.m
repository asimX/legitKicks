//
//  FilterMultiSelectionViewController.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 08/12/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "FilterMultiSelectionViewController.h"
#import "MCPanelViewController.h"

@interface FilterMultiSelectionViewController ()
{
    NSMutableArray *listArray;
    NSArray *sizeArray;
    NSArray *conditionArray;
    
    NSMutableDictionary *offscreenCell;
}

@end

@implementation FilterMultiSelectionViewController

@synthesize selectedListArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
     // Do any additional setup after loading the view.
    
    [self setDoneButtonToNavigationBar];
    
    offscreenCell = [NSMutableDictionary dictionary];
    
    conditionArray = @[@"Deadstock(DS - 10/10) - Never worn/Brand New", @"VeryNear Deadstock (VNDS - 9+/10) - Minor Flaws/Wears", @"GoodCondition (9/10) - Some Flaws/Wears", @"SemiBeat (8/10) - Multiple Flaws/Wears", @"Beat(7/10 or less) - Heavy Flaws/Wears"];
    
    sizeArray = @[@"1", @"1.5", @"2", @"2.5", @"3", @"3.5", @"4", @"4.5", @"5", @"5.5", @"6", @"6.5", @"7", @"7.5", @"8", @"8.5", @"9", @"9.5", @"10", @"10.5", @"11", @"11.5", @"12", @"12.5", @"13", @"13.5", @"14", @"15", @"16", @"17", @"18"];
    
    [listTableView reloadData];
    
}


#pragma mark Set Done button to Navigationbar
- (void)setDoneButtonToNavigationBar
{
    /*UIImage *backButtonImage = [UIImage imageNamed:@"back_btn"];
    CGRect buttonFrame = CGRectMake(0, 0, 44, 44);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = buttonFrame;
    [button addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:backButtonImage forState:UIControlStateNormal];*/
    
    
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnClicked:)];
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16;// it was -6 in iOS 6
    
    
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:settingItem, nil]];
    
}

-(IBAction)doneBtnClicked:(id)sender
{
    if(self.filterType==SIZE_FILTER_TYPE)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckForFilterSelectedSize" object:self.selectedListArray];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckForFilterSelectedCondition" object:self.selectedListArray];
    }
    //[self.navigationController popViewControllerAnimated:YES];
    
    MCPanelViewController *rightPanelViewController = [self.navigationController panelViewController];
    [rightPanelViewController dismiss];
}



#pragma mark Tableview delegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.filterType==SIZE_FILTER_TYPE)
    {
        return [sizeArray count];
    }
    else
    {
        return [conditionArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [offscreenCell objectForKey:@"listCell"];
    if(cell==nil)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
        [offscreenCell setObject:cell forKey:@"listCell"];
    }
    
    UILabel *titleLbl = (UILabel *)[cell.contentView viewWithTag:10];
    
    if(self.filterType==SIZE_FILTER_TYPE)
    {
        titleLbl.text = [sizeArray objectAtIndex:indexPath.row];
    }
    else
    {
        titleLbl.text = [conditionArray objectAtIndex:indexPath.row];
    }
    
    titleLbl.preferredMaxLayoutWidth = listTableView.frame.size.width - 18.0; //titleLbl.frame.size.width;
    
    [cell layoutSubviews];
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    UILabel *titleLbl = (UILabel *)[cell.contentView viewWithTag:10];
    
    if(self.filterType==SIZE_FILTER_TYPE)
    {
        titleLbl.text = [sizeArray objectAtIndex:indexPath.row];
        
        if([self.selectedListArray containsObject:[sizeArray objectAtIndex:indexPath.row]])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else
    {
        titleLbl.text = [conditionArray objectAtIndex:indexPath.row];
        
        if([self.selectedListArray containsObject:[conditionArray objectAtIndex:indexPath.row]])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    [cell layoutIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.filterType==SIZE_FILTER_TYPE)
    {
        if([self.selectedListArray containsObject:[sizeArray objectAtIndex:indexPath.row]])
        {
            [self.selectedListArray removeObject:[sizeArray objectAtIndex:indexPath.row]];
        }
        else
        {
            [self.selectedListArray addObject:[sizeArray objectAtIndex:indexPath.row]];
        }
    }
    else
    {
        if([self.selectedListArray containsObject:[conditionArray objectAtIndex:indexPath.row]])
        {
            [self.selectedListArray removeObject:[conditionArray objectAtIndex:indexPath.row]];
        }
        else
        {
            [self.selectedListArray addObject:[conditionArray objectAtIndex:indexPath.row]];
        }
    }
    
    //[listTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [listTableView reloadData];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
