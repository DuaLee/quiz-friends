# Quiz Friends

## Contents
- **[Overview](#1--overview)**
- **[Code Configuration](#2--code-configuration)**
  - [Color Constants](#21--color-constants-uicolor)
  - [Score Constants](#22--score-constants-double)
  - [Timer Constants](#23--timer-constants-timeinterval-seconds)
- **[In-App Configuration](#3--in-app-configuration)**
  - [Tilt to Answer](#31--tilt-to-answer-client-setting)
  - [Haptic Feedback](#32--haptic-feedback-client-setting)
  - [Shake to Roulette](#33--shake-to-roulette-client-setting)
  - [Retain Score](#34--retain-score-each-round-host-setting)
- **[Major Contributors](#4--major-contributors)**

## 1 | Overview
Quiz Friends, written in Swift for iOS, utilizes Multipeer Framework to allow for local multiplayer games. The quiz data is fetched through remote JSON libraries.
To download the source code, head over to [releases](https://github.com/DuaLee/quiz-friends/releases/latest) for the last stable release or clone the repository for the most recent unstable build.

## 2 | Code Configuration
Within first few lines of [`QuizViewController.swift`](quiz-friends/QuizViewController.swift), one can easily identify and configure the back-facing constants to their liking.

### 2.1 | Color Constants (UIColor)
| Constant | Description | Default Value\* |
| --- | --- | --- |
| `correctColor` | Status color for correct answer | ![](https://via.placeholder.com/15/32ade6/000000?text=+) `systemCyan` |
| `incorrectColor` | Status color for incorrect answer | ![](https://via.placeholder.com/15/ff2d54/000000?text=+) `systemPink` |
| `noAnswerColor` | Status color for no answer selected | ![](https://via.placeholder.com/15/ffcc00/000000?text=+) `systemYellow` |
| `defaultColor` | Status color for neutral state | ![](https://via.placeholder.com/15/8e8e93/000000?text=+) `systemGray` |

> \*Default colors shown are for light mode only and are based on Apple's [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/)

### 2.2 | Score Constants (Double)
| Constant | Description | Default Value |
| --- | --- | --- |
| `correctAward` | Points awarded for correct answer | `1.0` |
| `incorrectAward` | Points awarded for incorrect answer | `-1.0` |
| `noAnswerAward` | Points awarded for no answer selected | `0.0` |

### 2.3 | Timer Constants (TimeInterval Seconds)
| Constant | Description | Default Value |
| --- | --- | --- |
| `questionTime` | Time to answer questions | `10` |
| `reviewTime` | Time in between questions | `3` |

## 3 | In-App Configuration
The settings within the app allow for device-level modifications to gameplay.

### 3.1 | Tilt to Answer (Client Setting)
Allows user to select an answer choice by tilting the device. As long as the display is relatively upward-facing, the program recalibrates to allow one to angle the device somewhat freely.

| Direction | Answer Choice |
| --- | --- |
| Up | Choice 1 |
| Down | Choice 2 |
| Left | Choice 3 |
| Right | Choice 4 |

### 3.2 | Haptic Feedback (Client Setting)
Enable/disable device vibration (if supported) for various user actions.

### 3.3 | Shake to Roulette (Client Setting)
Enable/disable random selection of answer choice by shaking device. Can be done as many times as needed before question timer concludes.

### 3.4 | Retain Score Each Round (Host Setting)
When the host clicks play again at the round review screen, the current score is transfered to the next round, infinitely. The score, however, is only retained for a particular session.

## 4 | Major Contributors
- DuaLee
- lannahdavis
- lannahd

![image](https://user-images.githubusercontent.com/23531530/166174735-72599481-5d5e-467d-9a6d-47a4f0f79532.png)
