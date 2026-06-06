CapsLock::
   Timer = 0
   UseMagic = 0
   while GetKeyState("CapsLock","P")
   {
       Timer := Timer + 1
       Sleep, 10
   }
   if (Timer <= 15 && !UseMagic)
   {
      SetCapsLockState % !GetKeyState("CapsLock", "T") ;
   }
Return

#if GetKeyState("CapsLock","P")

w::
  UseMagic = 1
  w::up
a::
  UseMagic = 1
  a::left
s::
  UseMagic = 1
  s::down
d::
  UseMagic = 1
  d::right
q::
  UseMagic = 1
  q::home
e::
  UseMagic = 1
  e::end
f::
  UseMagic = 1
  f::delete
1::
  UseMagic = 1
  1::F1
2::
  UseMagic = 1
  2::F2
3::
  UseMagic = 1
  3::F3
4::
  UseMagic = 1
  4::F4
5::
  UseMagic = 1
  5::F5
6::
  UseMagic = 1
  6::F6
7::
  UseMagic = 1
  7::F7
8::
  UseMagic = 1
  8::F8
9::
  UseMagic = 1
  9::F9
0::
  UseMagic = 1
  0::F10
-::
  UseMagic = 1
  -::F11
=::
  UseMagic = 1
  =::F12
backspace::
  UseMagic = 1
  backspace::delete

WheelUp::  ; 向左滚动.
  UseMagic = 1
  WheelUp::WheelLeft

WheelDown::  ; 向右滚动.
  UseMagic = 1
  WheelDown::WheelRight

LButton::
  UseMagic = 1
  LButton::XButton1

RButton::
  UseMagic = 1
  RButton::XButton2

u::
  UseMagic = 1
  u::LButton

Space::
  UseMagic = 1
  Space::LButton

o::
  UseMagic = 1
  o::RButton

*i::
*j::
*k::
*l::
  CoordMode, Mouse, Screen
  UseMagic = 1
  PressTime = 0
  while (GetKeyState("i","P") || GetKeyState("j","P") || GetKeyState("k","P") || GetKeyState("l","P"))
  {
    if (GetKeyState("Shift","P")) 
    {
      MouseSpeed = 30
    }
    else
    {
      MouseSpeed = 10
    }
    
    MouseGetPos, begin_x, begin_y
    Mx = 0
    My = 0
    if (GetKeyState("i","P")) 
    {
      My := My - MouseSpeed
    }
    if (GetKeyState("k","P")) 
    {
      My := My + MouseSpeed
    }
    if (GetKeyState("j","P")) 
    {
      Mx := Mx - MouseSpeed
    }
    if (GetKeyState("l","P")) 
    {
      Mx := Mx + MouseSpeed
    }

    if (Abs(Mx) > 0 && Abs(My) > 0)
    {
      Mx := Mx / 1.414
      My := My / 1.414
    }

    Mx := Mx * (1 + Min(PressTime / 500,4))
    My := My * (1 + Min(PressTime / 500,4))

    DllCall("SetCursorPos", "int", begin_x + Mx, "int", begin_y + My)
    Sleep,20
    PressTime := PressTime + 20
  }

#if