// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `hello`
  String get hello {
    return Intl.message('hello', name: 'hello', desc: '', args: []);
  }

  /// `Change Language`
  String get changeLanguage {
    return Intl.message(
      'Change Language',
      name: 'changeLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get arabic {
    return Intl.message('Arabic', name: 'arabic', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Log in`
  String get login {
    return Intl.message('Log in', name: 'login', desc: '', args: []);
  }

  /// `Welcome to the Itqan Learning Platform`
  String get welcomeInQB {
    return Intl.message(
      'Welcome to the Itqan Learning Platform',
      name: 'welcomeInQB',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Enter your email`
  String get enterEmail {
    return Intl.message(
      'Enter your email',
      name: 'enterEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email`
  String get pleaseEnterEmail {
    return Intl.message(
      'Please enter your email',
      name: 'pleaseEnterEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get pleaseEnterPassword {
    return Intl.message(
      'Please enter your password',
      name: 'pleaseEnterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Password `
  String get passwordFormFieldHint {
    return Intl.message(
      'Password ',
      name: 'passwordFormFieldHint',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters long`
  String get passwordShowHint {
    return Intl.message(
      'Password must be at least 6 characters long',
      name: 'passwordShowHint',
      desc: '',
      args: [],
    );
  }

  /// `WHATSAPP`
  String get whatsapp {
    return Intl.message('WHATSAPP', name: 'whatsapp', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Page being developed...`
  String get updatingPage {
    return Intl.message(
      'Page being developed...',
      name: 'updatingPage',
      desc: '',
      args: [],
    );
  }

  /// `More features coming soon 🔧`
  String get morePros {
    return Intl.message(
      'More features coming soon 🔧',
      name: 'morePros',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Profile`
  String get myAccount {
    return Intl.message('Profile', name: 'myAccount', desc: '', args: []);
  }

  /// `Tests`
  String get tests {
    return Intl.message('Tests', name: 'tests', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Services`
  String get delivery {
    return Intl.message('Services', name: 'delivery', desc: '', args: []);
  }

  /// `Courses`
  String get courses {
    return Intl.message('Courses', name: 'courses', desc: '', args: []);
  }

  /// `Exam Date Page`
  String get examDatePage {
    return Intl.message(
      'Exam Date Page',
      name: 'examDatePage',
      desc: '',
      args: [],
    );
  }

  /// `Services Page`
  String get ServicesPage {
    return Intl.message(
      'Services Page',
      name: 'ServicesPage',
      desc: '',
      args: [],
    );
  }

  /// `Educational courses`
  String get educationalCourses {
    return Intl.message(
      'Educational courses',
      name: 'educationalCourses',
      desc: '',
      args: [],
    );
  }

  /// `There are no courses currently available.`
  String get noAvailableCourses {
    return Intl.message(
      'There are no courses currently available.',
      name: 'noAvailableCourses',
      desc: '',
      args: [],
    );
  }

  /// `Course Details`
  String get courseDetails {
    return Intl.message(
      'Course Details',
      name: 'courseDetails',
      desc: '',
      args: [],
    );
  }

  /// `Start Learning Now`
  String get startLearning {
    return Intl.message(
      'Start Learning Now',
      name: 'startLearning',
      desc: '',
      args: [],
    );
  }

  /// `Educational video within this course`
  String get educationalCourse {
    return Intl.message(
      'Educational video within this course',
      name: 'educationalCourse',
      desc: '',
      args: [],
    );
  }

  /// `Watching the video`
  String get watchingVideo {
    return Intl.message(
      'Watching the video',
      name: 'watchingVideo',
      desc: '',
      args: [],
    );
  }

  /// `Discovering Courses`
  String get discoverCourses {
    return Intl.message(
      'Discovering Courses',
      name: 'discoverCourses',
      desc: '',
      args: [],
    );
  }

  /// `✨ Start your educational journey here`
  String get startYourTravel {
    return Intl.message(
      '✨ Start your educational journey here',
      name: 'startYourTravel',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load slider 😢`
  String get failLoading {
    return Intl.message(
      'Failed to load slider 😢',
      name: 'failLoading',
      desc: '',
      args: [],
    );
  }

  /// `Latest News`
  String get latestNews {
    return Intl.message('Latest News', name: 'latestNews', desc: '', args: []);
  }

  /// `Loading news...`
  String get loadingNews {
    return Intl.message(
      'Loading news...',
      name: 'loadingNews',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get title {
    return Intl.message('Notifications', name: 'title', desc: '', args: []);
  }

  /// `Coming Soon...  `
  String get message {
    return Intl.message(
      'Coming Soon...  ',
      name: 'message',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications_title {
    return Intl.message(
      'Notifications',
      name: 'notifications_title',
      desc: '',
      args: [],
    );
  }

  /// `Coming Soon...`
  String get coming_soon_message {
    return Intl.message(
      'Coming Soon...',
      name: 'coming_soon_message',
      desc: '',
      args: [],
    );
  }

  /// `Exams`
  String get examSchedule {
    return Intl.message('Exams', name: 'examSchedule', desc: '', args: []);
  }

  /// `Exam Date Page`
  String get examDatePagee {
    return Intl.message(
      'Exam Date Page',
      name: 'examDatePagee',
      desc: '',
      args: [],
    );
  }

  /// `Account Management`
  String get accountManagement {
    return Intl.message(
      'Account Management',
      name: 'accountManagement',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get deleteAccount {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Deleting your account is a permanent action.`
  String get deleteWarning {
    return Intl.message(
      'Deleting your account is a permanent action.',
      name: 'deleteWarning',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Deletion`
  String get confirmDelete {
    return Intl.message(
      'Confirm Deletion',
      name: 'confirmDelete',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account? This action cannot be undone.`
  String get deleteQuestion {
    return Intl.message(
      'Are you sure you want to delete your account? This action cannot be undone.',
      name: 'deleteQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Yes, delete`
  String get yesDelete {
    return Intl.message('Yes, delete', name: 'yesDelete', desc: '', args: []);
  }

  /// ` Account deleted successfully`
  String get deleteSuccess {
    return Intl.message(
      ' Account deleted successfully',
      name: 'deleteSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to delete account`
  String get deleteFailed {
    return Intl.message(
      'Failed to delete account',
      name: 'deleteFailed',
      desc: '',
      args: [],
    );
  }

  /// `Server connection error`
  String get serverError {
    return Intl.message(
      'Server connection error',
      name: 'serverError',
      desc: '',
      args: [],
    );
  }

  /// `Choose Image`
  String get chooseImageSource {
    return Intl.message(
      'Choose Image',
      name: 'chooseImageSource',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Image uploaded successfully`
  String get uploadSuccess {
    return Intl.message(
      'Image uploaded successfully',
      name: 'uploadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to upload image`
  String get uploadFailed {
    return Intl.message(
      'Failed to upload image',
      name: 'uploadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get firstName {
    return Intl.message('First Name', name: 'firstName', desc: '', args: []);
  }

  /// `Last Name`
  String get lastName {
    return Intl.message('Last Name', name: 'lastName', desc: '', args: []);
  }

  /// `Edit Name`
  String get editName {
    return Intl.message('Edit Name', name: 'editName', desc: '', args: []);
  }

  /// `Save Changes`
  String get saveChanges {
    return Intl.message(
      'Save Changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get newPassword {
    return Intl.message(
      'New Password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the new password`
  String get pleaseEnterNewPassword {
    return Intl.message(
      'Please enter the new password',
      name: 'pleaseEnterNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password changed successfully`
  String get passwordChangedSuccess {
    return Intl.message(
      'Password changed successfully',
      name: 'passwordChangedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to change the password`
  String get passwordChangedFailed {
    return Intl.message(
      'Failed to change the password',
      name: 'passwordChangedFailed',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Show Password`
  String get showPassword {
    return Intl.message(
      'Show Password',
      name: 'showPassword',
      desc: '',
      args: [],
    );
  }

  /// `Hide Password`
  String get hidePassword {
    return Intl.message(
      'Hide Password',
      name: 'hidePassword',
      desc: '',
      args: [],
    );
  }

  /// `updated successfully`
  String get updateSuccess {
    return Intl.message(
      'updated successfully',
      name: 'updateSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Update failed`
  String get updateFailed {
    return Intl.message(
      'Update failed',
      name: 'updateFailed',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get requiredField {
    return Intl.message(
      'This field is required',
      name: 'requiredField',
      desc: '',
      args: [],
    );
  }

  /// `newPassword`
  String get confirm_password {
    return Intl.message(
      'newPassword',
      name: 'confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Contact us`
  String get contactus {
    return Intl.message('Contact us', name: 'contactus', desc: '', args: []);
  }

  /// `Passwords do not match`
  String get password_mismatch {
    return Intl.message(
      'Passwords do not match',
      name: 'password_mismatch',
      desc: '',
      args: [],
    );
  }

  /// `Data loading failed`
  String get data_load_failed {
    return Intl.message(
      'Data loading failed',
      name: 'data_load_failed',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
  }

  /// `Website`
  String get website {
    return Intl.message('Website', name: 'website', desc: '', args: []);
  }

  /// `An error occurred. Please try again.`
  String get error {
    return Intl.message(
      'An error occurred. Please try again.',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signUp {
    return Intl.message('Sign Up', name: 'signUp', desc: '', args: []);
  }

  /// `Create New Account`
  String get createNewAccount {
    return Intl.message(
      'Create New Account',
      name: 'createNewAccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Google`
  String get signInWithGoogle {
    return Intl.message(
      'Sign in with Google',
      name: 'signInWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get alreadyHaveAccount {
    return Intl.message(
      'Already have an account?',
      name: 'alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Login Now`
  String get loginNow {
    return Intl.message('Login Now', name: 'loginNow', desc: '', args: []);
  }

  /// `Account Created Successfully! Welcome.`
  String get accountCreatedSuccess {
    return Intl.message(
      'Account Created Successfully! Welcome.',
      name: 'accountCreatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred.`
  String get unexpectedError {
    return Intl.message(
      'An unexpected error occurred.',
      name: 'unexpectedError',
      desc: '',
      args: [],
    );
  }

  /// `OR`
  String get or {
    return Intl.message('OR', name: 'or', desc: '', args: []);
  }

  /// `Create New Account`
  String get signupTitle {
    return Intl.message(
      'Create New Account',
      name: 'signupTitle',
      desc: '',
      args: [],
    );
  }

  /// `Active Exam Now`
  String get activeExamNow {
    return Intl.message(
      'Active Exam Now',
      name: 'activeExamNow',
      desc: '',
      args: [],
    );
  }

  /// `Start Exam`
  String get startExam {
    return Intl.message('Start Exam', name: 'startExam', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
