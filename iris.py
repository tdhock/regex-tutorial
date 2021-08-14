import pandas as pd
import matplotlib.pyplot as plt
plt.ion()
import altair
from vega_datasets import data
iris_df = data.iris()
import re
# https://pandas.pydata.org/docs/user_guide/reshaping.html#reshaping
iris_url = "https://raw.github.com/pandas-dev/pandas/master/pandas/tests/io/data/csv/iris.csv"
iris_wide = pd.read_csv(iris_url)
# https://pandas.pydata.org/docs/reference/api/pandas.wide_to_long.html
iris_wide["id"] = iris_wide.index
iris_parts = pd.wide_to_long(iris_wide, ["Petal", "Sepal"], i="id", j="dim", sep="", suffix="(Width|Length)")
iris_parts.plot.scatter("Petal", "Sepal", by="dim")

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
# https://pandas.pydata.org/docs/reference/api/pandas.melt.html -> one
# output reshape column.

# https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.stack.html
# -> all input columns are considered reshape, one output reshape
# column.
mi = pd.MultiIndex.from_frame(d.columns.str.extract(pattern))
di = pd.DataFrame(d, columns=mi)
