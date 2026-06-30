# %%
import argparse
import sqlalchemy
import os
import pandas as pd
# %%

def import_query(path):
    with open(path) as open_file:
        query = open_file.read()
    return query

def exec_query(table, db_origin, db_target):
    con = sqlalchemy.create_engine(f"sqlite:///../../data/{db_origin}/database.db")
    os.makedirs(f"../../data/{db_target}", exist_ok=True)
    app = sqlalchemy.create_engine(f"sqlite:///../../data/{db_target}/database.db")
    
    query = import_query(f"{table}.sql")
    with con.connect() as con_origin:
        df = pd.read_sql(query, con_origin)

    with app.connect() as con_target:
        df.to_sql(f"{table}", con_target, index=False, if_exists="replace")

# %%
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base_tables", type=str, nargs="+",
                        default=["fs_union", "fs_injuries"])
    parser.add_argument("--table", type=str, nargs="+",
                        default=["fs_historical", "fs_h2h", 
                                 "fs_rolling", "fs_target"])
    parser.add_argument("--db_origin", default="silver")
    parser.add_argument("--db_target", default="gold")

    args = parser.parse_args()

    for base_tb in args.base_tables:
        exec_query(base_tb, args.db_origin, args.db_target)

    for table in args.table:
        exec_query(table, "gold", args.db_target)


if __name__ == "__main__":
    main()
# %%
