# %%
import pandas as pd
import sqlalchemy
import os
# %%

class Sender:

    def process_file(self, filename:str, db_path:str):
        con = sqlalchemy.create_engine(f"sqlite:///{db_path}/database.db")
        table = db_path.split("/")[-1]
        filedir = filename.split("_")[0]
        df = pd.read_parquet(f"../../data/raw/{filedir}/{filename}")
        df.to_sql(f"{table}_{filedir}", con, if_exists="replace", index=False)
    
    def process_folder(self, dir:str, db_path:str):
        files = [f for f in os.listdir(dir) if f.endswith(".parquet")]
        for f in files:
            self.process_file(f, db_path)
    
    def process_df(self, df:pd.DataFrame, table:str, db_path:str):
        os.makedirs(db_path, exist_ok=True)
        app = sqlalchemy.create_engine(f"sqlite:///{db_path}/database.db")
        df = df.drop_duplicates()
        df.to_sql(table, app, if_exists="append", index=False)

# %%

if __name__ == "__main__":
    s = Sender("../../data/raw/futebol.db")
    s.process_folder("../../data/raw/fixtures")
# %%
