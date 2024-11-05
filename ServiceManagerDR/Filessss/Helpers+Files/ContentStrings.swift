//
// ContentStrings.swift
//

import Foundation

let iPad = UIDevice.current.userInterfaceIdiom == .pad

extension LocalizationKey{
    var localizedString: String {
        return NSLocalizedString(rawValue, comment: "")
    }
}

extension String {
    init(with localizationKey: LocalizationKey) {
        self = NSLocalizedString(localizationKey.rawValue, tableName: nil, bundle: Bundle.localizedBundle() ?? Bundle.main, value: "", comment: "")
    }
}

enum LocalizationKey: String, CaseIterable {
    case apply = "Apply"
    case changeLanguage = "Change Language"
    case english = "English"
    case spanish = "Spanish"
    case french  = "French"
    case iAgreeTo = "I agree to %@"
    case terms =  "Terms of Use"
    
    //MARK: - StartCV
    case plan = "PLAN\nYOUR LEGACY\nA MOMENT IN TIME\nFOR WHEN FEELING\nTHE LOSS OF OUR\nLOVED ONE"
    case another = "ANOTHER\nONBOARDING\nMESSAGE GOES\nIN THIS SECTION"
    case final = "FINAL\nONBOARDING\nMESSAGE GOES\nIN THIS SECTION"
    
    case startupCap = "START SETUP"
    case nextCap = "NEXT"
    
    // Section Titles
//    case contactsTitle = "CONTACTS"
//    case contactsSubtitle = "GROUPS AND LISTS"
    case contactsTFTitle = "Name this New List and add contacts"
    case contactsPlaceholder = "Enter Contact List Name"
    
    case memoryVaultTitle = "MEMORY VAULT"
    case memoryVaultVideoSubtitle = "UPLOAD VIDEO FILES"
    case memoryVaultAudioSubtitle = "UPLOAD AUDIO FILES"
    case memoryVaultImagesSubtitle = "UPLOAD IMAGE FILES"
    case memoryAddressFiles = "Address your files to a specific List"
    case memoryVaultPlaceholder = "Select Contact List"
    
    case messageStacksTitle = "MESSAGE STACKS"
    case messageStacksSubtitle = "Address your Messages to a specific List"
    
    case trustedPeopleTitle = "MAIN CONTACTS"
    case trustedPeopleSubtitle = "TRUSTED PEOPLE"
    
    case changeLanguages = "Languages"
    case darkMode = "Dark Mode"
//
    case title_Continue = "Continue"
    
    // Signup
    case emailUserName = "Email/Username"
    case emailUsernamePlaceholder = "Enter Email/Username"
    case emailPlaceholder = "Enter Email"
    case password = "Password"
    case passwordPlaceholder = "Enter Password"
    case confirmpasswordPlaceholder = "Enter Confirm Password"
    case usernamePlaceholder = "Enter Username"
    case fullnamePlaceholder = "Enter Full Name"
    case dontHaveAccount = "Don’t have an account?"
    case alreadyHaveAccount = "Already have an account?"
    case createPropertyListing = "Create Property Listing"
    case create = "Create"
    case update = "Update"
    case submit = "Submit"
//    case title = "Title"
//    case titleHere = "Title here"
//    case description = "Description"
    case descriptionHere = "Description here"
    case schoolInformation = "School Information"
    case enterSchoolInformation = "Enter School Information"
    case register = "Register"
    case login = "Login"
    case or = "or"
    case welcome = "WELCOME"
    case Main_User_ACCESS = "MAIN USER ACCESS"
    
    case recoverPassword = "Recover Password"
    
    // Profile Screen
    case editProfile = "Edit Profile"
    case enterPhNo = "Enter Your Phone Number"
    
    case personalInfo = "Personal Info"
    case name = "Name"
    case userName = "Username"
    case fullName = "Full Name"
    case optionalDetails = "Optiofnal Details"
    case webSite = "Website"
    case phoneNo = "Phone No."
    case saveChanges = "Save Changes"
    
    case accept = "Accept"
    case reject = "Reject"
    
    // Additional Texts
    case subscriptions = "Subscriptions"
    case alertYes = "Yes"
    case alertNo = "No"
    case alertOK = "OK"
    case alertCancel = "Cancel"
    case save = "Save"
    case settings = "Settings"
    
