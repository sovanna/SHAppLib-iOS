SHAppLib
========

This project gives a set of tools to develop iOS app faster with personal lib

## I. Notes

*For more information, you can read the tutorial [creating a status library in ios tutorial](http://www.raywenderlich.com/41377/creating-a-status-library-in-ios-tutorial
) from Ray Wenderlich*

*This how I build the framework.*

#### Step 1. Setup xcode project

	Create a new xcode project
	select a `Cocoa Touch Static Library` type in `Framework & Library`
	
#### Step 2. Dev your libs

	Create your class, do your test and so on..
	
#### Step 3. Build universal binaries

##### Aggregate target
The purpose of this is to build for iOS device (ARM) and simulator (i386) architectures.

To do that, we have to create an **aggregate target**

	menu Editor/Add Target...
	select Aggregate
	
##### Run script

	select the aggregate target that you've created before
	
	Click on your project
	Select the aggregate lib target
	Select the Build Phases tab
	Extend the Run Script
	
Paste the code below

```
# Step 1. Build Device and Simulator versions

xcodebuild -target ${PROJECT_NAME} ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"

xcodebuild -target ${PROJECT_NAME} -configuration ${CONFIGURATION} -sdk iphonesimulator -arch i386 BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"


# Step 2. Define some environment variable
SIMULATOR_LIBRARY_PATH="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/lib${PROJECT_NAME}.a" &&
DEVICE_LIBRARY_PATH="${BUILD_DIR}/${CONFIGURATION}-iphoneos/lib${PROJECT_NAME}.a" &&
UNIVERSAL_LIBRARY_DIR="${BUILD_DIR}/${CONFIGURATION}-universal" &&
UNIVERSAL_LIBRARY_PATH="${UNIVERSAL_LIBRARY_DIR}/${PRODUCT_NAME}" &&
FRAMEWORK="${UNIVERSAL_LIBRARY_DIR}/${PRODUCT_NAME}.framework" &&

# Step 3. Create framework directory structure.

rm -rf "${FRAMEWORK}" &&
mkdir -p "${UNIVERSAL_LIBRARY_DIR}" &&
mkdir -p "${FRAMEWORK}/Headers" &&


# Step 4. Generate universal binary for the device and simulator.

lipo "${SIMULATOR_LIBRARY_PATH}" "${DEVICE_LIBRARY_PATH}" -create -output "${UNIVERSAL_LIBRARY_PATH}" &&


# Step 5. Move files to appropriate locations in framework paths.

cp "${UNIVERSAL_LIBRARY_PATH}" "${FRAMEWORK}/"
```

**Add Headers files**

	menu Edito/Add Build Phase/Add Copy Files Build Phase

for `destination`

	select `Absolute Path``
	
for `path`, add

	${BUILD_DIR}/${CONFIGURATION}-universal/${PRODUCT_NAME}.framework/Headers
	
*You can add your headers file as you want.*

#### Step 4. Run

	click on play
	(make sure you've selected the aggregate target)
	
#### Step 5. Fin your framework

	right click on products/yourLib
	and select show in finder
	You have to see your framework in projectName-universal folder
	
**You can now use it in your project as other classic framework**

## Docs

#### SHURLRequest
`Allows to perform request to an API`

* getFromURL:withParams:andCompletion
* postToURL:withParams:andCompletion

**usage**

```
// load page info from the serie 24

[SHURLRequest getFromURL:@"https://graph.facebook.com/24fox" withParams:nil andCompletion:^(id data, int status) {
	if (status == 200 && data) {
		__autoreleasing NSError *error = nil;
		NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
		
		if (response && [response isKindOfClass:[NSDictionary class]]) {
			NSLog(@"Response : %@", response);
		}
	}
}];
```