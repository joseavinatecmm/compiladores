target triple = "arm64-apple-macosx26.0.0"

@.str = private unnamed_addr constant [15 x i8] c"Resultado: %d\0A\00"

declare i32 @printf(ptr, ...)

define i32 @main() {
  %y  = add i32 0, 5
  %t1 = add i32 3, 4
  %t2 = mul i32 %t1, %y
  %t3 = add i32 %t2, 0
  %x  = add i32 0, %t3
  %t4 = call i32 (ptr, ...) @printf(ptr @.str, i32 %x)
  ret i32 %x
}

