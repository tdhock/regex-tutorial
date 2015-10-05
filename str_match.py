import re

def str_match_named(subjects, pattern, conversion_funs={}, flags=re.VERBOSE):
    compiled = re.compile(pattern, flags)
    match_dict_list = []
    for s in subjects:
        match = compiled.match(s)
        if match:
            match_dict = match.groupdict()
            for key, val in conversion_funs.iteritems():
                if key in match_dict:
                    convert = conversion_funs[key]
                    match_dict[key] = convert(match_dict[key])
            match_dict_list.append(match_dict)
        else:
            match_dict_list.append({})
    return match_dict_list

# Exercise for the reader: implement a python function
# str_match_all_named, with features analogous to the R function.

if __name__ == "__main__":
    # If this module is invoked on the command line, run the following
    # demo:
    subject_list = [
        "chr10:213,054,000-213,055,000",
        "chrM:111,000-222,000",
        "foo bar",
        "chr1:110-111 chr2:220-222"
        ]
    pattern = r"""
(?P<chrom>chr.*?)
:
(?P<chromStart>.*?)
-
(?P<chromEnd>[0-9,]*)
"""
    pattern_not_digit = r"[^0-9]"
    rex_not_digit = re.compile(pattern_not_digit)
    def keep_digits(s):
        only_digits, n_rep = rex_not_digit.subn("", s)
        return int(only_digits)
    cfuns = {
        "chromStart":keep_digits,
        "chromEnd":keep_digits,
        }
    print str_match_named(subject_list, pattern, cfuns)

