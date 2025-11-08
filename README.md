# Interactive Bézier Curve Playground

> **Assignment:** Create a dynamic cubic Bézier curve that reacts to motion input like a springy rope.

---

## Objective

To Build an **interactive cubic Bézier curve simulation** that responds in real time to motion input — using gyroscope data on iOS or mouse movement on the web.

---

## Core Features

* **Cubic Bézier Curve:**
   > B(t) = (1−t)^3P₀ + 3(1−t)^2tP₁ + 3(1−t)t^2P₂ + t^3P₃ 
* **Dynamic Control Points:**

  * P₀, P₃ → Fixed endpoints
  * P₁, P₂ → Move based on gyroscope or mouse input
* **Spring Physics Model:**

  
  > acceleration = -k * (position - target) - damping * velocity
  
  Creates a smooth, rope-like motion.
* **Tangent Visualization:**
  Derivatives computed and drawn along the curve:
  > B'(t) = 3(1−t)^2(P₁−P₀) + 6(1−t)t(P₂−P₁) + 3t^2(P₃−P₂) 

---

## Stack

* **iOS Version:** Swift + CoreMotion + CoreGraphics
* **Frame Rate:** Target 60 FPS

---

## How to Run?

### iOS (Swift)

1. Open the project in **Xcode**.
2. Run on a **real device** (simulator won’t provide gyroscope data).
3. Move or tilt your device to see the curve react.

## Demo (iOS 16)
https://github.com/user-attachments/assets/30ba4c95-48b9-4875-bce8-6a0e0f01568d


