import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Ledger'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonAllProfiles.
  ///
  /// In en, this message translates to:
  /// **'All Profiles'**
  String get commonAllProfiles;

  /// No description provided for @commonProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get commonProfile;

  /// No description provided for @commonProfileLine.
  ///
  /// In en, this message translates to:
  /// **'Profile: {name}'**
  String commonProfileLine(Object name);

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonExportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get commonExportExcel;

  /// No description provided for @commonExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed.'**
  String get commonExportFailed;

  /// No description provided for @commonUnitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} units'**
  String commonUnitsCount(Object count);

  /// No description provided for @commonNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get commonNotes;

  /// No description provided for @commonDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get commonDate;

  /// No description provided for @commonProductNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Product name is required.'**
  String get commonProductNameRequired;

  /// No description provided for @commonValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price.'**
  String get commonValidPrice;

  /// No description provided for @commonValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity.'**
  String get commonValidQuantity;

  /// No description provided for @commonProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get commonProduct;

  /// No description provided for @commonQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get commonQuantity;

  /// No description provided for @commonUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get commonUnitPrice;

  /// No description provided for @commonTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @commonTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get commonTotalAmount;

  /// No description provided for @commonTotalAmountColon.
  ///
  /// In en, this message translates to:
  /// **'Total Amount:'**
  String get commonTotalAmountColon;

  /// No description provided for @commonAddAnotherProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Another Product'**
  String get commonAddAnotherProduct;

  /// No description provided for @navInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get navInventory;

  /// No description provided for @navSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get navSales;

  /// No description provided for @navPurchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get navPurchases;

  /// No description provided for @navFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get navFinance;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get navLogout;

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your session has timed out for security reasons. Please sign in again.'**
  String get sessionExpiredMessage;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account and start managing.'**
  String get loginWelcome;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'example@company.com'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get loginPasswordHint;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get loginForgotPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSubmit;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccount;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get loginCreateAccount;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email address is required.'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get loginPasswordRequired;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed.'**
  String get loginFailed;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Sales Ledger. Please enter your details.'**
  String get registerWelcome;

  /// No description provided for @registerCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get registerCompanyName;

  /// No description provided for @registerCompanyNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Acme Trading'**
  String get registerCompanyNameHint;

  /// No description provided for @registerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerSubmit;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHaveAccount;

  /// No description provided for @registerLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get registerLogin;

  /// No description provided for @registerCompanyNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Company name is required.'**
  String get registerCompanyNameRequired;

  /// No description provided for @registerPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get registerPasswordTooShort;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Account creation failed.'**
  String get registerFailed;

  /// No description provided for @profileSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Profile'**
  String get profileSelectionTitle;

  /// No description provided for @profileSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the profile you want to use to sign in to Sales Ledger.'**
  String get profileSelectionSubtitle;

  /// No description provided for @profileSelectionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Profiles could not be loaded.'**
  String get profileSelectionLoadFailed;

  /// No description provided for @profileSelectionAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New Profile'**
  String get profileSelectionAddNew;

  /// No description provided for @profileSelectionAddNewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a different account'**
  String get profileSelectionAddNewSubtitle;

  /// No description provided for @addProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Profile'**
  String get addProfileTitle;

  /// No description provided for @addProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile Name'**
  String get addProfileNameLabel;

  /// No description provided for @addProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Field Sales'**
  String get addProfileNameHint;

  /// No description provided for @addProfileRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role / Title'**
  String get addProfileRoleLabel;

  /// No description provided for @addProfileRoleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Regional Manager'**
  String get addProfileRoleHint;

  /// No description provided for @addProfileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Profile name is required.'**
  String get addProfileNameRequired;

  /// No description provided for @addProfileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile could not be saved.'**
  String get addProfileSaveFailed;

  /// No description provided for @inventoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Products could not be loaded.'**
  String get inventoryLoadFailed;

  /// No description provided for @inventoryNoExportData.
  ///
  /// In en, this message translates to:
  /// **'There is no data to export.'**
  String get inventoryNoExportData;

  /// No description provided for @inventoryExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Inventory exported: {path}'**
  String inventoryExportSuccess(Object path);

  /// No description provided for @inventorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by product name or description...'**
  String get inventorySearchHint;

  /// No description provided for @inventoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No products added yet.'**
  String get inventoryEmpty;

  /// No description provided for @inventoryAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New Product'**
  String get inventoryAddNew;

  /// No description provided for @inventoryFilterInStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inventoryFilterInStock;

  /// No description provided for @inventoryFilterOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get inventoryFilterOutOfStock;

  /// No description provided for @inventoryFilterFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get inventoryFilterFavorites;

  /// No description provided for @inventoryFavoriteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update favorite.'**
  String get inventoryFavoriteFailed;

  /// No description provided for @inventorySort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get inventorySort;

  /// No description provided for @inventorySortAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get inventorySortAlphabetical;

  /// No description provided for @inventorySortPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Price (High to Low)'**
  String get inventorySortPriceDesc;

  /// No description provided for @inventorySortPriceAsc.
  ///
  /// In en, this message translates to:
  /// **'Price (Low to High)'**
  String get inventorySortPriceAsc;

  /// No description provided for @inventorySortBestSelling.
  ///
  /// In en, this message translates to:
  /// **'Best Selling'**
  String get inventorySortBestSelling;

  /// No description provided for @inventoryOutOfStockBadge.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get inventoryOutOfStockBadge;

  /// No description provided for @addProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProductTitle;

  /// No description provided for @addProductBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information *'**
  String get addProductBasicInfo;

  /// No description provided for @addProductNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get addProductNameLabel;

  /// No description provided for @addProductNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Premium Leather Wallet'**
  String get addProductNameHint;

  /// No description provided for @addProductSalePrice.
  ///
  /// In en, this message translates to:
  /// **'Sale Price (₺)'**
  String get addProductSalePrice;

  /// No description provided for @addProductOptionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Details (Optional)'**
  String get addProductOptionalDetails;

  /// No description provided for @addProductCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addProductCategory;

  /// No description provided for @addProductCostPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost Price (₺)'**
  String get addProductCostPrice;

  /// No description provided for @addProductInitialStock.
  ///
  /// In en, this message translates to:
  /// **'Initial Stock Quantity'**
  String get addProductInitialStock;

  /// No description provided for @addProductWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get addProductWeight;

  /// No description provided for @addProductDimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions (L x W x H cm)'**
  String get addProductDimensions;

  /// No description provided for @addProductDimensionLength.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get addProductDimensionLength;

  /// No description provided for @addProductDimensionWidth.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get addProductDimensionWidth;

  /// No description provided for @addProductDimensionHeight.
  ///
  /// In en, this message translates to:
  /// **'H'**
  String get addProductDimensionHeight;

  /// No description provided for @addProductDescription.
  ///
  /// In en, this message translates to:
  /// **'Product Description'**
  String get addProductDescription;

  /// No description provided for @addProductDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Product details for customers...'**
  String get addProductDescriptionHint;

  /// No description provided for @addProductInternalNotes.
  ///
  /// In en, this message translates to:
  /// **'Internal Notes'**
  String get addProductInternalNotes;

  /// No description provided for @addProductInternalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes only you can see...'**
  String get addProductInternalNotesHint;

  /// No description provided for @addProductTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get addProductTags;

  /// No description provided for @addProductTagsHint.
  ///
  /// In en, this message translates to:
  /// **'Comma separated: leather, gift'**
  String get addProductTagsHint;

  /// No description provided for @addProductSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save Product'**
  String get addProductSubmit;

  /// No description provided for @addProductPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'You must add at least 1 photo.'**
  String get addProductPhotoRequired;

  /// No description provided for @addProductSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Product could not be saved.'**
  String get addProductSaveFailed;

  /// No description provided for @addProductPhotoCounter.
  ///
  /// In en, this message translates to:
  /// **'{current}/{max} photos (at least 1 required)'**
  String addProductPhotoCounter(Object current, Object max);

  /// No description provided for @addProductPhotoSizeExceeded.
  ///
  /// In en, this message translates to:
  /// **'Some photos were skipped because they exceed {maxMb} MB.'**
  String addProductPhotoSizeExceeded(Object maxMb);

  /// No description provided for @productDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetailsTitle;

  /// No description provided for @productDetailsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Product could not be loaded.'**
  String get productDetailsLoadFailed;

  /// No description provided for @productDetailsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get productDetailsDeleteTitle;

  /// No description provided for @productDetailsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product? This action cannot be undone.'**
  String get productDetailsDeleteMessage;

  /// No description provided for @productDetailsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Product could not be deleted.'**
  String get productDetailsDeleteFailed;

  /// No description provided for @productDetailsStockStatus.
  ///
  /// In en, this message translates to:
  /// **'Stock Status'**
  String get productDetailsStockStatus;

  /// No description provided for @productDetailsTotalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get productDetailsTotalSales;

  /// No description provided for @productDetailsCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get productDetailsCost;

  /// No description provided for @productDetailsMargin.
  ///
  /// In en, this message translates to:
  /// **'Profit Margin'**
  String get productDetailsMargin;

  /// No description provided for @productDetailsDimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions (L x W x H)'**
  String get productDetailsDimensions;

  /// No description provided for @productDetailsWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get productDetailsWeight;

  /// No description provided for @productDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDetailsDescription;

  /// No description provided for @productDetailsInternalNotes.
  ///
  /// In en, this message translates to:
  /// **'Internal Notes'**
  String get productDetailsInternalNotes;

  /// No description provided for @productDetailsRecentSales.
  ///
  /// In en, this message translates to:
  /// **'Recent Sales'**
  String get productDetailsRecentSales;

  /// No description provided for @productDetailsSalesHistoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Sales history could not be loaded.'**
  String get productDetailsSalesHistoryFailed;

  /// No description provided for @productDetailsNoSalesHistory.
  ///
  /// In en, this message translates to:
  /// **'No sales found for this product.'**
  String get productDetailsNoSalesHistory;

  /// No description provided for @productDetailsSaleHistoryLine.
  ///
  /// In en, this message translates to:
  /// **'{date} • {count} units'**
  String productDetailsSaleHistoryLine(Object date, Object count);

  /// No description provided for @purchasesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchases could not be loaded.'**
  String get purchasesLoadFailed;

  /// No description provided for @purchasesNoExportData.
  ///
  /// In en, this message translates to:
  /// **'There is no data to export.'**
  String get purchasesNoExportData;

  /// No description provided for @purchasesExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases exported: {path}'**
  String purchasesExportSuccess(Object path);

  /// No description provided for @purchasesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by supplier or description...'**
  String get purchasesSearchHint;

  /// No description provided for @purchasesFilterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get purchasesFilterCompleted;

  /// No description provided for @purchasesFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get purchasesFilterPending;

  /// No description provided for @purchasesFilterCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get purchasesFilterCanceled;

  /// No description provided for @purchasesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No purchases added yet.'**
  String get purchasesEmpty;

  /// No description provided for @purchasesAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New Purchase'**
  String get purchasesAddNew;

  /// No description provided for @purchaseCardItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String purchaseCardItemCount(Object count);

  /// No description provided for @addPurchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Purchase'**
  String get addPurchaseTitle;

  /// No description provided for @addPurchaseSupplierInfo.
  ///
  /// In en, this message translates to:
  /// **'Supplier Information'**
  String get addPurchaseSupplierInfo;

  /// No description provided for @addPurchaseSupplierName.
  ///
  /// In en, this message translates to:
  /// **'Supplier Name / Title'**
  String get addPurchaseSupplierName;

  /// No description provided for @addPurchaseSupplierHint.
  ///
  /// In en, this message translates to:
  /// **'Select or type a supplier'**
  String get addPurchaseSupplierHint;

  /// No description provided for @addPurchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get addPurchaseDate;

  /// No description provided for @addPurchaseProductDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get addPurchaseProductDetails;

  /// No description provided for @addPurchasePaymentAndNotes.
  ///
  /// In en, this message translates to:
  /// **'Payment and Notes'**
  String get addPurchasePaymentAndNotes;

  /// No description provided for @addPurchasePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get addPurchasePaymentMethod;

  /// No description provided for @addPurchaseNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Description / Note (Optional)'**
  String get addPurchaseNotesLabel;

  /// No description provided for @addPurchaseNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes about this purchase...'**
  String get addPurchaseNotesHint;

  /// No description provided for @addPurchaseSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save Purchase'**
  String get addPurchaseSubmit;

  /// No description provided for @addPurchaseProductHint.
  ///
  /// In en, this message translates to:
  /// **'Search a product or enter a new name'**
  String get addPurchaseProductHint;

  /// No description provided for @addPurchaseSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase could not be saved.'**
  String get addPurchaseSaveFailed;

  /// No description provided for @paymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentCash;

  /// No description provided for @paymentCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get paymentCard;

  /// No description provided for @paymentTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get paymentTransfer;

  /// No description provided for @purchaseDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase Details'**
  String get purchaseDetailsTitle;

  /// No description provided for @purchaseDetailsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase could not be loaded.'**
  String get purchaseDetailsLoadFailed;

  /// No description provided for @purchaseDetailsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Purchase'**
  String get purchaseDetailsDeleteTitle;

  /// No description provided for @purchaseDetailsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this purchase? This action cannot be undone.'**
  String get purchaseDetailsDeleteMessage;

  /// No description provided for @purchaseDetailsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase could not be deleted.'**
  String get purchaseDetailsDeleteFailed;

  /// No description provided for @purchaseDetailsSupplierInfo.
  ///
  /// In en, this message translates to:
  /// **'SUPPLIER INFORMATION'**
  String get purchaseDetailsSupplierInfo;

  /// No description provided for @purchaseDetailsTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT'**
  String get purchaseDetailsTotalAmount;

  /// No description provided for @purchaseDetailsPaymentType.
  ///
  /// In en, this message translates to:
  /// **'Payment Type'**
  String get purchaseDetailsPaymentType;

  /// No description provided for @purchaseDetailsItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchased Items'**
  String get purchaseDetailsItemsTitle;

  /// No description provided for @purchaseDetailsItemsFailed.
  ///
  /// In en, this message translates to:
  /// **'Items could not be loaded.'**
  String get purchaseDetailsItemsFailed;

  /// No description provided for @purchaseDetailsNotes.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION / NOTES'**
  String get purchaseDetailsNotes;

  /// No description provided for @purchaseDetailsNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items added to this purchase.'**
  String get purchaseDetailsNoItems;

  /// No description provided for @purchaseDetailsColumnProductName.
  ///
  /// In en, this message translates to:
  /// **'Product Code/Name'**
  String get purchaseDetailsColumnProductName;

  /// No description provided for @purchaseDetailsColumnUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get purchaseDetailsColumnUnitPrice;

  /// No description provided for @purchaseDetailsColumnTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get purchaseDetailsColumnTotal;

  /// No description provided for @salesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesTitle;

  /// No description provided for @salesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Sales could not be loaded.'**
  String get salesLoadFailed;

  /// No description provided for @salesNoExportData.
  ///
  /// In en, this message translates to:
  /// **'There is no data to export.'**
  String get salesNoExportData;

  /// No description provided for @salesExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sales exported: {path}'**
  String salesExportSuccess(Object path);

  /// No description provided for @salesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by platform or description...'**
  String get salesSearchHint;

  /// No description provided for @salesSortNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get salesSortNewestFirst;

  /// No description provided for @salesSortOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get salesSortOldestFirst;

  /// No description provided for @salesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sales added yet.'**
  String get salesEmpty;

  /// No description provided for @salesAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New Sale'**
  String get salesAddNew;

  /// No description provided for @saleCardItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} units'**
  String saleCardItemCount(Object count);

  /// No description provided for @addSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Sale'**
  String get addSaleTitle;

  /// No description provided for @addSaleCustomerInfo.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get addSaleCustomerInfo;

  /// No description provided for @addSaleCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name / Title'**
  String get addSaleCustomerName;

  /// No description provided for @addSaleOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get addSaleOrderDetails;

  /// No description provided for @addSalePlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get addSalePlatform;

  /// No description provided for @addSalePlatformHint.
  ///
  /// In en, this message translates to:
  /// **'Trendyol, Amazon...'**
  String get addSalePlatformHint;

  /// No description provided for @addSaleProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get addSaleProducts;

  /// No description provided for @addSaleLogisticsAndFinance.
  ///
  /// In en, this message translates to:
  /// **'Logistics and Finance'**
  String get addSaleLogisticsAndFinance;

  /// No description provided for @addSaleCargoStatus.
  ///
  /// In en, this message translates to:
  /// **'Shipping Status'**
  String get addSaleCargoStatus;

  /// No description provided for @addSaleStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get addSaleStatusPreparing;

  /// No description provided for @addSaleStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get addSaleStatusShipped;

  /// No description provided for @addSaleStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get addSaleStatusDelivered;

  /// No description provided for @addSaleTrackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Tracking Number (Optional)'**
  String get addSaleTrackingNumber;

  /// No description provided for @addSaleNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get addSaleNotesHint;

  /// No description provided for @addSaleSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save Sale'**
  String get addSaleSubmit;

  /// No description provided for @addSaleProductHint.
  ///
  /// In en, this message translates to:
  /// **'Search inventory or enter a new product'**
  String get addSaleProductHint;

  /// No description provided for @addSaleSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Sale could not be saved.'**
  String get addSaleSaveFailed;

  /// No description provided for @saleDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale Details'**
  String get saleDetailsTitle;

  /// No description provided for @saleDetailsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Sale could not be loaded.'**
  String get saleDetailsLoadFailed;

  /// No description provided for @saleDetailsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Sale'**
  String get saleDetailsDeleteTitle;

  /// No description provided for @saleDetailsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this sale? This action cannot be undone.'**
  String get saleDetailsDeleteMessage;

  /// No description provided for @saleDetailsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Sale could not be deleted.'**
  String get saleDetailsDeleteFailed;

  /// No description provided for @saleDetailsCustomer.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER'**
  String get saleDetailsCustomer;

  /// No description provided for @saleDetailsAmount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get saleDetailsAmount;

  /// No description provided for @saleDetailsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get saleDetailsStatus;

  /// No description provided for @saleDetailsTrackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Tracking No.'**
  String get saleDetailsTrackingNumber;

  /// No description provided for @saleDetailsItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get saleDetailsItemsTitle;

  /// No description provided for @saleDetailsItemsFailed.
  ///
  /// In en, this message translates to:
  /// **'Items could not be loaded.'**
  String get saleDetailsItemsFailed;

  /// No description provided for @saleDetailsNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items added to this sale.'**
  String get saleDetailsNoItems;

  /// No description provided for @saleDetailsQuantityLine.
  ///
  /// In en, this message translates to:
  /// **'Qty: {count}'**
  String saleDetailsQuantityLine(Object count);

  /// No description provided for @financeTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash Summary'**
  String get financeTitle;

  /// No description provided for @financeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Financial status and cash flow'**
  String get financeSubtitle;

  /// No description provided for @financeReportButton.
  ///
  /// In en, this message translates to:
  /// **'Get Report'**
  String get financeReportButton;

  /// No description provided for @financeSummaryFailed.
  ///
  /// In en, this message translates to:
  /// **'Cash summary could not be loaded.'**
  String get financeSummaryFailed;

  /// No description provided for @financeTotalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get financeTotalIncome;

  /// No description provided for @financeTotalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get financeTotalExpense;

  /// No description provided for @financeViewCashMovements.
  ///
  /// In en, this message translates to:
  /// **'View Cash Movements'**
  String get financeViewCashMovements;

  /// No description provided for @financeChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Income / Expense Analysis'**
  String get financeChartTitle;

  /// No description provided for @financeChartFailed.
  ///
  /// In en, this message translates to:
  /// **'Chart data could not be loaded.'**
  String get financeChartFailed;

  /// No description provided for @financeTopSelling.
  ///
  /// In en, this message translates to:
  /// **'Best Selling Products'**
  String get financeTopSelling;

  /// No description provided for @financeTopRevenue.
  ///
  /// In en, this message translates to:
  /// **'Highest Revenue Products'**
  String get financeTopRevenue;

  /// No description provided for @financeReportNotReady.
  ///
  /// In en, this message translates to:
  /// **'Data for the report is not ready yet.'**
  String get financeReportNotReady;

  /// No description provided for @financeReportExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cash report exported: {path}'**
  String financeReportExportSuccess(Object path);

  /// No description provided for @financeReportFailed.
  ///
  /// In en, this message translates to:
  /// **'Report could not be generated.'**
  String get financeReportFailed;

  /// No description provided for @financeNetProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get financeNetProfit;

  /// No description provided for @financeChangeVsPrevious.
  ///
  /// In en, this message translates to:
  /// **'{percent} vs previous period'**
  String financeChangeVsPrevious(Object percent);

  /// No description provided for @financeNoDataForChart.
  ///
  /// In en, this message translates to:
  /// **'No data.'**
  String get financeNoDataForChart;

  /// No description provided for @financeIncomeLegend.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get financeIncomeLegend;

  /// No description provided for @financeExpenseLegend.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get financeExpenseLegend;

  /// No description provided for @financeNoPeriodData.
  ///
  /// In en, this message translates to:
  /// **'No data for this period.'**
  String get financeNoPeriodData;

  /// No description provided for @financePeriodDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get financePeriodDaily;

  /// No description provided for @financePeriodWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get financePeriodWeekly;

  /// No description provided for @financePeriodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get financePeriodMonthly;

  /// No description provided for @financePeriodYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get financePeriodYearly;

  /// No description provided for @cashFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash Movements'**
  String get cashFlowTitle;

  /// No description provided for @cashFlowMovementType.
  ///
  /// In en, this message translates to:
  /// **'Movement Type'**
  String get cashFlowMovementType;

  /// No description provided for @cashFlowIncomeFilter.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get cashFlowIncomeFilter;

  /// No description provided for @cashFlowExpenseFilter.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get cashFlowExpenseFilter;

  /// No description provided for @cashFlowPickDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get cashFlowPickDateRange;

  /// No description provided for @cashFlowClearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get cashFlowClearFilter;

  /// No description provided for @cashFlowTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get cashFlowTotalBalance;

  /// No description provided for @cashFlowMonthIncome.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Income'**
  String get cashFlowMonthIncome;

  /// No description provided for @cashFlowMonthExpense.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Expenses'**
  String get cashFlowMonthExpense;

  /// No description provided for @cashFlowRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get cashFlowRecentTransactions;

  /// No description provided for @cashFlowLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Cash movements could not be loaded.'**
  String get cashFlowLoadFailed;

  /// No description provided for @cashFlowEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cash movements found for this filter.'**
  String get cashFlowEmpty;

  /// No description provided for @cargoStatusPackaging.
  ///
  /// In en, this message translates to:
  /// **'Packaging'**
  String get cargoStatusPackaging;

  /// No description provided for @cargoStatusDelayed.
  ///
  /// In en, this message translates to:
  /// **'Delayed Shipping'**
  String get cargoStatusDelayed;

  /// No description provided for @cargoStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get cargoStatusShipped;

  /// No description provided for @cargoStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sale Completed'**
  String get cargoStatusCompleted;

  /// No description provided for @cargoStatusCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get cargoStatusCanceled;

  /// No description provided for @purchaseStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get purchaseStatusCompleted;

  /// No description provided for @purchaseStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get purchaseStatusPending;

  /// No description provided for @purchaseStatusCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get purchaseStatusCanceled;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
