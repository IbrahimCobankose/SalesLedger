// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sales Ledger';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDismiss => 'Dismiss';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSave => 'Save';

  @override
  String get commonAll => 'All';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonExportExcel => 'Export to Excel';

  @override
  String get commonExportFailed => 'Export failed.';

  @override
  String commonUnitsCount(Object count) {
    return '$count units';
  }

  @override
  String get commonNotes => 'Notes';

  @override
  String get commonDate => 'Date';

  @override
  String get commonProductNameRequired => 'Product name is required.';

  @override
  String get commonValidPrice => 'Enter a valid price.';

  @override
  String get commonValidQuantity => 'Enter a valid quantity.';

  @override
  String get commonProduct => 'Product';

  @override
  String get commonQuantity => 'Quantity';

  @override
  String get commonUnitPrice => 'Unit Price';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonTotalAmount => 'Total Amount';

  @override
  String get commonTotalAmountColon => 'Total Amount:';

  @override
  String get commonAddAnotherProduct => 'Add Another Product';

  @override
  String get navInventory => 'Inventory';

  @override
  String get navSales => 'Sales';

  @override
  String get navPurchases => 'Purchases';

  @override
  String get navFinance => 'Finance';

  @override
  String get navProfile => 'My Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get navReports => 'Reports';

  @override
  String get navLogout => 'Log Out';

  @override
  String get sessionExpiredMessage =>
      'Your session has timed out for security reasons. Please sign in again.';

  @override
  String get loginWelcome => 'Sign in to your account and start managing.';

  @override
  String get loginEmailLabel => 'Email Address';

  @override
  String get loginEmailHint => 'example@company.com';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginForgotPassword => 'Forgot Password';

  @override
  String get loginSubmit => 'Sign In';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginCreateAccount => 'Create Account';

  @override
  String get loginEmailRequired => 'Email address is required.';

  @override
  String get loginEmailInvalid => 'Enter a valid email address.';

  @override
  String get loginPasswordRequired => 'Password is required.';

  @override
  String get loginFailed => 'Sign in failed.';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerWelcome =>
      'Welcome to Sales Ledger. Please enter your details.';

  @override
  String get registerCompanyName => 'Company Name';

  @override
  String get registerCompanyNameHint => 'e.g. Acme Trading';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerSubmit => 'Sign Up';

  @override
  String get registerHaveAccount => 'Already have an account? ';

  @override
  String get registerLogin => 'Sign In';

  @override
  String get registerCompanyNameRequired => 'Company name is required.';

  @override
  String get registerPasswordTooShort =>
      'Password must be at least 6 characters.';

  @override
  String get registerFailed => 'Account creation failed.';

  @override
  String get profileSelectionTitle => 'Select Profile';

  @override
  String get profileSelectionSubtitle =>
      'Choose the profile you want to use to sign in to Sales Ledger.';

  @override
  String get profileSelectionLoadFailed => 'Profiles could not be loaded.';

  @override
  String get profileSelectionAddNew => 'Add New Profile';

  @override
  String get profileSelectionAddNewSubtitle =>
      'Sign in with a different account';

  @override
  String get addProfileTitle => 'Add Profile';

  @override
  String get addProfileNameLabel => 'Profile Name';

  @override
  String get addProfileNameHint => 'e.g. Field Sales';

  @override
  String get addProfileRoleLabel => 'Role / Title';

  @override
  String get addProfileRoleHint => 'e.g. Regional Manager';

  @override
  String get addProfileNameRequired => 'Profile name is required.';

  @override
  String get addProfileSaveFailed => 'Profile could not be saved.';

  @override
  String get inventoryLoadFailed => 'Products could not be loaded.';

  @override
  String get inventoryNoExportData => 'There is no data to export.';

  @override
  String inventoryExportSuccess(Object path) {
    return 'Inventory exported: $path';
  }

  @override
  String get inventorySearchHint => 'Search by product name or description...';

  @override
  String get inventoryEmpty => 'No products added yet.';

  @override
  String get inventoryAddNew => 'Add New Product';

  @override
  String get inventoryFilterInStock => 'In Stock';

  @override
  String get inventoryFilterOutOfStock => 'Out of Stock';

  @override
  String get inventoryFilterFavorites => 'Favorites';

  @override
  String get inventorySort => 'Sort';

  @override
  String get inventorySortAlphabetical => 'Alphabetical';

  @override
  String get inventorySortPriceDesc => 'Price (High to Low)';

  @override
  String get inventorySortPriceAsc => 'Price (Low to High)';

  @override
  String get inventorySortBestSelling => 'Best Selling';

  @override
  String get inventoryOutOfStockBadge => 'Out of Stock';

  @override
  String get addProductTitle => 'Add Product';

  @override
  String get addProductBasicInfo => 'Basic Information *';

  @override
  String get addProductNameLabel => 'Product Name';

  @override
  String get addProductNameHint => 'e.g. Premium Leather Wallet';

  @override
  String get addProductSalePrice => 'Sale Price (₺)';

  @override
  String get addProductOptionalDetails => 'Details (Optional)';

  @override
  String get addProductCategory => 'Category';

  @override
  String get addProductCostPrice => 'Cost Price (₺)';

  @override
  String get addProductInitialStock => 'Initial Stock Quantity';

  @override
  String get addProductWeight => 'Weight (kg)';

  @override
  String get addProductDimensions => 'Dimensions (L x W x H cm)';

  @override
  String get addProductDimensionLength => 'L';

  @override
  String get addProductDimensionWidth => 'W';

  @override
  String get addProductDimensionHeight => 'H';

  @override
  String get addProductDescription => 'Product Description';

  @override
  String get addProductDescriptionHint => 'Product details for customers...';

  @override
  String get addProductInternalNotes => 'Internal Notes';

  @override
  String get addProductInternalNotesHint => 'Notes only you can see...';

  @override
  String get addProductTags => 'Tags';

  @override
  String get addProductTagsHint => 'Comma separated: leather, gift';

  @override
  String get addProductSubmit => 'Save Product';

  @override
  String get addProductPhotoRequired => 'You must add at least 1 photo.';

  @override
  String get addProductSaveFailed => 'Product could not be saved.';

  @override
  String addProductPhotoCounter(Object current, Object max) {
    return '$current/$max photos (at least 1 required)';
  }

  @override
  String addProductPhotoSizeExceeded(Object maxMb) {
    return 'Some photos were skipped because they exceed $maxMb MB.';
  }

  @override
  String get productDetailsTitle => 'Product Details';

  @override
  String get productDetailsLoadFailed => 'Product could not be loaded.';

  @override
  String get productDetailsDeleteTitle => 'Delete Product';

  @override
  String get productDetailsDeleteMessage =>
      'Are you sure you want to delete this product? This action cannot be undone.';

  @override
  String get productDetailsDeleteFailed => 'Product could not be deleted.';

  @override
  String get productDetailsStockStatus => 'Stock Status';

  @override
  String get productDetailsTotalSales => 'Total Sales';

  @override
  String get productDetailsCost => 'Cost';

  @override
  String get productDetailsMargin => 'Profit Margin';

  @override
  String get productDetailsDimensions => 'Dimensions (L x W x H)';

  @override
  String get productDetailsWeight => 'Weight';

  @override
  String get productDetailsDescription => 'Description';

  @override
  String get productDetailsInternalNotes => 'Internal Notes';

  @override
  String get productDetailsRecentSales => 'Recent Sales';

  @override
  String get productDetailsSalesHistoryFailed =>
      'Sales history could not be loaded.';

  @override
  String get productDetailsNoSalesHistory => 'No sales found for this product.';

  @override
  String productDetailsSaleHistoryLine(Object date, Object count) {
    return '$date • $count units';
  }

  @override
  String get purchasesLoadFailed => 'Purchases could not be loaded.';

  @override
  String get purchasesNoExportData => 'There is no data to export.';

  @override
  String purchasesExportSuccess(Object path) {
    return 'Purchases exported: $path';
  }

  @override
  String get purchasesSearchHint => 'Search by supplier or description...';

  @override
  String get purchasesFilterCompleted => 'Completed';

  @override
  String get purchasesFilterPending => 'Pending';

  @override
  String get purchasesFilterCanceled => 'Canceled';

  @override
  String get purchasesEmpty => 'No purchases added yet.';

  @override
  String get purchasesAddNew => 'Add New Purchase';

  @override
  String purchaseCardItemCount(Object count) {
    return '$count Items';
  }

  @override
  String get addPurchaseTitle => 'Add Purchase';

  @override
  String get addPurchaseSupplierInfo => 'Supplier Information';

  @override
  String get addPurchaseSupplierName => 'Supplier Name / Title';

  @override
  String get addPurchaseSupplierHint => 'Select or type a supplier';

  @override
  String get addPurchaseDate => 'Purchase Date';

  @override
  String get addPurchaseProductDetails => 'Product Details';

  @override
  String get addPurchasePaymentAndNotes => 'Payment and Notes';

  @override
  String get addPurchasePaymentMethod => 'Payment Method';

  @override
  String get addPurchaseNotesLabel => 'Description / Note (Optional)';

  @override
  String get addPurchaseNotesHint => 'Notes about this purchase...';

  @override
  String get addPurchaseSubmit => 'Save Purchase';

  @override
  String get addPurchaseProductHint => 'Search a product or enter a new name';

  @override
  String get addPurchaseSaveFailed => 'Purchase could not be saved.';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentCard => 'Credit Card';

  @override
  String get paymentTransfer => 'Bank Transfer';

  @override
  String get purchaseDetailsTitle => 'Purchase Details';

  @override
  String get purchaseDetailsLoadFailed => 'Purchase could not be loaded.';

  @override
  String get purchaseDetailsDeleteTitle => 'Delete Purchase';

  @override
  String get purchaseDetailsDeleteMessage =>
      'Are you sure you want to delete this purchase? This action cannot be undone.';

  @override
  String get purchaseDetailsDeleteFailed => 'Purchase could not be deleted.';

  @override
  String get purchaseDetailsSupplierInfo => 'SUPPLIER INFORMATION';

  @override
  String get purchaseDetailsTotalAmount => 'TOTAL AMOUNT';

  @override
  String get purchaseDetailsPaymentType => 'Payment Type';

  @override
  String get purchaseDetailsItemsTitle => 'Purchased Items';

  @override
  String get purchaseDetailsItemsFailed => 'Items could not be loaded.';

  @override
  String get purchaseDetailsNotes => 'DESCRIPTION / NOTES';

  @override
  String get purchaseDetailsNoItems => 'No items added to this purchase.';

  @override
  String get purchaseDetailsColumnProductName => 'Product Code/Name';

  @override
  String get purchaseDetailsColumnUnitPrice => 'Unit Price';

  @override
  String get purchaseDetailsColumnTotal => 'Total';

  @override
  String get salesTitle => 'Sales';

  @override
  String get salesLoadFailed => 'Sales could not be loaded.';

  @override
  String get salesNoExportData => 'There is no data to export.';

  @override
  String salesExportSuccess(Object path) {
    return 'Sales exported: $path';
  }

  @override
  String get salesSearchHint => 'Search by platform or description...';

  @override
  String get salesSortNewestFirst => 'Newest First';

  @override
  String get salesSortOldestFirst => 'Oldest First';

  @override
  String get salesEmpty => 'No sales added yet.';

  @override
  String get salesAddNew => 'Add New Sale';

  @override
  String saleCardItemCount(Object count) {
    return '$count units';
  }

  @override
  String get addSaleTitle => 'Add Sale';

  @override
  String get addSaleCustomerInfo => 'Customer Information';

  @override
  String get addSaleCustomerName => 'Customer Name / Title';

  @override
  String get addSaleOrderDetails => 'Order Details';

  @override
  String get addSalePlatform => 'Platform';

  @override
  String get addSalePlatformHint => 'Trendyol, Amazon...';

  @override
  String get addSaleProducts => 'Products';

  @override
  String get addSaleLogisticsAndFinance => 'Logistics and Finance';

  @override
  String get addSaleCargoStatus => 'Shipping Status';

  @override
  String get addSaleStatusPreparing => 'Preparing';

  @override
  String get addSaleStatusShipped => 'Shipped';

  @override
  String get addSaleStatusDelivered => 'Delivered';

  @override
  String get addSaleTrackingNumber => 'Tracking Number (Optional)';

  @override
  String get addSaleNotesHint => 'Notes (Optional)';

  @override
  String get addSaleSubmit => 'Save Sale';

  @override
  String get addSaleProductHint => 'Search inventory or enter a new product';

  @override
  String get addSaleSaveFailed => 'Sale could not be saved.';

  @override
  String get saleDetailsTitle => 'Sale Details';

  @override
  String get saleDetailsLoadFailed => 'Sale could not be loaded.';

  @override
  String get saleDetailsDeleteTitle => 'Delete Sale';

  @override
  String get saleDetailsDeleteMessage =>
      'Are you sure you want to delete this sale? This action cannot be undone.';

  @override
  String get saleDetailsDeleteFailed => 'Sale could not be deleted.';

  @override
  String get saleDetailsCustomer => 'CUSTOMER';

  @override
  String get saleDetailsAmount => 'AMOUNT';

  @override
  String get saleDetailsStatus => 'Status';

  @override
  String get saleDetailsTrackingNumber => 'Tracking No.';

  @override
  String get saleDetailsItemsTitle => 'Products';

  @override
  String get saleDetailsItemsFailed => 'Items could not be loaded.';

  @override
  String get saleDetailsNoItems => 'No items added to this sale.';

  @override
  String saleDetailsQuantityLine(Object count) {
    return 'Qty: $count';
  }

  @override
  String get financeTitle => 'Cash Summary';

  @override
  String get financeSubtitle => 'Financial status and cash flow';

  @override
  String get financeReportButton => 'Get Report';

  @override
  String get financeSummaryFailed => 'Cash summary could not be loaded.';

  @override
  String get financeTotalIncome => 'Total Income';

  @override
  String get financeTotalExpense => 'Total Expense';

  @override
  String get financeViewCashMovements => 'View Cash Movements';

  @override
  String get financeChartTitle => 'Income / Expense Analysis';

  @override
  String get financeChartFailed => 'Chart data could not be loaded.';

  @override
  String get financeTopSelling => 'Best Selling Products';

  @override
  String get financeTopRevenue => 'Highest Revenue Products';

  @override
  String get financeReportNotReady => 'Data for the report is not ready yet.';

  @override
  String financeReportExportSuccess(Object path) {
    return 'Cash report exported: $path';
  }

  @override
  String get financeReportFailed => 'Report could not be generated.';

  @override
  String get financeNetProfit => 'Net Profit';

  @override
  String financeChangeVsPrevious(Object percent) {
    return '$percent vs previous period';
  }

  @override
  String get financeNoDataForChart => 'No data.';

  @override
  String get financeIncomeLegend => 'Income';

  @override
  String get financeExpenseLegend => 'Expense';

  @override
  String get financeNoPeriodData => 'No data for this period.';

  @override
  String get financePeriodDaily => 'Daily';

  @override
  String get financePeriodWeekly => 'Weekly';

  @override
  String get financePeriodMonthly => 'Monthly';

  @override
  String get financePeriodYearly => 'Yearly';

  @override
  String get cashFlowTitle => 'Cash Movements';

  @override
  String get cashFlowMovementType => 'Movement Type';

  @override
  String get cashFlowIncomeFilter => 'Income';

  @override
  String get cashFlowExpenseFilter => 'Expense';

  @override
  String get cashFlowPickDateRange => 'Select Date Range';

  @override
  String get cashFlowClearFilter => 'Clear Filter';

  @override
  String get cashFlowTotalBalance => 'Total Balance';

  @override
  String get cashFlowMonthIncome => 'This Month\'s Income';

  @override
  String get cashFlowMonthExpense => 'This Month\'s Expenses';

  @override
  String get cashFlowRecentTransactions => 'Recent Transactions';

  @override
  String get cashFlowLoadFailed => 'Cash movements could not be loaded.';

  @override
  String get cashFlowEmpty => 'No cash movements found for this filter.';

  @override
  String get cargoStatusPackaging => 'Packaging';

  @override
  String get cargoStatusDelayed => 'Delayed Shipping';

  @override
  String get cargoStatusShipped => 'Shipped';

  @override
  String get cargoStatusCompleted => 'Sale Completed';

  @override
  String get cargoStatusCanceled => 'Canceled';

  @override
  String get purchaseStatusCompleted => 'Completed';

  @override
  String get purchaseStatusPending => 'Pending';

  @override
  String get purchaseStatusCanceled => 'Canceled';
}
