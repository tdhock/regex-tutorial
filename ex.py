import pandas as pd
import re
d=pd.DataFrame({"Petal.Width":[1], "Sepal.Width":[2], "Petal.Length":[3], "Species":"setosa"})
d=pd.DataFrame({"Petal.Width":[1], "Sepal.Width":[2], "Petal.Length":[3], "Species":"setosa", "Sepal.Length":[4]})
d["id"] = d.index
pd.wide_to_long(d, ["Petal", "Sepal"], i="id", j="dim", sep=".", suffix="(Width|Length)")
pattern = re.compile("(?P<part>.*)[.](?P<dim>.*)")
def my_rename(x):
    m = pattern.match(x)
    if m is None:
        return x
    else:
        return "%(dim)s_%(part)s" % m.groupdict()
d2 = d.rename(columns=my_rename)
pd.wide_to_long(d2, ["Width", "Length"], i="id", j="dim", sep="_", suffix="(Petal|Sepal)")
d.melt(value_vars=[x for x in d.columns if pattern.match(x)])