    case forgotPassword = "Forgot Password"
    case forgotpassword = "Forgot Password?"
    case FORGOTPASSWORD = "FORGOT PASSWORD"
    case profile = "Profile"
    case security = "Security"
    case payments = "Payments"
    case email = "Email"
    case phoneNumber = "Phone Number"
    case changePassword = "Change Password"
    case CHANGE_PASSWORD = "CHANGE PASSWORD"
    case notificationsOnOff = "Notifications ON/OFF"
    case notification = "Notifications"
    case messages = "Messages"
    case favourites = "Favorites"
    case blockList = "Block List"
    case subscribe = "Subscribe"
    case rate_Us = "Rate Us"
    case help = "Help"
    case about_Us = "About Us"
    case chat_Settings = "Chat Settings"
    case cardList = "Card"
    case invitefriend = "Invite Friend"
    case balance = "Balance"
    case pin_Code = "PIN Code"
    case faceIDLogin = "Face ID Login"
    case changeRole = "Change Role"
    case privacyPolicy = "Privacy Policy"
    case comingSoon = "This functionality is coming soon."
    case somethingWentWrong = "Something went wrong!"
    case session = "Session Expired"
    case internetMessage = "Please check your internet connection and try again."
    case log_in =  "Log in"
    case SignupTitle = "Signup"
    case passwordLength = "Password must be at least 8 characters."
    case termsSelected = "Before you can proceed you must read and accept the Terms & Conditions."
    case alertAllFieldsRequired = "All fields are required."
    case alertEnterEmail_Username = "Please enter your email/username."
    case alertEnterEmail = "Please enter your email."
    case alertEnterMessage = "Please enter your message."
    case alertEnterListName = "Please enter contact list name."
    case alertValidEmail = "Please enter valid email."
    case emptyContacts = "Please select at least one contact."
    case emptyContactList = "Please create at least one contact list to proceed."
    case alertEnterPassword = "Please enter your password."
    case alertEnterValidPassword = "Password should be atleast 8 characters including upper and lower case letters, a number and a special character - #,!"
    case alertEnterValidNewPassword = "New password should be atleast 8 characters including upper and lower case letters, a number and a special character - #,!"
    case alertConfPass = "Please confirm your password."
    case alertEnterFirstName = "Please enter your first name."
    case alertEnterLastName = "Please enter your last name."
    case alertEnterFullName = "Please enter your full name."
    case alertEnterName = "Please enter your name."
    case alertEnterUserName = "Please enter your username."
    case alertEnterPhoneNumber = "Please enter phone number."
    case alertEnterWebsite = "The web address you entered seems incorrect. Please verify it starts with http:// or https://."
    case alertValidPhoneNumber = "Please enter 7-15 digit phone number."
    case alertChooseCountryCode = "Please select country code."
    case alertConfirmPasswordNotMatch = "New & confirm password must be same."
    case alertConfirmPassNotMatch = "Password & confirm password must be same."
    case alertTermsOfUse = "Please accept terms of use first."
    case phoneNotAvaialable = "The phone number is currently unavailable."
    case SelectUser = "Please select user for assign admin role."
    case alertCurrentPass = "Please enter your current password."
    case alertNewPass = "Please enter your new password."
    case alertNewConfPass = "Please confirm your new password."
    case alertTimeout = "Timeout please resend verification code."
    case logout =  "Logout"
    case logoutPermission =  "Are you sure you want to logout?"
    
    case deleteAccount =  "Delete Account"
    case deleteAccountPermission =  "If you proceed, you will lose your all personal data. Are you sure you want to delete your account?"
    case enterLocationStatic = "Please enter a location."
    case deleteChat = "Are you sure you want to delete this chat?"
    case installLatestVersion = "A new version of the app is available. Would you like to update now?"
    case noNotification =  "Your notification list is currently empty. There are no new notifications to display at this time."
    case viewOffer = "View Offers"
    case askForNotificationPermission = "To begin receiving notifications, kindly grant or adjust your notification settings accordingly."
    case property_title = "Please enter title."
    case property_description = "Please enter description."
    case property_type = "Please select property type."
    case property_price = "Please enter property price."
    case property_rentprice = "Please enter rent price type."
    case property_size = "Please enter property size."
    case property_bedroom = "Please enter number of bedrooms."
    case property_bathroom = "Please enter number of bathrooms."
    case property_furnish = "Please select furnishing."
    case property_facilities = "Please select facilities."
    case property_discount = "Please enter discount title."
    case property_discountDescription = "Please enter discount description."
    case property_location = "Please enter property location."
    case property_photos = "Please enter property photos."
    
