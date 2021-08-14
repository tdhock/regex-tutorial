# https://pandas.pydata.org/docs/user_guide/reshaping.html#reshaping
import re
import pandas as pd
import altair as alt
from vega_datasets import data
iris_wide = data.iris()

chart = alt.Chart(iris_wide).mark_circle().encode(
    x="petalWidth",
    y="petalLength",
    color="species"
).interactive()
chart.save("iris_altair_no_facets.html")

# https://pandas.pydata.org/docs/reference/api/pandas.wide_to_long.html
iris_wide["id"] = iris_wide.index
iris_parts = pd.wide_to_long(iris_wide, ["petal", "sepal"], i="id", j="dim", sep="", suffix="(Width|Length)").reset_index()
chart = alt.Chart(iris_parts).mark_circle().encode(
    x="petal",
    y="sepal",
    color="species"
).facet(column="dim")
chart.save("iris_altair_facet_dim.html")
# seems like there is no way to specify equal
# aspect. https://github.com/altair-viz/altair/issues/1628

# also no geom_abline yet
# https://stackoverflow.com/questions/62854174/altair-draw-a-line-in-plot-where-x-y

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
