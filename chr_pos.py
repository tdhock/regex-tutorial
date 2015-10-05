import pandas as pd
import re

# Subjects are specified as a list or a pandas Series.
subject_list = [
    "chr10:213,054,000-213,055,000",
    "chrM:111,000-222,000",
    "foo bar",
    None,
    "chr1:110-111 chr2:220-222"
    ]
subject_series = pd.Series(subject_list)

# too greedy, wrong answer on last subject.
pattern_greedy_stars = r"""
(?P<chrom>chr.*)
:
(?P<chromStart>.*)
-
(?P<chromEnd>.*)
"""
subject_series.str.extract(pattern_greedy_stars, re.VERBOSE)

# greedy character class, wrong answer on chrM subject.
pattern_greedy_class = r"""
(?P<chrom>chr[0-9]+)
:
(?P<chromStart>[0-9,]+)
-
(?P<chromEnd>[0-9,]+)
"""
subject_series.str.extract(pattern_greedy_class, re.VERBOSE)

# negated character class, right answer but repetitive.
pattern_greedy_negated = r"""
(?P<chrom>chr[^:]+)
:
(?P<chromStart>[^-]+)
-
(?P<chromEnd>[^ ]*)
"""
subject_series.str.extract(pattern_greedy_negated, re.VERBOSE)

# non-greedy, right answer.
pattern_not_greedy = r"""
(?P<chrom>chr.*?)
:
(?P<chromStart>.*?)
-
(?P<chromEnd>[0-9,]*)
"""
match_df = subject_series.str.extract(pattern_not_greedy, re.VERBOSE)
print match_df

# pandas does not support NaN in .astype(int) so we must use float.
# http://pandas.pydata.org/pandas-docs/stable/gotchas.html#support-for-integer-na
def tofloat(series):
    return series.str.replace(r"[^0-9]", "").astype(float)

match_df["chromStart_float"] = tofloat(match_df["chromStart"])
match_df["chromEnd_float"] = tofloat(match_df["chromStart"])
print match_df

# str.findall returns an object series. each element is a list of
# tuples containing the match but with no names.
findall_series = subject_series.str.findall(pattern_not_greedy, re.VERBOSE)
print findall_series
print findall_series[0]
print findall_series[3]

