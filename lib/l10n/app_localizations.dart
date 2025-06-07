import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'RIVO'**
  String get appTitle;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Text for sign up link
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome to RIVO'**
  String get welcome;

  /// Products section title
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// Title for other users' profiles
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings section title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language selection label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Hebrew language option
  ///
  /// In en, this message translates to:
  /// **'עברית'**
  String get hebrew;

  /// Error message when a required field is empty
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// Error message when an invalid email is entered
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validationEmailInvalid;

  /// Error message when password is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long'**
  String get validationPasswordTooShort;

  /// Error message when bio exceeds maximum length
  ///
  /// In en, this message translates to:
  /// **'Bio cannot be longer than 200 characters'**
  String get validationBioTooLong;

  /// Warning message when there are unsaved changes
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes'**
  String get unsavedChanges;

  /// Confirmation dialog title when discarding changes
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesConfirmation;

  /// Label for the button to select an image
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// Error message when username is too short
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters long'**
  String get validationUsernameTooShort;

  /// Error message when username contains invalid characters
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers and underscores'**
  String get validationUsernameInvalid;

  /// Error message when an invalid price is entered
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price (e.g., 10.99)'**
  String get validationPriceInvalid;

  /// Text for Google sign in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Sign in button label
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Text for forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Text before sign up link
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAnAccount;

  /// Text for create account button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Text before sign in link
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// Error message when no account is found with the provided email
  ///
  /// In en, this message translates to:
  /// **'No account found with this email address.'**
  String get noAccountFoundWithEmail;

  /// Generic network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection and try again.'**
  String get networkError;

  /// Text for send reset link button
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Title shown after reset password email is sent
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get checkYourEmail;

  /// Message shown after reset password email is sent
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent you an email with instructions to reset your password. If you don\'t see it, check your spam folder.'**
  String get resetPasswordEmailSent;

  /// Text for back to sign in button
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// Title for product feed screen
  ///
  /// In en, this message translates to:
  /// **'Product Feed'**
  String get productFeed;

  /// Button label for refreshing content
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Error message when products fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading products'**
  String get errorLoadingProducts;

  /// Button label to retry loading content
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Title for product details screen
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// Message shown when a product has been deleted
  ///
  /// In en, this message translates to:
  /// **'This product is no longer available'**
  String get productNoLongerAvailable;

  /// Message shown when a product is not found
  ///
  /// In en, this message translates to:
  /// **'This product no longer exists'**
  String get productNoLongerExists;

  /// Error message when product loading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load product'**
  String get failedToLoadProduct;

  /// Title for unexpected error message
  ///
  /// In en, this message translates to:
  /// **'Unexpected Error'**
  String get unexpectedError;

  /// Label for description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Label for seller information section
  ///
  /// In en, this message translates to:
  /// **'Seller Information'**
  String get sellerInformation;

  /// Button label for starting a chat
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Title for edit profile screen
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Error message when profile fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// Error message when profile fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// Error message when products fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load products'**
  String get failedToLoadProducts;

  /// Message shown when item is added to cart
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// Button label to view cart
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// Error message when adding to cart fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add to cart'**
  String get failedToAddToCart;

  /// Error message when image picking fails
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get failedToPickImage;

  /// Success message when profile is updated
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// Error message when profile update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// Button label for changing profile photo
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// Label for username field
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Hint text for username field
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterYourUsername;

  /// Error message when username is already taken
  ///
  /// In en, this message translates to:
  /// **'Username already taken'**
  String get usernameAlreadyTaken;

  /// Error message when username is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get pleaseEnterUsername;

  /// Error message when username is too short
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMustBeAtLeast3Characters;

  /// Label for bio field
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// Hint text for bio field
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get tellUsAboutYourself;

  /// Button label for saving changes
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Error message when sign out fails
  ///
  /// In en, this message translates to:
  /// **'Error signing out'**
  String get errorSigningOut;

  /// Success message when a product is deleted
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleted;

  /// Error message when product deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product'**
  String get failedToDeleteProduct;

  /// Error message shown when deleting a product fails
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while deleting the product'**
  String get errorDeletingProduct;

  /// Title for delete product confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// Confirmation message shown before deleting a product
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product? This action cannot be undone.'**
  String get confirmDeleteProduct;

  /// Button to cancel an action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Error message when edit profile screen fails to open
  ///
  /// In en, this message translates to:
  /// **'Failed to open edit profile'**
  String get failedToOpenEditProfile;

  /// Title for current user's profile
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Tooltip for purchases button
  ///
  /// In en, this message translates to:
  /// **'My Purchases'**
  String get myPurchases;

  /// Tooltip for sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Message shown when no products are available
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// Title for the wishlist screen
  ///
  /// In en, this message translates to:
  /// **'My Wishlist'**
  String get myWishlist;

  /// Message shown when user is not signed in
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view your wishlist'**
  String get signInToViewWishlist;

  /// Message shown when wishlist is empty
  ///
  /// In en, this message translates to:
  /// **'No saved items yet'**
  String get wishlistEmpty;

  /// Button to continue shopping after upload
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// Add to cart button text
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// Message shown when an item is removed from wishlist
  ///
  /// In en, this message translates to:
  /// **'Removed from wishlist'**
  String get removedFromWishlist;

  /// Remove from wishlist button text
  ///
  /// In en, this message translates to:
  /// **'Remove from Wishlist'**
  String get removeFromWishlist;

  /// Button label for removing item
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Error message when wishlist fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load wishlist'**
  String get failedToLoadWishlist;

  /// Message shown when a product in wishlist is no longer available
  ///
  /// In en, this message translates to:
  /// **'Product no longer available'**
  String get productUnavailable;

  /// Title for the cart screen
  ///
  /// In en, this message translates to:
  /// **'Your Cart'**
  String get yourCart;

  /// Message shown when the cart is empty
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get yourCartIsEmpty;

  /// Label for total price
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Label for checkout button
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// Message shown after checkout simulation
  ///
  /// In en, this message translates to:
  /// **'Checkout simulation complete!'**
  String get checkoutSimulationComplete;

  /// Success message shown after deleting a product
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeletedSuccessfully;

  /// Generic error message when an unexpected error occurs
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unexpectedErrorTryAgain;

  /// Message shown when user needs to log in to make a purchase
  ///
  /// In en, this message translates to:
  /// **'Please log in to make a purchase'**
  String get pleaseLoginToPurchase;

  /// Message shown when user tries to purchase an already purchased item
  ///
  /// In en, this message translates to:
  /// **'You have already purchased this item!'**
  String get alreadyPurchasedItem;

  /// Message shown when a purchase is successful
  ///
  /// In en, this message translates to:
  /// **'Purchase successful!'**
  String get purchaseSuccessful;

  /// Prefix for purchase failure messages
  ///
  /// In en, this message translates to:
  /// **'Purchase failed'**
  String get purchaseFailed;

  /// Generic error prefix
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Message shown for unknown errors
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// Message shown when an unexpected error occurs
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedErrorOccurred;

  /// Buy now button text
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// Welcome message on the first onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Rivo'**
  String get welcomeToRivo;

  /// Description text on the first onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Discover amazing products and connect with sellers in your area'**
  String get onboardingWelcomeDescription;

  /// Title for the second onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Buy & Sell with Ease'**
  String get onboardingBuySellTitle;

  /// Description text for the second onboarding screen
  ///
  /// In en, this message translates to:
  /// **'List items for sale or find great deals near you'**
  String get onboardingBuySellDescription;

  /// Title for the third onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Safe & Secure'**
  String get onboardingSafeTitle;

  /// Description text for the third onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Chat with sellers and buyers in a secure environment'**
  String get onboardingSafeDescription;

  /// Button to skip the onboarding process
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Button to go to the next onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Button to finish onboarding and proceed to the app
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Text and link to sign in for existing users
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAnAccountSignIn;

  /// Welcome back message on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Subtitle on login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to Rivo'**
  String get signInToContinue;

  /// Label for email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Hint text for email field
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Label for password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Hint text for password field
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Divider text for login options
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// Error message for invalid login credentials
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please try again.'**
  String get invalidEmailOrPassword;

  /// Error message when email is not verified
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before signing in. Check your inbox for a verification link.'**
  String get verifyEmailBeforeSignIn;

  /// Error message for network issues
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection and try again.'**
  String get networkErrorTryAgain;

  /// Error message when no account is found
  ///
  /// In en, this message translates to:
  /// **'No account found with this email. Please sign up first.'**
  String get noAccountFoundSignUp;

  /// Error message when sign in is canceled
  ///
  /// In en, this message translates to:
  /// **'Sign in was canceled. Please try again.'**
  String get signInCanceled;

  /// Error message when Google sign in fails
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in with Google. Please try again.'**
  String get googleSignInFailed;

  /// Title for signup screen
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAnAccount;

  /// Subtitle for signup screen
  ///
  /// In en, this message translates to:
  /// **'Fill in your details to get started'**
  String get fillInYourDetails;

  /// Label for full name field
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Hint text for full name field
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// Hint text for username field
  ///
  /// In en, this message translates to:
  /// **'Choose a username'**
  String get chooseAUsername;

  /// Message shown when username is available
  ///
  /// In en, this message translates to:
  /// **'Username is available!'**
  String get usernameAvailable;

  /// Message shown when username is already taken
  ///
  /// In en, this message translates to:
  /// **'This username is already taken'**
  String get usernameTaken;

  /// Error message when checking username availability fails
  ///
  /// In en, this message translates to:
  /// **'Error checking username availability'**
  String get errorCheckingUsername;

  /// Hint text for password field
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get createAStrongPassword;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Hint text for search field
  ///
  /// In en, this message translates to:
  /// **'Search items, brands and categories'**
  String get searchHint;

  /// Sort button text
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Filter button text
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Follow button text
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// Following button text
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// Message shown when unfollowing a seller
  ///
  /// In en, this message translates to:
  /// **'You have unfollowed this seller'**
  String get unfollowedSeller;

  /// Message shown when following a seller
  ///
  /// In en, this message translates to:
  /// **'You are now following this seller'**
  String get followedSeller;

  /// Error message when there's no internet connection
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// Message shown when authentication is required
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue'**
  String get pleaseSignInToContinue;

  /// Tooltip for add to wishlist button
  ///
  /// In en, this message translates to:
  /// **'Add to wishlist'**
  String get addToWishlist;

  /// Message shown when an item is added to wishlist
  ///
  /// In en, this message translates to:
  /// **'Added to wishlist'**
  String get addedToWishlist;

  /// Button label for sharing
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Label for like button
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// Label for unlike button
  ///
  /// In en, this message translates to:
  /// **'Unlike'**
  String get unlike;

  /// Label for save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Label for unsave button
  ///
  /// In en, this message translates to:
  /// **'Unsave'**
  String get unsave;

  /// Label for user display name
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Title for add new product screen
  ///
  /// In en, this message translates to:
  /// **'Add New Product'**
  String get addNewProduct;

  /// Upload product button text
  ///
  /// In en, this message translates to:
  /// **'Upload Product'**
  String get uploadProduct;

  /// Label for title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Label for price field
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Error message when a required field is empty
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// Error message when price is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get invalidPrice;

  /// Error message when no image is selected
  ///
  /// In en, this message translates to:
  /// **'Please select an image'**
  String get imageRequired;

  /// Hint text for image upload
  ///
  /// In en, this message translates to:
  /// **'Tap to add an image'**
  String get tapToAddImage;

  /// Label for gallery option
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// Label for camera option
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Loading message during upload
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// Title for upload success message
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get uploadSuccessTitle;

  /// Message shown when product upload is successful
  ///
  /// In en, this message translates to:
  /// **'Your product has been uploaded successfully.'**
  String get uploadSuccessMessage;

  /// Button to view the uploaded product
  ///
  /// In en, this message translates to:
  /// **'View Product'**
  String get viewProduct;

  /// Title for upload error message
  ///
  /// In en, this message translates to:
  /// **'Upload Failed'**
  String get uploadErrorTitle;

  /// Error message when upload fails
  ///
  /// In en, this message translates to:
  /// **'Upload Failed'**
  String get uploadFailed;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// Label for post time
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get posted;

  /// Error message when failing to like a product
  ///
  /// In en, this message translates to:
  /// **'Failed to like product'**
  String get failedToLikeProduct;

  /// Error message when saving a product fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save product'**
  String get failedToSaveProduct;

  /// Relative time for just now
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Relative time for minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, one{1 minute ago} other{{minutes} minutes ago}}'**
  String minutesAgo(num minutes);

  /// Relative time for hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, one{1 hour ago} other{{hours} hours ago}}'**
  String hoursAgo(num hours);

  /// Relative time for days ago
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{1 day ago} other{{days} days ago}}'**
  String daysAgo(num days);

  /// Relative time for months ago
  ///
  /// In en, this message translates to:
  /// **'{months, plural, one{1 month ago} other{{months} months ago}}'**
  String monthsAgo(num months);

  /// Product ID display format
  ///
  /// In en, this message translates to:
  /// **'Product {productId}'**
  String productId(Object productId);

  /// Placeholder text for product details
  ///
  /// In en, this message translates to:
  /// **'Product details would appear here'**
  String get productDetailsPlaceholder;

  /// Add to cart button with status text
  ///
  /// In en, this message translates to:
  /// **'Add to Cart - {status}'**
  String addToCartWithStatus(Object status);

  /// Error message when adding to wishlist fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add to wishlist'**
  String get failedToAddToWishlist;

  /// Error message when removing from wishlist fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove from wishlist'**
  String get failedToRemoveFromWishlist;

  /// Label for confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Hint text for confirm password field
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reEnterYourPassword;

  /// Text before terms of service link
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our'**
  String get byCreatingAnAccount;

  /// Terms of service link text
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Conjunction between terms and privacy policy
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// Privacy policy link text
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Title for reset password screen
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Title for forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotYourPassword;

  /// Instructions for forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get enterYourEmailToResetPassword;

  /// Instructions shown after reset password email is sent
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent you an email with a link to reset your password. Please check your inbox and follow the instructions. If you don\'t see the email, check your spam folder.'**
  String get resetPasswordInstructions;

  /// Button text to go back to login screen
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// Button label to add first product when feed is empty
  ///
  /// In en, this message translates to:
  /// **'Add your first product'**
  String get addYourFirstProduct;

  /// Message shown when search is not yet implemented
  ///
  /// In en, this message translates to:
  /// **'Search functionality coming soon!'**
  String get searchComingSoon;

  /// Message shown when cart is empty
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartIsEmpty;

  /// Message shown when user needs to sign in to message
  ///
  /// In en, this message translates to:
  /// **'Please sign in to message'**
  String get signInToMessage;

  /// Message shown when starting a chat with a seller
  ///
  /// In en, this message translates to:
  /// **'Messaging seller about {product}'**
  String messagingSeller(String product);

  /// Title for the marketplace section
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// Label for product title field
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// Label for product description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// Label for product price field
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// Message shown when product upload fails
  ///
  /// In en, this message translates to:
  /// **'There was an error uploading your product. Please try again.'**
  String get uploadErrorMessage;

  /// Error message when title is empty
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// Error message when description is empty
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// Error message when price is empty
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get priceRequired;

  /// Hint text for title field
  ///
  /// In en, this message translates to:
  /// **'Enter product title'**
  String get enterTitle;

  /// Hint text for description field
  ///
  /// In en, this message translates to:
  /// **'Enter product description'**
  String get enterDescription;

  /// Hint text for price field
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// Success message after upload
  ///
  /// In en, this message translates to:
  /// **'Upload Successful!'**
  String get uploadSuccess;

  /// Button to retry failed operation
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Title for the purchase history screen
  ///
  /// In en, this message translates to:
  /// **'My Purchases'**
  String get purchaseHistoryTitle;

  /// Message shown when user has no purchase history
  ///
  /// In en, this message translates to:
  /// **'No purchases yet'**
  String get noPurchasesYet;

  /// Subtitle shown when there are no purchases
  ///
  /// In en, this message translates to:
  /// **'Your purchases will appear here'**
  String get purchasesWillAppearHere;

  /// Label showing purchase date
  ///
  /// In en, this message translates to:
  /// **'Purchased on: {date}'**
  String purchasedOn(Object date);

  /// Fallback text when product price is not available
  ///
  /// In en, this message translates to:
  /// **'Price not available'**
  String get priceNotAvailable;

  /// Message shown when product data is incomplete
  ///
  /// In en, this message translates to:
  /// **'Product information is missing'**
  String get productInfoMissing;

  /// Fallback text when product has no name
  ///
  /// In en, this message translates to:
  /// **'Unnamed Product'**
  String get unnamedProduct;

  /// Button text for reporting an issue
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// Message shown when an unexpected error occurs
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while loading your purchases.\\nPlease try again later.'**
  String get unexpectedErrorMessage;

  /// Error message when there's no internet connection
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your connection and try again.'**
  String get noInternetConnectionMessage;

  /// Error message when server request fails
  ///
  /// In en, this message translates to:
  /// **'Unable to load purchases. Please try again later.'**
  String get serverErrorMessage;

  /// Message shown when user needs to sign in
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view your purchase history'**
  String get signInToViewHistory;

  /// Button text to navigate to login screen
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLogin;

  /// Loading message for purchase history
  ///
  /// In en, this message translates to:
  /// **'Loading purchases...'**
  String get loadingPurchases;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'he': return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
