# Microsoft Cognitive Services iOS Examples

## Overview

These Xcode projects serve as an introduction to [Microsoft's Cognitive Services](https://www.microsoft.com/cognitive-services/) and were created by [Alex Repty](https://twitter.com/arepty) as part of a [workshop for UIKonf 2016 in Berlin](http://www.uikonf.com/workshops/).

## Prerequisites

You will need a Mac with Xcode 8.0 and Swift 3 to run these examples ([a Swift 2 version for Xcode 7.x is still available](https://github.com/alexrepty/Cognitive-Services-Workshop/releases/tag/swift2)), plus a [Microsoft account](https://signup.live.com/) which you'll use to [sign up for Cognitive Services](https://www.microsoft.com/cognitive-services/en-us/sign-up). From there, you will be able to retrieve the necessary API keys to use in the Xcode projects.

## Tag & Tweet

This example uses the [Computer Vision API](https://www.microsoft.com/cognitive-services/en-us/computer-vision-api) to analyze an image and pre-fill a social sharing view controller with a range of suitable tags for the image, ready to post to either Twitter or Facebook.

![image](tagtweet.gif)

## EmojiMe

This example uses the [Emotion API](https://www.microsoft.com/cognitive-services/en-us/emotion-api) to detect faces and facially expressed emotions in an image and render emojis in the places where they were detected.

![image](emojime.gif)
