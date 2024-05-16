#import "LoginViewController.h"
#import "UstTestApp-Swift.h"
#import <FirebaseAuth/FirebaseAuth.h>
#import <GoogleSignIn/GoogleSignIn.h>
@import Firebase;
@import GoogleSignIn;

@interface LoginViewController ()

@property (nonatomic, strong) LoginViewModel *viewModel;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Home Screen";
    [self.siginButton addTarget:self action:@selector(signInButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.viewModel = [[LoginViewModel alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [self.viewModel isNetworkAvailableWithCompletion:^(BOOL status) {
        if (status) {
            NSString *userToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"userToken"];
            if (userToken) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil]; // Replace "Main" with your actual storyboard name
                HomeScreenViewController *nextVC = [storyboard instantiateViewControllerWithIdentifier:@"HomeScreenViewController"];
                [weakSelf.navigationController pushViewController:nextVC animated:YES];
            } else {
                [weakSelf.viewModel signOut];
            }
        } else {
            [weakSelf.viewModel signOut];
        }
    }];
}

- (void)signInButtonTapped{
    GIDConfiguration *config = [[GIDConfiguration alloc] initWithClientID:[FIRApp defaultApp].options.clientID];
    [GIDSignIn.sharedInstance setConfiguration:config];
    
    __weak __auto_type weakSelf = self;
    [GIDSignIn.sharedInstance signInWithPresentingViewController:self
                                                      completion:^(GIDSignInResult * _Nullable result, NSError * _Nullable error) {
        __auto_type strongSelf = weakSelf;
        if (strongSelf == nil) { return; }
        
        if (error == nil) {
            FIRAuthCredential *credential =
            [FIRGoogleAuthProvider credentialWithIDToken:result.user.idToken.tokenString
                                             accessToken:result.user.accessToken.tokenString];
            // ...
            [[FIRAuth auth] signInWithCredential:credential completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Firebase sign-in error: %@", error.localizedDescription);
                } else {
                    NSString *tokenString = result.user.idToken.tokenString;
                    [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:@"userToken"];
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    HomeScreenViewController *nextVC = [storyboard instantiateViewControllerWithIdentifier:@"HomeScreenViewController"];
                    [self.navigationController pushViewController:nextVC animated:YES];
                }
            }];
        } else {
            // ...
        }
    }];
}

@end
