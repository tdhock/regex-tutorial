import re

# In a regular string, the python interpreter treats the backslash as
# an escape, and so does not actually put a backslash in the
# string. In the example below the \n is converted to a newline by the
# python interpreter. This is the same behavior as the R interpreter.
contains_newline = "foo\nbar"
contains_newline

# In R, writing "print(x)" shows the same thing as just "x" on the
# command line. In python writing "x" and "print x" do not show the
# same thing, beware!
print contains_newline
print repr(contains_newline)
print eval(repr(contains_newline))

# You can put newlines directly in a triple-quoted string. In R you
# can also use newlines in string literals, but there is no need for
# triple quotes.
also_contains_newline = """foo
bar"""
also_contains_newline
assert contains_newline == also_contains_newline

# r" " is for a raw string in which backslashes are treated literally
# by the python interpreter. There are no raw strings in R.
contains_backslash = r"foo\nbar"
contains_backslash
assert contains_backslash != contains_newline

# You can create a string with backslashes using a non-raw string
# literal, but it requires more backslashes.
also_contains_backslash = "foo\\nbar"
assert contains_backslash == also_contains_backslash

# To get a regular expression that matches a newline, you can use
# either \n or a literal newline.
subject = """this is some long text foo
bar suffix
sars"""
re_backslash = re.compile(contains_backslash)
re_newline = re.compile(contains_newline)
re_backslash.search(subject)
re_newline.search(subject)

# Raw strings and triple quotes are useful for constructing readable
# regular expressions. Note that named groups in python use the
# (?P<name>pattern) syntax whereas in R we do not need the P.
contains_both = r"""
(?P<before_newline>foo) # this is readable.
\n
(?P<after_newline>bar)
"""
contains_both # not very readable.

# When used with re.VERBOSE, this regular expression matches the same
# thing as the others above.
print re.search(contains_both, subject, re.VERBOSE).groupdict()

# If this regular expression will be used repeatedly on several
# subjects, it is faster to compile it once and then used the compiled
# object to do the matching.
verbose_compiled = re.compile(contains_both, re.VERBOSE)
print verbose_compiled.search(subject).groupdict()

