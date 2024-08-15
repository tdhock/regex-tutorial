Goal is to convert HTML tables in
[Keyboard_event_key_values.html](Keyboard_event_key_values.html) to R
data tables.

One row for each hex code/name, as below.

```r
> full_win_codes
         dom_name     key_name  space    hex
           <char>       <char> <char> <char>
  1: Unidentified         <NA>   <NA>   <NA>
  2:          Alt      VK_MENU            12
  3:     AltGraph         <NA>   <NA>   <NA>
  4:     CapsLock   VK_CAPITAL            14
  5:      Control   VK_CONTROL            11
 ---                                        
314:          Add       VK_ADD            6B
315:       Divide    VK_DIVIDE            6F
316:     Subtract  VK_SUBTRACT            6D
317:    Separator VK_SEPARATOR            6C
318:            0   VK_NUMPAD0            60
```

Solution: see [my blog](https://tdhock.github.io/blog/2024/chromote-key-codes/).
