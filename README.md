# berkut_test

Test task solution for berkut. Imitates an assembly line interface.

## Implementation notes

I chose asynchronous architecture, because I have assumed that the mechanisms are external remote devices and you 
need to wait for them to finish execution. If they are just a code abstraction and a part of the same program, I 
would have consider using threading.

### Project structure

- `assembly_line.lua` contains the main logic of the line itself.

- There is no advanced async/await in pure Lua, so I wrote a minimalistic module `async.lua` to implement some basic
constructions.

- `lib/` contains external libraries. I used only cosmetic ones: `inspect` displays any tables (improves usability of the shell) and `log` adds timestamps and log levels to the assembly line output.

- `main.lua` is a main script for launching the line.

- `shell.lua` is for handling errors occuring in assembly line by a live operator

- `shifting_array.lua` handles shifting in O(1) time. Irrelevant in most cases, but useful if the line becomes long and the mechanisms work very fast.

- `spec/` is a folder for automated tests.

- `tools.lua` contains general purpose utilities.

## Running tests

Tests are based on [busted](https://lunarmodules.github.io/busted/) testing framework.

Installation:

```bash
sudo luarocks install busted
```

Launch:

```bash
busted
```
