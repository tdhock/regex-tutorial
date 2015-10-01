import re

def str_match(subjects, pattern, conversion_funs={}, flags=re.VERBOSE):
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