    case currentPassword = "Current Password"
    case newPassword = "New Password"
    case confirmPassword = "Confirm Password"
    
    case enterCurrentPassword = "Enter Current Password"
    case enterNewPassword = "Enter New Password"
    
    
    
    //MARK: Subscriptions
    case subscriptionDesc = "By subscribing to this app, you will be charged via your iTunes account, and your subscription will automatically renew each month for the same amount unless you cancel it in your iTunes Store settings at least 24 hours before the current period ends.\n\n"
    case subscriptionText = "By subscribing to this app, you will be charged via your iTunes account, and your subscription will automatically renew each month for the same amount unless you cancel it in your iTunes Store settings at least 24 hours before the current period ends. This subscription will give you complete access to the app. By subscribing, you agree to our %@ and %@."
    case termsAndPrivacy = "By subscribing, you agree to our %@ and %@."
    case subscriptionWillExpireOn = "Your subscription will expire on"
    case subscriptionExpiredOn = "Your subscription expired on"
    case payMonth = "Pay %@ /month"
    case payAnnual = "Pay %@ /annual"
    case daysLeft = "You have %@ days left"
    case expired = "Expired"
    case subscribed = "Subscribed"
    case somethingWrong = "Something went wrong"
    case plsSelectPlan = "Please select plan"
    case premiumFeature = "Premium Features"
    case premiumFeatureNew = "By subscribing to a monthly plan, it will give you access to the following premium features"
    case feature1 = "Videos"
    case feature2 = "Gallary"
    case feature3 = "Add Photos"
    case loginSignupToUseFeature = "Please Log in or sign up first to access all features of this app."
    
    case noPhoneAvailable = "There is no phone number available."
    case messageSent = "Message has been sent successfully."
    
    case accessDenied = "Access Denied"
   case contactAccess = "Please enable access to contacts through the Settings app."
    
    case noContactsAvailable = "No Contacts Available!"
    
    case delete = "Delete"
    
    case deleteContactList = "Are you sure you want to delete this contact list?"
    case deleteList = "Are you sure you want to delete this list?"
    case deleteMessage = "Are you sure you want to delete this message?"
    
    case verify = "Verify"
    case deleteTrustee = "Are you sure you want to delete this trustee?"
    case proceed = "Proceed"
    case noTrusteeAvailable = "No trustee Available!"
    
    case search = "Search"
    case searchContact = "Search Contact From Contact List"
    case activate = "Activate"
    case deactivate = "Deactivate"
    
    case photosAndImages = "PHOTOS & IMAGES"
    case voiceAndAudio = "VOICE & AUDIO"
    case videoFiles = "VIDEO FILES"
    case textMessages = "TEXT MESSAGES"
    
    case enterVerificationCode = "Please enter verification code."
    
    case kImageLimit = "Max photos limit reached."
    case failedToProccess = "Failed to process file."
    case alertSelectList = "Please select contact list."
    
    case noMemoryVaultAvailable = "No memory vaults available!"
    case noContactListAvailable = ""
    case trustePermission = "Enter trustee name"
    
    case contactList = "CONTACT LISTS"
    case contactListDesc = "Add or edit people into specific contact lists to better organize your individual content."
    
    case memoryVaultDesc = "Set up future deliverable files for your previously configured contacts and contact lists."
    case trustedPeopleDesc = "Set-up the trusted contacts who will inherit your account access and privileges in the future."
    case restoreSubscription = "You have an active subscription. Please click 'Restore' to reactivate it."
    
    case noTransactionToRestore = "No transactions to restore."
    
    
    case Trustee_Access = "TRUSTEE ACCESS"
    case Code = "Code"
    case enter_Code = "Enter Code"
    case TRUSTEE_Login = "TRUSTEELOGIN"
    case log_In_with_code = "LOG IN WITH CODE"
    case have_AccessDesc = "You now have access to %@’s account.\nYou can view and set-up messages, however you\ncannot modify or edit previous information."
    case profile_AccessDesc = "A unique 5 letter code has been sent \n to your registered email or mobile number. \n Access your loved one’s profile from here:"
    
}
