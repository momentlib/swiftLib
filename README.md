# swiftLib
Natural Language Date Parser Library in XCode

This takes the code from [Core](https://github.com/momentlib/core) and allows xcode to do the compiling for you.

**To get the Library**

1. Build the library for both simulator and ios. 
2. Run lipo command to combine them
3. Add the result to your project

lipo -create /path/to/Debug-iphoneos/libmomentLib.a /path/to/Debug-iphonesimulator/libmomentLib.a -output libcombined.a