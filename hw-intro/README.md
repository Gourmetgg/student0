HW 0: Intro
===========

Official reference:

- <https://cs162.org/static/hw/hw-intro/>
- <https://cs162.org/static/hw/hw-intro/docs/counting-words/>

Assignment goals
----------------

This homework is the CS 162 warm-up for C programming and Unix development. It
exercises compilation with `make`, command-line tools, resource limits, memory
layout, debugging, and a small word-count program.

The word-count portion follows the official `hw-intro/words` task shape:
implement the counting helpers, free all allocated structures, and make the
main program handle one or more input files and command-line output modes.

Key implementation areas
------------------------

- `limits.c`: inspect and print process resource limits with real values.
- `map.c` and `recurse.c`: observe process memory layout, stack growth, heap
  allocation, and recursive stack behavior.
- `words/main.c`: parse flags, open input streams, combine file results, and
  choose output format.
- `words/word_count.c`: implement `num_words`, `count_words`, and
  `free_words`.
- `words/gutenberg/`: larger text inputs for manual stress checks.

Build and run
-------------

```sh
cd hw-intro
make
./limits
./map

cd words
make
./words -h
./words -c words.txt
./words -f words.txt
./words -c gutenberg/alice.txt
```

Current test inventory
----------------------

No checked-in automated test harness was found for this homework. The current
coverage is manual smoke testing only:

- Compile `limits`, `map`, and `words`.
- Run `limits` and inspect whether the output is plausible.
- Run `map` and inspect whether stack, heap, globals, and code addresses are
  distinguishable.
- Run `words` on sample files and compare output by hand.

Completeness assessment
-----------------------

Coverage is incomplete. The official homework expects several behaviors that
should be asserted automatically:

- `words` should count words accurately for file input.
- Frequency output should be deterministic enough to compare against expected
  content after sorting if the program order is not specified.
- Multiple input files should be processed as one combined stream.
- Stdin behavior should work when no file path is supplied or when the chosen
  mode expects stream input.
- Empty files, missing files, invalid flags, punctuation, repeated words, and
  case behavior should be tested.
- `limits` and `map` need shape checks so placeholder or all-zero output is
  caught early.

Detailed missing-test prompts
-----------------------------

1. Add `words/tests/basic.txt`:

   ```text
   hello hello world
   systems world hello
   ```

   Add expected checks:

   - `./words -c tests/basic.txt` should report `6` total words.
   - `./words -f tests/basic.txt` should include `hello` with count `3`,
     `world` with count `2`, and `systems` with count `1`.
   - If output order can vary, normalize with `sort` before comparing.

2. Add `words/tests/punctuation.txt`:

   ```text
   Hello, hello! HELLO?
   cs-162 cs162
   ```

   The test should document the expected tokenizer policy. If punctuation is a
   separator and case is preserved, check those exact tokens. If case is folded,
   check the folded counts. This fixture prevents silent changes to token
   parsing.

3. Add `words/tests/multifile_a.txt` and `words/tests/multifile_b.txt`:

   ```text
   alpha beta
   ```

   ```text
   beta gamma gamma
   ```

   Test command:

   ```sh
   ./words -f tests/multifile_a.txt tests/multifile_b.txt
   ```

   Expected content: `alpha: 1`, `beta: 2`, `gamma: 2`.

4. Add stdin coverage:

   ```sh
   printf "one two one\n" | ./words -f
   ```

   Assert `one: 2` and `two: 1`. This catches programs that only work when
   `fopen` succeeds on a path.

5. Add failure-mode coverage:

   ```sh
   ./words -z tests/basic.txt
   ./words -c tests/does-not-exist.txt
   ```

   Assert a non-zero exit status and a useful error message on stderr.

6. Add `limits` sanity coverage in `hw-intro/test_intro.sh`:

   - Run `./limits`.
   - Fail if the output is empty.
   - Fail if every numeric field is `0`.
   - Fail if expected limit names such as stack, file size, or address space are
     missing.

7. Add `map` shape coverage:

   - Run `./map`.
   - Assert that it prints labels for stack, heap, globals, and code/text.
   - Assert that address-looking values are present.
   - Avoid hard-coding exact addresses because ASLR makes them unstable.

Suggested `make test` target
----------------------------

Add a `test` target that calls a script such as `tests/run_hw_intro_tests.sh`.
That script should rebuild the homework, run the fixture tests, normalize output
where needed, and return a non-zero exit status on the first failure.
