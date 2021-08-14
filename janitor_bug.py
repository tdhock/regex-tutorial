import pandas as pd
import janitor
d=pd.DataFrame({"Petal.Width":[1], "Sepal.Width":[2], "Petal.Length":[3], "Species":"setosa", "Sepal.Length":[4]})
d.pivot_longer(column_names = ["Petal.Width", "Sepal.Width","Petal.Length","Sepal.Length"], names_pattern="(.*)[.](.*)", names_to=["part", "dim"])
d.pivot_longer(names_pattern="(.*)[.](.*)", names_to=["part", "dim"])
