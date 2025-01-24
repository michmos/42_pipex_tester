# 42 pipex tester
This is a tester for the project `pipex` from the ecole 42 core curriculum. It is designed to facilitate the addition of your own custom test cases.

> This tester is written **for linux**. There might be issues if you use a different OS :exclamation:

> If the tester helps you, leave a star on github to make it more visible for others :star:

> If you find a bug, send me a message on slack please (@mmoser) :email:

## Usage
### Download
Clone the repository **into your pipex directory**:
```
git clone https://github.com/michmos/42_pipex_tester.git && cd 42_pipex_tester
```
Alternatively, you can clone it elsewhere and adjust the relative path inside `run.sh`.

Ensure you have a Makefile in place and that your program compiles to `pipex` (also the bonus, in case you did it).

### Run
Run the tester like this:
```
bash run.sh
```

The behaviour can be modified by adding ONE of the following flags:
| Flag              | Meaning                                                              | 
| ----------------- | -------------------------------------------------------------------- |
| `--help`          | display all flags and their usage                                    |
| `--hide-err-log`  | hide error log                                                       |
| `--show-valgrind` | show valgrind output for tests cases where valgrind found an error   |

e.g.:
```
bash run.sh --show-valgrind
```

## Layout
![visualization](https://github.com/michmos/42_pipex_tester/assets/141367977/290d866f-3c3e-4c7d-84c5-2392036d4a15)
The tester compares your program with the original shell piping in terms of:
* **output** to the specified file
* **exit status**
* **time** - differences here may indicate that your parent is not waiting for all children to terminate
* **leaks** in the parent


## Adapt
Test cases can easily be added to  `run.sh`  following the same structure as the existing ones.
Two variables are available for customization:
* `LEAKS_ONLY`: if set to 1, all subsequent test cases will only be checked for leaks and fatal errors, until it is reset to 0. This is especially useful for test cases that have no equivalent in bash
* `HERE_DOC`: a string used as input for here_doc. Ensure it ends with a \n

If a test case receives less than 4 arguments without setting LEAKS_ONLY to 0, an error message will be displayed as the subject doesn't clarify how to handle these cases - naturally, your program shouldn't crash.
