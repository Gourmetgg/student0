HW 1: Lists
===========

Official reference:

- <https://cs162.org/static/hw/hw-list/>
- <https://cs162.org/static/hw/hw-list/docs/pwords/>

Assignment goals
----------------

This homework introduces the Pintos intrusive linked-list implementation and
uses it in a word-count program. It also introduces basic pthread programming:
the `pwords` executable should spawn worker threads, process input files in
parallel, and wait for all workers before printing the final result.

Key implementation areas
------------------------

- `list.c` and `list.h`: Pintos list primitives and ownership conventions.
- `word_count_l.c`: list-backed word-count storage.
- `word_count_p.c`: thread-aware word-count storage and synchronization.
- `pwords.c`: create one thread per input file and join every spawned thread.
- `pthread.c`: smaller pthread practice program.
- `gutenberg/`: larger input files for comparison and stress testing.

Build and run
-------------

```sh
cd hw-list
make
./pthread 4
./words gutenberg/alice.txt
./lwords gutenberg/alice.txt
./pwords gutenberg/alice.txt gutenberg/sawyer.txt
```

Manual comparison:

```sh
./words gutenberg/alice.txt > /tmp/words.out
./lwords gutenberg/alice.txt > /tmp/lwords.out
./pwords gutenberg/alice.txt > /tmp/pwords.out
diff -u /tmp/words.out /tmp/lwords.out
diff -u /tmp/words.out /tmp/pwords.out
```

Current test inventory
----------------------

No checked-in automated test harness was found for this homework. The current
manual checks compare the reference `words` program against `lwords` and
`pwords` on larger text files.

Completeness assessment
-----------------------

Coverage is incomplete. The official homework centers on data-structure
correctness and thread correctness, so tests should cover both deterministic
word-count behavior and race-prone parallel behavior:

- `lwords` should match the reference output for all fixtures.
- `pwords` should match the reference output for one file and many files.
- The main `pwords` thread should always join workers before output.
- Shared word-count state should not lose increments under concurrent updates.
- List nodes should be inserted, searched, sorted, and freed without leaks.

Detailed missing-test prompts
-----------------------------

1. Add deterministic fixtures under `tests/fixtures/`:

   - `empty.txt`: empty file.
   - `single.txt`: `alpha beta alpha`.
   - `case_punctuation.txt`: `Apple apple, APPLE!`
   - `many.txt`: repeat 100 to 1,000 words with known counts.

   For every fixture, run:

   ```sh
   ./words tests/fixtures/single.txt > /tmp/ref.out
   ./lwords tests/fixtures/single.txt > /tmp/lwords.out
   ./pwords tests/fixtures/single.txt > /tmp/pwords.out
   diff -u /tmp/ref.out /tmp/lwords.out
   diff -u /tmp/ref.out /tmp/pwords.out
   ```

2. Add multi-file `pwords` coverage:

   ```sh
   ./words tests/fixtures/a.txt tests/fixtures/b.txt > /tmp/ref.out
   ./pwords tests/fixtures/a.txt tests/fixtures/b.txt > /tmp/pwords.out
   diff -u /tmp/ref.out /tmp/pwords.out
   ```

   The fixture should include the same word in both files so lost increments are
   visible.

3. Add a repeated race test:

   ```sh
   for i in $(seq 1 100); do
     ./pwords tests/fixtures/many.txt tests/fixtures/many.txt > /tmp/run.out
     diff -u /tmp/expected_twice.out /tmp/run.out
   done
   ```

   This catches missing locks, early printing before joins, and shared-list
   corruption that only appears intermittently.

4. Add argument and failure tests:

   - `./pwords` with no input should follow the documented behavior.
   - `./pwords tests/fixtures/missing.txt` should return non-zero and print a
     useful error.
   - A mix of valid and invalid files should not leak threads or hang.

5. Add memory-check instructions:

   ```sh
   valgrind --leak-check=full ./lwords tests/fixtures/many.txt
   valgrind --leak-check=full ./pwords tests/fixtures/many.txt tests/fixtures/many.txt
   ```

   These checks should confirm that list entries and word strings are released
   exactly once.

6. Add targeted list-unit tests if a small harness is acceptable:

   - Insert several entries and confirm list order.
   - Search for present and absent words.
   - Increment an existing word without inserting a duplicate.
   - Free a non-empty list and an empty list.

Suggested `make test` target
----------------------------

Add `make test` to rebuild the executables, run the fixture comparison script,
and optionally run the repeated race loop when `STRESS=1` is set.
