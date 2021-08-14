import pandas as pd
# https://pyjanitor.readthedocs.io/notebooks/Pivoting%20Data%20from%20Wide%20to%20Long.html
import janitor
import plotnine as p9
iris_url = "https://raw.github.com/pandas-dev/pandas/master/pandas/tests/io/data/csv/iris.csv"
iris_wide = pd.read_csv(iris_url)
# https://pyjanitor.readthedocs.io/reference/janitor.functions/janitor.pivot_longer.html
iris_long = iris_wide.pivot_longer(
    index="Name",
    names_pattern="(Sepal|Petal)(Length|Width)",
    names_to=["Part", "Dim"],
    values_to="cm")

gg_hist = p9.ggplot()+\
    p9.geom_histogram(
        p9.aes(x="cm", fill="Name"),
        iris_long,
        color="black", bins=20)+\
    p9.facet_grid("Part ~ Dim", labeller="label_both")
gg_hist.save("iris_p9_hist.png", width=5, height=5)

iris_parts = iris_wide.pivot_longer(
    index="Name",
    names_pattern="(Sepal|Petal)(Length|Width)",
    names_to=[".value", "Dim"])
gg_scatter_parts = p9.ggplot()+\
    p9.geom_abline(
        slope=1, intercept=0,
        color="grey")+\
    p9.geom_point(
        p9.aes(x="Sepal", y="Petal", fill="Name"),
        iris_parts)+\
    p9.facet_grid(". ~ Dim", labeller="label_both")+\
    p9.coord_equal()
gg_scatter_parts.save("iris_p9_scatter_parts.png", width=5, height=5)

iris_dims = iris_wide.pivot_longer(
    index="Name",
    names_pattern="(Sepal|Petal)(Length|Width)",
    names_to=["Part", ".value"])
gg_scatter_dims = p9.ggplot()+\
    p9.geom_abline(
        slope=1, intercept=0,
        color="grey")+\
    p9.geom_point(
        p9.aes(x="Length", y="Width", fill="Name"),
        iris_dims)+\
    p9.facet_grid(". ~ Part", labeller="label_both")+\
    p9.coord_equal()
gg_scatter_dims.save("iris_p9_scatter_dims.png", width=5, height=5)

