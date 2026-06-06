# WishingFn

[English](README.en.md) 路 [Agent Notes](AGENTS.md)

涓€涓交閲忋€佸彲鎵撳寘鍙戝竷鐨?CapsLock 鍔熻兘灞傚伐鍏枫€俉ishingFn 鐢?Kanata 鎻愪緵璺ㄥ钩鍙伴敭鐩樺眰锛岀敤 Python 鎻愪緵鏀惰棌澶广€佽矾寰?缃戦〉鎵撳紑鍜屽懡浠ゅ惎鍔ㄨ兘鍔涖€?

> Windows 鍙戝竷鍖呭唴缃?Kanata锛涚敤鎴蜂笉闇€瑕佸崟鐙畨瑁?Kanata銆?

## 鐗规€?

- CapsLock 鍔熻兘灞傦細鏂瑰悜閿€丠ome/End銆丏elete銆丗1-F12銆侀紶鏍囩Щ鍔ㄥ拰鐐瑰嚮銆?
- 閫変腑鏂囧瓧浼樺厛锛氭敹钘?鎵撳紑鏃朵紭鍏堜娇鐢ㄥ綋鍓嶉€変腑鏂囧瓧锛屾病鏈夐€変腑鏃跺洖閫€鍒板壀璐存澘銆?
- 鏅鸿兘鏀惰棌锛氳嚜鍔ㄨ瘑鍒矾寰勩€佺綉椤?URL 鍜屽懡浠ゃ€?
- 鏀惰棌澶归潰鏉匡細鏀寔鎵撳紑銆侀噸鍛藉悕鍒悕銆佸垹闄ゆ敹钘忋€?
- Windows 涓€鏉″懡浠ゅ畨瑁咃細瀹夎銆佹洿鏂般€佸嵏杞介兘鍙€氳繃杩滅▼鑴氭湰瀹屾垚銆?
- GitHub Releases锛氭帹閫?tag 鍚庤嚜鍔ㄦ瀯寤?Windows 鍙戝竷鍖呫€?

## 瀹夎

### Windows

瀹夎銆佹敞鍐屽紑鏈鸿嚜鍚姩骞剁珛鍗冲惎鍔細

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.ps1 | iex
```

鏇存柊锛?

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/update.ps1 | iex
```

鍗歌浇骞剁Щ闄ゅ紑鏈鸿嚜鍚姩锛?

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/uninstall.ps1 | iex
```

榛樿瀹夎浣嶇疆锛?

```text
%LOCALAPPDATA%\WishingFn
```

### macOS / Linux

瀹夎鍛戒护鍏ュ彛宸查鐣欙紝浣?macOS/Linux 鍙戝竷鍖呰繕鏈惎鐢細

```bash
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.sh | bash -s -- update
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.sh | bash -s -- uninstall
```

## 蹇嵎閿?

| 蹇嵎閿?| 鍔熻兘 |
| --- | --- |
| 鍗曞嚮 `CapsLock` | 鍒囨崲澶у皬鍐?|
| `CapsLock + w/a/s/d` | 涓?/ 宸?/ 涓?/ 鍙?|
| `CapsLock + q/e` | Home / End |
| `CapsLock + f` | Delete |
| `CapsLock + Backspace` | Delete |
| `CapsLock + 1..0,-,=` | F1..F12 |
| `CapsLock + u/Space/o` | 宸﹂敭 / 宸﹂敭 / 鍙抽敭 |
| `CapsLock + i/j/k/l` | 榧犳爣绉诲姩 |
| `CapsLock + c` | 鏀惰棌閫変腑鏂囧瓧锛涙棤閫変腑鏃舵敹钘忓壀璐存澘 |
| `CapsLock + v` | 鎵撳紑閫変腑鏂囧瓧锛涙棤閫変腑鏃舵墦寮€鍓创鏉?|
| `CapsLock + x` | 鎵撳紑鏀惰棌澶?|

## 鏀惰棌澶?

WishingFn 浼氭妸鍐呭璇嗗埆涓猴細

- 璺緞锛氭枃浠舵垨鏂囦欢澶?
- 缃戦〉锛歚http://` 鎴?`https://`
- 鍛戒护锛氬叾浠栨枃鏈?

鏀惰棌鏃朵細瑕佹眰杈撳叆鍒悕銆傛敹钘忓す闈㈡澘鏀寔锛?

- 鍙屽嚮 / `Enter`锛氭墦寮€
- `F2`锛氶噸鍛藉悕鍒悕
- `Delete`锛氬垹闄?

> 鍛戒护浼氶€氳繃绯荤粺 shell 鎵ц锛屽彧鏀惰棌浣犱俊浠荤殑鍛戒护銆?

## 寮€鍙戜笌缁存姢

瀹炵幇缁嗚妭銆佹墦鍖呮祦绋嬨€佸彂甯冩祦绋嬪拰 Agent 宸ヤ綔璇存槑瑙?[AGENTS.md](AGENTS.md)銆?
