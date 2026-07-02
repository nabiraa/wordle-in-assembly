# x86 Assembly Wordle Game 🎮

A lightweight, text-mode clone of the popular word-guessing game **Wordle**, written entirely in **16-bit x86 Assembly Language**. This project was developed as a semester lab project for the **Computer Organization and Assembly Language Lab** using the **emu8086** emulator.

---

## 🚀 Key Features
* **Dynamic Word Selection:** Uses a pseudo-random word generator tied directly to the system clock to pick a new 5-letter word from a pre-defined word bank every time you start the game.
* **Color-Coded Feedback (VGA/BIOS Text Mode):** Leverages hardware video interrupts to render real-time color feedback:
  * 🟩 **Green Background:** Letter is correct and in the perfect position.
  * 🟨 **Yellow Background:** Letter exists in the word but is in the wrong position.
  * 🟥 **Red Text:** Letter does not exist in the secret word.
* **Smart Duplicate Letter Handling:** Includes logic using bit-masks to prevent duplicate guessed letters from accidentally claiming multiple matches against a single target letter.
* **Case Insensitivity:** Automatically detects and converts lowercase inputs to uppercase using ASCII bitwise arithmetic.
* **6-Attempt Limit:** Tracks total rounds played, triggering a reveal of the secret word if the player runs out of turns.

---

## 🛠️ Low-Level Concepts & Interrupts Used
* **`INT 21h` (MS-DOS System Services):** 
  * `AH=01h`: Captures live keyboard inputs with character echoing.
  * `AH=09h`: Displays system string messages terminated with `$`.
  * `AH=2Ch`: Reads the system time hardware register down to the hundredths-of-a-second to serve as a random seed.
  * `AH=4Ch`: Safely terminates execution and returns control to the OS.
* **`INT 10h` (BIOS Video Services):** 
  * `AH=09h`: Writes characters directly to the video memory buffer with specific color attributes (`BL`).
  * `AH=03h` & `AH=02h`: Manually updates and advances the blinking hardware cursor position.
* **`INT 16h` (BIOS Keyboard Services):**
  * `AH=00h`: Pauses execution and waits for a final keystroke to prevent the terminal window from instantly snapping closed.
* **Addressing Modes:** Extensively uses **Register Indirect & Indexed Addressing** (`GUESS[SI]` and `TARGET[DI]`) to manipulate and sweep through contiguous byte arrays.

---

## 👥 Team Contribution Breakdown
This project was divided into 3 modular sub-systems to parallelize development under a tight deadline:
* **Member 1 (Input & UI Handler):** Managed string constants, text menus, user keyboard inputs, and the auto-capitalization validation wrapper.
* **Member 2 (Core Comparison Logic Engine):** Built the 2-pass evaluation array logic to compare arrays, flag status states, and resolve exact/misplaced letter matching.
* **Member 3 (Color Display & Game Loop Controller):** Implemented the BIOS color rendering loops, custom cursor adjustments, loop boundaries, and win/loss handlers.

---

## 💻 How to Run
1. Download and open the **emu8086** emulator.
2. Copy the contents of the `.asm` file into the editor workspace.
3. Click **Emulate** to compile the low-level source code.
4. Hit **Run** in the emulator console to start guessing!
