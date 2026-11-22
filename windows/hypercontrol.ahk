; =============================================================================
;  Hyper Control for Windows (AutoHotkey v2)
;  Windows port of ../hypercontrol.yml (the Karabiner version for macOS).
; =============================================================================
;
; SETUP
;   1. Install AutoHotkey v2 (the portable zip works without admin rights).
;   2. PowerToys > Keyboard Manager > Remap a key: swap Left Alt and Left Ctrl
;      both ways, so the key beside Space acts like the Mac Command key.
;      Stop the old mac.ahk; this script already includes what it did.
;   3. Double-click this file to run it. To start it at login, put a shortcut
;      to it in the Startup folder (Win+R, then type shell:startup).
;   4. Optional: double-click disable-office-key.reg (see the Hyper keys section).
;   5. Hold the Command key and press Caps+Z: a tooltip shows which modifiers
;      the script sees. Command should show as LCtrl.
;      If it shows LAlt as well, quit PowerToys and start it again after this
;      script, so PowerToys sees each key press first.
;
; MAC KEY NAMES (with the PowerToys swap above)
;   Command = the key beside Space -> Windows sees Ctrl  (^ in AutoHotkey)
;   Option  = the Windows key      -> Windows sees Win   (# in AutoHotkey)
;   Control = the bottom-left key  -> Windows sees Alt   (! in AutoHotkey)
;   Shift   = Shift                                      (+ in AutoHotkey)
;
; HOW THE HYPER LAYER WORKS
;   The script tracks whether Caps Lock is held in the variable capsHeld.
;   The "#HotIf capsHeld" block below only applies while it is held.
;   Caps Lock's own on/off toggle is switched off permanently.
;   Tapping Caps Lock on its own sends Escape.
;
; After editing this file: right-click the tray icon (green H) > Reload Script.
; =============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")
InstallKeybdHook()                  ; needed for A_PriorKey and the Hyper Layer
SetCapsLockState("AlwaysOff")

; --- Timing (same idea as Karabiner's settings) -------------------------------
CAPS_TAP_MS   := 500   ; Caps released within this -> Escape (karabiner.json: 500)
SHIFT_TAP_MS  := 200   ; Shift released within this -> ( or )
SPACE_ROLL_MS := 150   ; Space within this after right Shift -> ") "

; --- Hyper chord ----------------------------------------------------------------
; Ctrl+Shift+Alt+Win. Windows reserves this as the "Office key": Hyper+W opens
; Word, +X Excel, +Y Yammer (and +O/P/T/N/D/L, which this layout doesn't use).
; If that happens, either import disable-office-key.reg, or change this to
; "^+!" (Ctrl+Shift+Alt, no Win) and bind those chords instead.
HYPER_CHORD := "^+!#"

; --- State ----------------------------------------------------------------------
capsHeld   := false
capsDownAt := 0
shiftDownAt := Map("LShift", 0, "RShift", 0)   ; 0 = not held


; =============================================================================
;  Caps Lock: tap = Escape, hold = Hyper Layer
; =============================================================================
*CapsLock:: {
    global capsHeld, capsDownAt
    if capsHeld
        return                      ; key auto-repeat while held: ignore
    capsHeld := true
    capsDownAt := A_TickCount
}

*CapsLock up:: {
    global capsHeld
    capsHeld := false
    ; A_PriorKey is the last key pressed before this release. If it's still
    ; CapsLock, nothing else was pressed while Caps was held: it was a tap.
    if (A_PriorKey = "CapsLock" && A_TickCount - capsDownAt < CAPS_TAP_MS)
        Send("{Esc}")
}


; =============================================================================
;  Hyper Layer
;  Keep this block ABOVE the others: when two conditional versions of a hotkey
;  both apply, AutoHotkey uses the one nearest the top of the file.
;  All hotkeys start with * so they also fire with other modifiers held.
; =============================================================================
#HotIf capsHeld

; --- Arrows and editing --------------------------------------------------------
; Mac modifiers are translated to their Windows equivalents (see CapsArrow):
;   Caps+F = Right, +Option = word right, +Command = end of line, +Shift selects
*f::CapsArrow("Right")
*b::CapsArrow("Left")
*n::CapsArrow("Down")
*p::CapsArrow("Up")

*h::CapsDelete("Backward")          ; Backspace (+Option: word, +Command: to line start)
*Backspace::CapsDelete("Forward")   ; forward Delete (same modifier variants)

*SC033::SendWithShift("^{Home}")    ; ,  start of document (+Shift selects)
*SC034::SendWithShift("^{End}")     ; .  end of document

; Emacs-style keys. On the Mac these are Control+key handled by macOS; Windows
; has no such bindings, so each one is done with ordinary keys.
*a::SendWithShift("{Home}")         ; start of line (Mac: start of paragraph)
*e::SendWithShift("{End}")          ; end of line   (Mac: end of paragraph)
*d::Send("{Del}")                   ; delete forward
*k::Send("+{End}{Del}")             ; delete to end of line; at line end, joins lines
*o::Send("{Enter}{Left}")           ; split line, cursor stays put

; --- Other keys -----------------------------------------------------------------
*v::Send("^+v")                     ; paste as plain text (most apps; not Office)
*SC01A::Send("^#{Left}")            ; [  previous virtual desktop
*SC01B::Send("^#{Right}")           ; ]  next virtual desktop
*Space::Send("#.")                  ; emoji panel

; --- Hyper keys -----------------------------------------------------------------
; Each sends HYPER+key. Bind those chords to your apps yourself.
; Comments are the v3 design labels from the Mac version.
; Punctuation uses scan codes (SCxxx) so no symbol needs escaping.
*SC029::Hyper("{SC029}")            ; `  window: maximise
*1::Hyper("1")                      ; window: quarter 1
*2::Hyper("2")                      ; window: quarter 2
*3::Hyper("3")                      ; window: quarter 3
*4::Hyper("4")                      ; window: quarter 4
*5::Hyper("5")                      ; window: half left
*6::Hyper("6")                      ; window: half right
*7::Hyper("7")                      ; window: half top
*8::Hyper("8")                      ; window: half bottom
*9::Hyper("9")                      ; window: reasonable size
*0::Hyper("0")                      ; window: centre
*SC00C::Hyper("{SC00C}")            ; -  clipboard popup
*SC00D::Hyper("{SC00D}")            ; =  Access
*SC02B::Hyper("{SC02B}")            ; \  Passwords
*q::Hyper("q")                      ; BusyCal
*w::Hyper("w")                      ; Notes     (Office key: Word)
*r::Hyper("r")                      ; Reminders
*y::Hyper("y")                      ; iMessage  (Office key: Yammer)
*u::Hyper("u")                      ; Music
*i::Hyper("i")                      ; Nova
*s::Hyper("s")                      ; Safari
*g::Hyper("g")                      ; Hookmark
*j::Hyper("j")                      ; FinBar
*SC027::Hyper("{SC027}")            ; ;  expand text
*SC028::Hyper("{SC028}")            ; '  AI chat
*x::Hyper("x")                      ; iTerm2    (Office key: Excel)
*m::Hyper("m")                      ; Mail
*SC035::Hyper("{SC035}")            ; /  Finder

; --- Diagnostic -----------------------------------------------------------------
; Caps+Z shows which modifiers the script sees, logically (after PowerToys)
; and physically. Hold the modifier you're checking, then press Caps+Z.
*z:: {
    text := "Modifiers AutoHotkey sees (logical / physical):`n"
    for key in ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"]
        text .= Format("{:-7} {} / {}`n", key, GetKeyState(key), GetKeyState(key, "P"))
    ToolTip(text)
    SetTimer(() => ToolTip(), -4000)
}

; --- Swallowed ------------------------------------------------------------------
; On the Mac, unlisted Caps keys are Control+key. On Windows, Ctrl is your
; Command key, so passing them on would trigger Command shortcuts (Caps+C
; would copy). These do nothing instead, so stray presses don't type letters.
*c::
*l::
*t::
*Enter::
*Tab::
{
}

#HotIf


; =============================================================================
;  Shift parentheses
;  Tap left Shift = (, tap right Shift = ). Holding one Shift and tapping the
;  other gives "()" or ")(". Right Shift then Space quickly gives ") ".
; =============================================================================
~LShift::ShiftDown("LShift")
~RShift::ShiftDown("RShift")

~LShift up:: {
    if ShiftTapped("LShift")
        Send(GetKeyState("RShift") ? ")(" : "(")
}

~RShift up:: {
    if ShiftTapped("RShift")
        Send(GetKeyState("LShift") ? "()" : ")")
}

; ")" then Space typed so fast that Space lands while right Shift is still
; down. Only within SPACE_ROLL_MS of pressing it, so a held Shift+Space is
; left alone.
#HotIf !capsHeld && RightShiftJustPressed()
+Space::Send(") ")
#HotIf


; =============================================================================
;  File Explorer
;  Only while the file list has focus (not while renaming or typing in the
;  address bar, where Cmd+Backspace must not delete files).
;  Must stay ABOVE the general Mac shortcuts, which reuse these keys.
; =============================================================================
#HotIf !capsHeld && ExplorerFileListFocused()
^Up::Send("!{Up}")                  ; Cmd+Up: parent folder
^Down::Send("{Enter}")              ; Cmd+Down: open selected item
^BS::Send("{Del}")                  ; Cmd+Backspace: move to Recycle Bin
#HotIf


; =============================================================================
;  Mac shortcuts (from mac.ahk, github.com/stevenilsen123/mac-keyboard-behavior-in-windows)
;  Off while Caps is held, so they never compete with the Hyper Layer.
; =============================================================================
#HotIf !capsHeld

; App and tab switching
Ctrl & Tab::AltTab                  ; Cmd+Tab: app switcher
!Tab::Send("^{Tab}")                ; physical Ctrl+Tab: next tab
!+Tab::Send("^+{Tab}")              ; physical Ctrl+Shift+Tab: previous tab

^q::Send("!{F4}")                   ; Cmd+Q: quit

; Cursor movement (add Shift to select)
^Left::Send("{Home}")               ; Cmd+Left: start of line
^Right::Send("{End}")               ; Cmd+Right: end of line
^Up::Send("^{Home}")                ; Cmd+Up: start of document
^Down::Send("^{End}")               ; Cmd+Down: end of document
^+Left::Send("+{Home}")
^+Right::Send("+{End}")
^+Up::Send("+^{Home}")
^+Down::Send("+^{End}")
#Left::Send("^{Left}")              ; Option+Left: word left
#Right::Send("^{Right}")            ; Option+Right: word right
#+Left::Send("+^{Left}")
#+Right::Send("+^{Right}")

; Real Ctrl+C / Ctrl+D from the physical Ctrl key (break / end-of-file)
!c::Send("^c")
!d::Send("^d")


; =============================================================================
;  More Mac shortcuts (not in mac.ahk)
; =============================================================================
^+z::Send("^y")                     ; Cmd+Shift+Z: redo
^BS::Send("+{Home}{BS}")            ; Cmd+Backspace: delete to line start
#BS::Send("^{BS}")                  ; Option+Backspace: delete word left
#Del::Send("^{Del}")                ; Option+Delete: delete word right
#+Up::Send("^+{Up}")                ; Option+Shift+Up: select paragraph up
#+Down::Send("^+{Down}")            ; Option+Shift+Down: select paragraph down

^SC029::CycleAppWindows(false)      ; Cmd+`: next window of this app
^+SC029::CycleAppWindows(true)      ; Cmd+Shift+`: previous window
^m::WinMinimize("A")                ; Cmd+M: minimise
^+SC01A::Send("^+{Tab}")            ; Cmd+Shift+[: previous tab
^+SC01B::Send("^{Tab}")             ; Cmd+Shift+]: next tab

^#Esc::Send("^+{Esc}")              ; Cmd+Option+Esc: Task Manager (force quit)
^+3::Send("#{PrintScreen}")         ; Cmd+Shift+3: screenshot to Pictures\Screenshots
^+4::Send("#+s")                    ; Cmd+Shift+4: snip a region
^+5::Send("#+s")                    ; Cmd+Shift+5: snip
^!q::DllCall("LockWorkStation")     ; Ctrl+Cmd+Q: lock screen (Win+L can't be sent)

#HotIf


; =============================================================================
;  Helper functions
; =============================================================================

; Send keys, adding Shift if it's held, so Caps+Shift+key selects.
SendWithShift(keys) => Send((GetKeyState("Shift") ? "+" : "") keys)

; Send the Hyper chord plus a key.
Hyper(key) => Send(HYPER_CHORD key)

; Is the Mac Command / Option key held? (Uses the logical state, i.e. what
; Windows sees after the PowerToys swap.)
CommandHeld() => GetKeyState("Ctrl")
OptionHeld() => GetKeyState("LWin") || GetKeyState("RWin")

; Arrow key with Mac-style modifiers:
;   plain -> arrow, Option -> word/paragraph jump, Command -> line/document edge
CapsArrow(dir) {
    static commandKeys := Map("Left", "{Home}", "Right", "{End}", "Up", "^{Home}", "Down", "^{End}")
    if CommandHeld()
        keys := commandKeys[dir]
    else if OptionHeld()
        keys := "^{" dir "}"
    else
        keys := "{" dir "}"
    SendWithShift(keys)
}

; Backspace / forward delete with Mac-style modifiers:
;   plain -> one character, Option -> one word, Command -> to line start/end
CapsDelete(direction) {
    back := (direction = "Backward")
    if CommandHeld()
        Send(back ? "+{Home}{BS}" : "+{End}{Del}")
    else if OptionHeld()
        Send(back ? "^{BS}" : "^{Del}")
    else
        Send(back ? "{BS}" : "{Del}")
}

; Remember when a Shift key went down (ignoring key auto-repeat).
ShiftDown(key) {
    if !shiftDownAt[key]
        shiftDownAt[key] := A_TickCount
}

; True if this Shift release was a quick tap with nothing else pressed.
ShiftTapped(key) {
    downAt := shiftDownAt[key]
    shiftDownAt[key] := 0
    return A_PriorKey = key
        && downAt && A_TickCount - downAt < SHIFT_TAP_MS
        && !capsHeld
        && !GetKeyState("Ctrl") && !GetKeyState("Alt")
        && !GetKeyState("LWin") && !GetKeyState("RWin")
}

RightShiftJustPressed() {
    downAt := shiftDownAt["RShift"]
    return downAt && A_TickCount - downAt < SPACE_ROLL_MS
}

; Bring the next window of the active app to the front, like Cmd+` on the Mac.
CycleAppWindows(reverse) {
    try {
        exe := WinGetProcessName("A")
        cls := WinGetClass("A")
    } catch {
        return
    }
    ; Same app and window type, front-most first; skip untitled helper windows.
    wins := []
    for id in WinGetList("ahk_exe " exe " ahk_class " cls)
        if WinGetTitle(id) != ""
            wins.Push(id)
    if wins.Length < 2
        return
    if reverse {
        WinMoveBottom(wins[1])          ; current window to the back
        WinActivate(wins[2])
    } else {
        WinActivate(wins[wins.Length])  ; back-most window to the front
    }
}

; True when File Explorer's file list (not a text box) has keyboard focus.
ExplorerFileListFocused() {
    try {
        return WinActive("ahk_class CabinetWClass")
            && InStr(ControlGetClassNN(ControlGetFocus("A")), "DirectUIHWND") = 1
    }
    return false
}
