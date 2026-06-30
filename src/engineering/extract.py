# %%
import requests
import dotenv
import os
import pandas as pd
import json
import time
dotenv.load_dotenv()
API_KEY = os.getenv("SPORT_KEY")
# %%

class Extractor:

    def __init__(self, token:str):
        self.token = token
        self.headers = {
            'x-apisports-key':self.token
        }

    def to_parquet(self, df, type:str, league:str, season:str):
        path = f"../../data/raw/{type}"
        os.makedirs(path, exist_ok=True)
        df.to_parquet(f"{path}/{type}_{league}_{season}.parquet")
        
    def get_data(self, endpoint:str, params:dict):
        try:
            r = requests.get(url=f'https://v3.football.api-sports.io/{endpoint}',
                            headers=self.headers, 
                            params=params,
                            timeout=30)
            
            r.raise_for_status()

        except requests.exceptions.RequestException as err:
            raise RuntimeError(
                f"Erro ao consultar endpoint {endpoint}"
            ) from err

        results = r.json()
        if "response" not in results:
            raise ValueError("Resposta inválida da API")
        return results
    
    def process_fixture(self, league:str, season:str):
        params = {
            "league":league,
            "season":season
        }
        attempt = 0
        
        while attempt < 3:
            results = self.get_data(endpoint="fixtures", params=params)

            if results and results.get("response"):
                df = pd.DataFrame(results['response'])
                cols = df.columns.to_list()
                for col in cols:
                    df[col] = df[col].apply(lambda x: json.dumps(x, ensure_ascii=False)
                                            if isinstance(x, (dict,list)) else x)
                df["ingestion_timestamp"] = pd.Timestamp.now()
                df["season"] = season
                self.to_parquet(df=df, type="fixtures", league=league, season=season)
                return

            attempt += 1
            print(f"""Tentativa {attempt} falhou para liga {league} season {season}.
                  Tentando novamente...""")
            time.sleep(3)
            
        print(f"Erro: Sem fixture para liga {league} season {season}")

    def process_standing(self, league:str, season:str):
        params = {
            "league":league,
            "season":season
        }
        attempt = 0
        while attempt < 3:
            results = self.get_data(endpoint="standings", params=params)

            if results and results.get("response"):
                results = results["response"][0]["league"]["standings"][0]
                df = pd.DataFrame(results)
                
                columns = ['team', 'all', 'home', 'away']
                for col in columns:
                    df[col] = df[col].apply(lambda x: json.dumps(x, ensure_ascii=False))

                df["ingestion_timestamp"] = pd.Timestamp.now()
                df["league_id"] = league
                df["season"] = season

                self.to_parquet(df=df, type="standings", league=league, season=season)
                return

            attempt += 1
            print(f"""Tentativa {attempt} falhou para liga {league} season {season}.
                  Tentando novamente...""")
            time.sleep(3)
        print(f"Erro: Sem standings para liga {league} season {season}.")

    def process_injuries(self, league, season):
        params = {
            "league": league,
            "season": season
        }
        attempt = 0
        
        while attempt < 3:
            results = self.get_data(endpoint="injuries", params=params)

            if results and results.get("response"):
                df = pd.DataFrame(results['response'])
                cols = df.columns.to_list()
                for col in cols:
                    df[col] = df[col].apply(lambda x: json.dumps(x, ensure_ascii=False)
                                            if isinstance(x, (dict,list)) else x)
                df["ingestion_timestamp"] = pd.Timestamp.now()
                df["season"] = season
                self.to_parquet(df=df, type="injuries", league=league, season=season)
                return

            attempt += 1
            print(f"""Tentativa {attempt} falhou para liga {league} season {season}.
                  Tentando novamente...""")
            time.sleep(3)
            
        print(f"Erro: Sem injuries para liga {league} season {season}")

    def process(self, league, season):
        self.process_fixture(league, season)
        self.process_injuries(league, season)
        self.process_standing(league, season)

# %%
if __name__ == "__main__":
    e = Extractor(API_KEY)

    seasons = ["2022", "2023", "2024"]

    for s in seasons:
        e.process_standing("39", s)


# %%
headers = {
    "x-apisports-key": API_KEY
}
params = {
            "league":39,
            "season":2024
        }
r = requests.get(url=f'https://v3.football.api-sports.io/players',
                            headers=headers, 
                            params=params,
                            timeout=30)
# %%
r.json()
# %%
