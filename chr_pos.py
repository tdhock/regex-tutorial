from str_match import *
import pandas as pd

# In python we put the subjects in a list rather than the character
# vector we used in R.
subject_list = [
    "chr10:213,054,000-213,055,000",
    "chrM:111,000-222,000",
    "foo bar",
    "chr1:110-111 chr2:220-222"
    ]
subject_series = pd.Series(subject_list)

"foo\tbar"
r"foo\tbar"

# We can defined a compiled regular expression object using
# re.compile, and make it readable by breaking it over several lines
# using triple quotes and re.VERBOSE. Note that named groups in python
# use the (?P<name>pattern) syntax whereas in R we do not need the P.
# Also note that we use r""" """ to get a raw string (ignoring escapes).
pattern_greedy_stars = r"""
(?P<chrom>chr.*)
:
(?P<chromStart>.*)
-
(?P<chromEnd>.*)
"""
str_match(subject_list, pattern_greedy_stars)
subject_series.str.extract(pattern_greedy_stars, re.VERBOSE)

# greedy character class.
pattern_greedy_class = r"""
(?P<chrom>chr[0-9]+)
:
(?P<chromStart>[0-9,]+)
-
(?P<chromEnd>[0-9,]+)
"""
str_match(subject_list, pattern_greedy_class)
subject_series.str.extract(pattern_greedy_class, re.VERBOSE)

# negated character class (repetitive).
pattern_greedy_negated = r"""
(?P<chrom>chr[^:]+)
:
(?P<chromStart>[^-]+)
-
(?P<chromEnd>[^ ]*)
"""
str_match(subject_list, pattern_greedy_negated)
subject_series.str.extract(pattern_greedy_negated, re.VERBOSE)

# non-greedy.
pattern_not_greedy = r"""
(?P<chrom>chr.*?)
:
(?P<chromStart>.*?)
-
(?P<chromEnd>[0-9,]*)
"""
str_match(subject_list, pattern_not_greedy)
match_df = subject_series.str.extract(pattern_not_greedy, re.VERBOSE)
print match_df

# type conversion functions.
pattern_not_digit = r"[^0-9]"
rex_not_digit = re.compile(pattern_not_digit)
def keep_digits(s):
    only_digits, n_rep = rex_not_digit.subn("", s)
    return int(only_digits)

converters = {
    "chromStart":keep_digits,
    "chromEnd":keep_digits,
    }
str_match(subject_list, pattern_not_greedy, converters)

# pandas does not support NaN in .astype(int) so we must use float.
# http://pandas.pydata.org/pandas-docs/stable/gotchas.html#support-for-integer-na
def tofloat(series):
    return series.str.replace(pattern_not_digit, "").astype(float)

match_df["chromStart_float"] = tofloat(match_df["chromStart"])
match_df["chromEnd_float"] = tofloat(match_df["chromStart"])
print match_df

# str.findall returns an object series. each element is a list of
# tuples containing the match but with no names.
findall_series = subject_series.str.findall(pattern_not_greedy, re.VERBOSE)
print findall_series
print findall_series[0]
print findall_series[3]

# As of pandas 0.16.2 there is no str.extractall method which I expect
# should return a list of DataFrames, one for each subject. Exercise
# for the reader: fork pandas, add the str_extractall function to
# https://github.com/pydata/pandas/blob/master/pandas/core/strings.py,
# and submit them a
# PR. http://pandas.pydata.org/pandas-docs/stable/contributing.html

