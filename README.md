# Sendbird UIKit for iOS
![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Swift-orange.svg)

## Introduction

Sendbird UIKit for iOS is a development kit with an user interface that enables an easy and fast integration of standard chat features into new or existing client apps. This repository houses the UIKit source code in addition to a UIKit sample as explained below.

- **uikit** is where you can find the open source code. Check out [UIKit Open Source Guidelines](https://github.com/sendbird/sendbird-uikit-ios-sources/blob/main/OPENSOURCE_GUIDELINES.md) for more information regarding our stance on open source.
- **uikit-sample** is a chat app which contains custom sample code for various key features written in `Swift`. 

### More about Sendbird UIKIT for iOS

Find out more about Sendbird UIKit for iOS at [UIKit for iOS doc](https://sendbird.com/docs/uikit/v1/ios/getting-started/about-uikit). If you need any help in resolving any issues or have questions, visit [our community](https://community.sendbird.com).

<br />

## Before getting started

This section shows you the prerequisites you need for testing Sendbird UIKit for iOS sample app. 

### Requirements

The minimum requirements for UIKit for iOS are:

- iOS 10.3 or later
- Swift 4.2 or later / Objective-C
- Chat SDK for iOS is 3.0.216 or later

> Note: Sendbird UIKit for iOS is Sendbird Chat SDK-dependent. If you install the UIKit, `CocoaPods` will automatically install the Chat SDK for iOS as well. 

### Try the sample app using your data 

If you would like to try the sample app specifically fit to your usage, you can do so by replacing the default sample app ID with yours, which you can obtain by [creating your Sendbird application from the dashboard](https://sendbird.com/docs/chat/v3/ios/getting-started/install-chat-sdk#2-step-1-create-a-sendbird-application-from-your-dashboard). Furthermore, you could also add data of your choice on the dashboard to test. This will allow you to experience the sample app with data from your Sendbird application. 

<br />

## Getting started

This section explains the steps you need to take before testing the sample app.

### Create a project

Create a project to get started. Sendbird UIKit supports both `Objective-C` and `Swift`, so you can create and work on a project in the language you want to develop with.

### Install UIKit for iOS

The sample uses source files from `uikit` folder directly, but you can also install UIKit for iOS through either `CocoaPods` or `Carthage`.

#### - CocoaPods

1. Add `SendBirdUIKit` into your `Podfile` in Xcode as below:

```bash
platform :ios, '10.3' 
use_frameworks! 

target YOUR_PROJECT_TARGET do
    pod 'SendBirdUIKit'
end
```

2. Install the `SendBirdUIKit` framework through `CocoaPods`.

```bash
$ pod install
```

3. Update the `SendBirdUIKit` framework through `CocoaPods`.

```bash
$ pod update 
```

> __Note__: Sendbird UIKit for iOS is `Sendbird Chat SDK-dependent`. If you install the UIKit, `CocoaPods` will automatically install the Chat SDK for iOS as well. The minimum requirement of the Chat SDK for iOS is 3.0.216 or later. 

#### - Carthage

1.Add `SendBirdUIKit`and `SendBirdSDK`into your `Cartfile` as below:

> __Note__: Sendbird UIKit for iOS is `Sendbird Chat SDK-dependent`. The minimum requirement of the Chat SDK for iOS is 3.0.216 or later. 

```bash
github "sendbird/sendbird-uikit-ios"
github "sendbird/sendbird-ios-framework" == 3.0.216
```

2. Install the `SendBirdUIKit` framework through `Carthage`.

```bash
$ carthage update
```

3. Go to your Xcode project target’s **General settings** tab in the `Frameworks and Libraries` section. Then drag and drop on the disk each framework from the `<YOUR_XCODE_PROJECT_DIRECTORY>/Carthage/Build/iOS` folder.
4. Go to your Xcode project target’s **Build Phases settings** tab, click the **+** icon, and choose **New Run Script Phase**. Create a `Run Script`, specify your shell (ex: /bin/sh), and add `/usr/local/bin/carthage copy-frameworks` to the script below the shell.
5. Add the following paths to the `SendBirdUIKit` and `SendBirdSDK` frameworks under `Input Files`.

```bash
$(SRCROOT)/Carthage/Build/iOS/SendBirdUIKit.framework
$(SRCROOT)/Carthage/Build/iOS/SendBirdSDK.framework
```

> __Note__: Building or creating the `SendbirdUIKit` framework with `Carthage` can only be done using the latest `Swift`. If your `Swift` is not the most recent version, the framework should be copied into your project manually.

#### Handling errors caused by unknown attributes

If you are building with Xcode 11.3 or earlier version, you may face two following errors caused by Swift's new annotation processing applied on `Swift 5.2` which is used in Xcode 11.4.

```bash
- Unknown attribute ‘_inheritsConvenienceInitializers’
- Unknown attribute ‘_hasMissingDesignatedInitializers’
```

When these errors happen, follow the steps below which remove the annotations by executing the necessary script in the build steps in advance. 

1. Open the **Edit scheme** menu of the project target.
![EditScheme](https://static.sendbird.com/docs/uikit/ios/getting-started-handling-errors-01_20200623.png)
2. Go to **Build** > **Pre-actions** and select the **New Run Script Action** option at the bottom.
![NewRunScriptAction](https://static.sendbird.com/docs/uikit/ios/getting-started-handling-errors-02_20200623.png)
3. Add the script below. Select the target to apply the script.
![ApplyScript](https://static.sendbird.com/docs/uikit/ios/getting-started-handling-errors-03_20200623.png)

```bash
# CocoaPods
if [ -d "${PROJECT_DIR}/Pods/SendBirdUIKit" ]; then
    find ${PROJECT_DIR}/Pods/SendBirdUIKit/SendBirdUIKit.framework/Modules/SendBirdUIKit.swiftmodule/ -type f -name '*.swiftinterface' -exec sed -i '' s/'@_inheritsConvenienceInitializers '// {} +
    find ${PROJECT_DIR}/Pods/SendBirdUIKit/SendBirdUIKit.framework/Modules/SendBirdUIKit.swiftmodule/ -type f -name '*.swiftinterface' -exec sed -i '' s/'@_hasMissingDesignatedInitializers '// {} +
fi

# Carthage
if [ -d "${PROJECT_DIR}/Carthage/Build/iOS/SendBirdUIKit.framework" ]; then
    find ${PROJECT_DIR}/Carthage/Build/iOS/SendBirdUIKit.framework/Modules/SendBirdUIKit.swiftmodule/ -type f -name '*.swiftinterface' -exec sed -i '' s/'@_inheritsConvenienceInitializers '// {} +
    find ${PROJECT_DIR}/Carthage/Build/iOS/SendBirdUIKit.framework/Modules/SendBirdUIKit.swiftmodule/ -type f -name '*.swiftinterface' -exec sed -i '' s/'@_hasMissingDesignatedInitializers '// {} +
fi
```
4. Try to build and run

<br />

## Get attachment permission

Sendbird UIKit offers features to attach or save files such as photos, videos, and documents. To use those features, you need to request permission from end users.

#### Media attachment permission

Applications must acquire permission to use end users’ photo assets or to save assets into their library. Once the permission is granted, users can send image or video messages and save media assets.

```xml
...
<key>NSPhotoLibraryUsageDescription</key>
    <string>$(PRODUCT_NAME) would like access to your photo library</string>
<key>NSCameraUsageDescription</key>
    <string>$(PRODUCT_NAME) would like to use your camera</string>
<key>NSMicrophoneUsageDescription</key>
    <string>$(PRODUCT_NAME) would like to use your microphone (for videos)</string>
<key>NSPhotoLibraryAddUsageDescription</key>
    <string>$(PRODUCT_NAME) would like to save photos to your photo library</string>
...
```


![The information property list editor, which let you configure media attachment permission.](https://static.sendbird.com/docs/uikit/ios/getting-started-02_20200416.png)

#### *(Optional)* Document attachment permission

If you want to allow your users to attach files from `iCloud` to messages, you must activate the `iCloud` feature. Once it is activated, users can also send a message with files from `iCloud`.

Go to your Xcode project's **Signing & Capabilities** tab. Then, click **+ Capability** button and select **iCloud**. Check **iCloud Documents**.

![Configuring options to allow your users to attaching files from iCloud to messages in the Signing & Capabilities tab.](https://static.sendbird.com/docs/uikit/ios/getting-started-03_20200416.png)

<br />

## Distribution setting

UIKit is distributed in the form of a fat binary, which contains information on both **Simulator** and **Device** architectures. Add the script below if you are planning to distribute your application in the App Store and wish to remove unnecessary architectures in the application's build phase.

Go to your Xcode project target's **Build Phases** tab. Then, click **+** and select **New Run Script Phase**. Append this script.

```bash
APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

# This script loops through the frameworks embedded in the application and
# removes unused architectures.
find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
    FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
    FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
    echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"

    EXTRACTED_ARCHS=()

    for ARCH in $ARCHS
    do
        echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
        lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
        EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
    done

    echo "Merging extracted architectures: ${ARCHS}"
    lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
    rm "${EXTRACTED_ARCHS[@]}"

    echo "Replacing original executable with thinned version"
    rm "$FRAMEWORK_EXECUTABLE_PATH"
    mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"
done
```

<br />

## UIKit features and ways to customize 

Here is an overview of a list of items you can use to customize the UIKit. 
To find these items, sign in to the sample app. Click on the **Custom Samples** button to see the custom sample screen on which you will find the `/Customize` folder that contains code used for customization.

| Category | Item | Desctription |
| :---: | :--- | :--- |
| Global| ColorSet |A singleton that manages primary colors in global color set. |
| | FontSet |A singleton that manages all fonts in global font set.|
| | IconSet | A singleton that manages bar buttons in global icon set. |
| | StringSet |A singleton that manages header titles in global string set. |
| | Theme | A singleton that manages **ChannelListTheme** in global theme. |
| ChannelList| UI Component | A component that customizes certain UI elements and mark them with red borders. |
| | Custom Cell | A component that changes default channel cells to custom cells. |
| | ChannelListQuery | A `SBDGroupChannelListQuery` instance that displays empty channels and frozen channels. |
| | Function Overriding | A function that inherits the `SBUChannelListViewController` class and customizes a selection of its functions. |
|Channel | UI Component | A component that customizes certain UI elements and mark them with red borders. |
| | Custom Cell | A component that changes default channel cells to custom cells. |
| | MessageListParams | A `SBDMessageListParams` object that uses specific attributes to retrieve a list of messages.  |
| | MessageParams | A `SBUUserMessageParams` that uses specific attributes to send and display messages.  |
| | Function Overriding | A function that inherits the `SBUChannelViewController` class and customizes a selection of its functions. |
|Channel Settings | UI Component | A component that customizes certain UI elements and mark them with red borders. |
| | Function Overriding | A function that inherits the `SBUChannelSettingsViewController` class and customizes a selection of its functions. |
|Create Channel | UI Component |A component that customizes certain UI elements and mark them with red borders. |
| | Custom Cell | A component that changes default channel cells to custom cells. |
| | User list | A `SBDApplicationUserListQuery` instance that can be used for importing your own user list.  |
|Invite User | UI Component | A component that customizes certain UI elements and mark them with red borders. |
| | Custom Cell | A component that changes default channel cells to custom cells. |
| | User list | A `SBDApplicationUserListQuery` instance that can be used for importing your own user list. |
|Member List | UI Component | A component that customizes certain UI elements and mark them with red borders. |
| | Custom Cell | A component that changes default channel cells to custom cells. |
| | Function Overriding | A function that inherits the `SBUMemberListViewController` class and customizes a selection of its functions. |
