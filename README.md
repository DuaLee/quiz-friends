# Quiz Friends

## 1 | Overview
Quiz Friends, written in Swift for iOS, utilizes Multipeer Framework to allow for local multiplayer games. The quiz data is fetched through remote JSON libraries.

## 2 | Code Configuration
Within first few lines of `QuizViewController.swift`, one can easily identify and configure the back-facing constants to their liking.

### 2.1 | Color Constants (UIColor)
| Constant | Description | Default Value |
| --- | --- | --- |
| `correctColor` | Status color for correct answer | `systemCyan` |
| `incorrectColor` | Status color for incorrect answer | `systemPink` |
| `noAnswerColor` | Status color for no answer selected | `systemYellow` |
| `defaultColor` | Status color for neutral state | `systemGray` |

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

![image](https://user-images.githubusercontent.com/23531530/166174735-72599481-5d5e-467d-9a6d-47a4f0f79532.png)
