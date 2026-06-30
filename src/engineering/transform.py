# %%
import pandas as pd
import json
import sqlalchemy

# %%

class Transformer:

    def __init__(self, input_dbpath:str):
        self.input_dbpath = input_dbpath
        self.con = sqlalchemy.create_engine(f"sqlite:///{self.input_dbpath}")

    def to_dict(self, df:pd.DataFrame, cols:list)->pd.DataFrame:

        for col in cols:
            df[col] = df[col].apply(lambda x: json.loads(x) 
                                  if x is not None else x)
        return df
    
    def to_normalize(self, df:pd.DataFrame, cols:list)->pd.DataFrame:

        expanded = []
        for col in cols:
            expanded.append(pd.json_normalize(df[col].apply(
                            lambda x: x if isinstance(x, dict)
                            else x), sep="_").add_prefix(f"{col}_"))
            df = df.drop(columns=col)
        df = pd.concat([df] + expanded, axis = 1)
        return df
    
    def transform_table(self, table:str, cols:list)->pd.DataFrame:

        df = pd.read_sql(f"SELECT * FROM {table}", self.con)        
        df = self.to_dict(df, cols)
        df = self.to_normalize(df, cols)
        return df
# %%

