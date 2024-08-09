## Clayton Compiler
Implementation of a C Compiler written in Zig, following the book [Writing a C Compiler: Build a Real Programming Language from Scratch - Nora Sandler](https://www.amazon.com/Writing-Compiler-Programming-Language-Scratch/dp/1718500424)

#### Usage

1. Clone the repo

2. Build the compiler (make sure to have Zig installed)

```zsh
zig build
```

3. Use it to compile a C program
```zsh
./zig-out/bin/c-compiler main.c
```
