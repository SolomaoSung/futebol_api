# %%
from extract import Extractor
from send import Sender
from transform import Transformer
import dotenv
import os
import time
from config import CONFIG

dotenv.load_dotenv()
API_KEY = os.getenv("SPORT_KEY")
# %%

def main(leagues:list, seasons:list):
    e = Extractor(API_KEY)

    for l in leagues:
        for s in seasons:
            print(f"Extraindo dados da liga {l} season {s}...")
            e.process(l, s)
            time.sleep(10)

    s = Sender()

    print("Enviando dados para database...")
    s.process_folder(dir =  "../../data/raw/fixtures", db_path = "../../data/bronze")
    s.process_folder(dir =  "../../data/raw/injuries", db_path = "../../data/bronze")
    s.process_folder(dir = "../../data/raw/standings", db_path = "../../data/bronze")

    t = Transformer("../../data/bronze/database.db")

    print("Transformando dados bronze...")
    for table, cfg in CONFIG.items():
        df = t.transform_table(table=table, 
                           cols=cfg["json_cols"]) 
    
        name = table.split("_")[1]
        print(f"Enviando dados {name} para database...")
        s.process_df(df, f"silver_{name}", db_path="../../data/silver")
    print("Dados enviados para database silver.")
    
    
# %%
seasons = ["2022", "2023", "2024"]

main(leagues=["2", "39", "78", "140"], seasons=seasons)

# %%
