#import <UIKit/UIKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
@import FirebaseCore;

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet GIDSignInButton *siginButton;
@end

NS_ASSUME_NONNULL_END
