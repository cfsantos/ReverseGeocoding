//
//  ViewController.m
//  ReverseGeocoding
//
//  Created by Claudio Filipi Goncalves dos Santos on 10/20/15.
//  Copyright © 2015 Claudio Filipi Goncalves dos Santos. All rights reserved.
//

#import "ViewController.h"
@import MapKit;
@import CoreLocation;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *latitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *longitudeTextField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@property(nonatomic)CGFloat latitude;
@property(nonatomic)CGFloat longitude;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.latitude = -47;
    self.longitude = -22;
    MKCoordinateSpan span = {.latitudeDelta =  1, .longitudeDelta =  1};
    CLLocationCoordinate2D coord = {.latitude =  self.latitude, .longitude =  self.longitude};
    MKCoordinateRegion region = {coord, span};
    [self.mapView setRegion:region animated:NO];
}

-(void)addLoading{
    self.loadingView = [[UIActivityIndicatorView alloc] initWithFrame:self.mapView.frame];
    self.loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.5 alpha:0.3];
    [self.mapView addSubview:self.loadingView];
    
    [self.loadingView startAnimating];
}

-(void)removeLoading{
    [self.loadingView stopAnimating];
    
    [self.loadingView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addressToLatLong:(id)sender {
    CLGeocoder* reverseGeocoder = [[CLGeocoder alloc] init];
    self.latitude = [self.latitudeTextField.text floatValue];
    self.longitude = [self.longitudeTextField.text floatValue];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.latitude
                                                      longitude:self.longitude];
    
    [self addLoading];
    
    if (reverseGeocoder) {
        [reverseGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark* placemark = [placemarks firstObject];
            if (placemark) {

                NSString *address = [placemark thoroughfare];
                self.addressTextField.text = address;
                
                [self mapviewWithLatitude:self.latitude
                                longitude:self.longitude];
                
                
            }
            [self removeLoading];
        }];
    }
}

- (IBAction)latLongToAddress:(id)sender {
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    NSString *addressString = self.addressTextField.text;
    
    [self addLoading];
    
    [geocoder geocodeAddressString:addressString
                 completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark* placemark = [placemarks firstObject];
        if (placemark) {
            CLLocation *location = placemark.location;
            self.latitude = location.coordinate.latitude;
            self.longitude = location.coordinate.longitude;
            self.latitudeTextField.text = [NSString stringWithFormat:@"%f", self.latitude];
            self.longitudeTextField.text = [NSString stringWithFormat:@"%f", self.longitude];
            
            [self mapviewWithLatitude:self.latitude
                            longitude:self.longitude];
            
            
        }
        [self removeLoading];
        
    }];
}

-(void)mapviewWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude{
    CLLocationCoordinate2D coord = {.latitude =  latitude, .longitude =  longitude};
    MKCoordinateRegion aRegion = MKCoordinateRegionMakeWithDistance(
                                                                CLLocationCoordinate2DMake(self.latitude, self.longitude), 500, 500);
    
    MKCoordinateSpan span = aRegion.span;
    MKCoordinateRegion region = {coord, span};
    [self.mapView setRegion:region animated:NO];
    
    [self annotationInLatitude:latitude longitude:longitude];
}

-(void)annotationInLatitude:(CGFloat)latitude longitude:(CGFloat)longitude{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    CLLocationCoordinate2D coord = {.latitude =  latitude, .longitude =  longitude};
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coord];
    [annotation setTitle:@"Hello World"];
    [self.mapView addAnnotation:annotation];

}

#pragma mark - MKMapView delegate calls

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered{
    if (fullyRendered) {
        [self annotationInLatitude:self.latitude longitude:self.longitude];
    }
}

#pragma mark - UITextField Delegate calls

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}


@end
