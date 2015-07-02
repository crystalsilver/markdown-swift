https://travis-ci.org/leannenorthrop/markdown-swift.svg?branch=master

# markdown-swift

An first attempt at porting markdown-js to swift framework including Wylie translations for Uchen script support via Romanized characters. Currently this project is under active development and about to undergo a major rewrite to align better to Swift's
language style. Will convert this project to CocoaPod once a satisfactory codebase is in place.

## Building

Can be built either within XCode or on OSx command-line: `xcodebuild clean build test -scheme Markdown -destination 'platform=iOS Simulator,name=iPhone 6,OS=8.3'`.
