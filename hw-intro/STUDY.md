# HW 0: Understanding Check

These questions are written by the maintainers of this repository, not the
CS 162 staff. They are designed to test whether you understand the *why*
behind HW 0, not just whether your code compiles. Try to write your own
answer first; the collapsed answer is a sanity-check, not a substitute.

## 1. The starter `main.c` for the word-count program declares `FILE *infile = NULL;` and triggers `-Werror=unused-but-set-variable`. What does this hint at about the structure of `main` you are expected to write?

<details><summary>Answer</summary>

The skeleton is telling you that your finished `main` is supposed to *use*
`infile` — i.e. for each positional argument you should open the file with
`fopen`, assign the result to `infile`, run the count/frequency helpers on
it, and close it. Until your code actually consumes that variable in every
control-flow path, the compiler refuses to build. The error is a hint, not
a bug to silence with `__attribute__((unused))`.

</details>

## 2. `count_words` is supposed to "return 1 in the event of any errors and 0 otherwise" per the comment. Why is this convention different from the usual C "return 0 on success" used by `main`?

<details><summary>Answer</summary>

`count_words` is a *library* function, not a process exit. The CS 162 style
for these helpers is closer to a boolean: returns 0 when the work
completed, returns 1 (or any non-zero) when something failed. The caller
treats the return value as `if (count_words(...)) { /* handle */ }`.
Process exit codes follow the opposite convention because the shell
expects 0 for success.

</details>

## 3. After you finish `words`, running it on `/dev/urandom` would loop forever. Why? What change would make it safe?

<details><summary>Answer</summary>

`fgetc` returns successfully until it sees `EOF`, and `/dev/urandom` never
produces `EOF` — it streams bytes forever. The word-count helpers loop
"until EOF", so they never terminate. The fix is to add an upper bound (a
maximum-word-length check, a max-total-words limit, or a read timeout) or
to refuse non-regular files at the `fopen` boundary using `fstat`.

</details>

## 4. `map.c` prints addresses of stack, heap, globals, and code. On modern Linux those addresses change every run. What feature is responsible, and what flag could you pass to `./map` to make the addresses stable for a debugging session?

<details><summary>Answer</summary>

Address-space layout randomization (ASLR) randomizes the base of the stack,
heap, shared libraries, and (under PIE) the executable on every exec. You
can disable it for a single process with `setarch $(uname -m) -R ./map`,
or globally (root) with `echo 0 > /proc/sys/kernel/randomize_va_space`.
Disable only while debugging — production processes benefit from ASLR.

</details>

## 5. `limits` reports the max number of open file descriptors. Why is the *soft* limit usually below the *hard* limit, and which one matters for `open()`?

<details><summary>Answer</summary>

The soft limit is the value the kernel enforces against the process; the
hard limit is the ceiling that an unprivileged process may raise the soft
limit to. `open()` and friends compare against the soft limit, so that is
what you actually want when sizing how many sockets / files you can hold
open. `setrlimit` lets you raise the soft up to the hard; only root can
raise the hard.

</details>

## 6. Why does the assignment specify case-insensitive frequency counts? What goes wrong if you fold case after inserting into the list instead of before?

<details><summary>Answer</summary>

Folding case at insertion time keeps a single canonical entry per word, so
`Hello` and `HELLO` both increment the same `WordCount`. Folding after
insertion means the list has separate `Hello`, `HELLO`, and `hello`
entries that need to be merged in a second pass — which doubles your code
and creates a subtle aliasing bug if two iterators are walking the list at
once. Convert each character with `tolower` *before* `add_word`.

</details>

## 7. The handout suggests using `valgrind ./words ...` to check for leaks. What free-list bug in `free_words` does `valgrind` *not* catch?

<details><summary>Answer</summary>

`valgrind --leak-check=full` flags memory you never freed and writes to
freed memory, but it does not flag a *use-after-free where the freed value
was overwritten* — for example, `free(w->word); w->word = strdup("x");`
followed by `free(w->word)` again is a use-after-free at the value level
but not at the pointer level. `valgrind` also does not flag logic errors
like freeing a list but leaving a dangling pointer in a caller. For those,
use AddressSanitizer (`-fsanitize=address`) or audit the call graph
manually.

</details>
