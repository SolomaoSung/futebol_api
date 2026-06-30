# %%
import pandas as pd
import sqlalchemy
import numpy as np
import mlflow
import matplotlib

mlflow.set_tracking_uri("http://localhost:5000")
mlflow.set_experiment(experiment_id=1)
# %%

con = sqlalchemy.create_engine("sqlite:///../../data/gold/database.db")
df_features = pd.read_sql("SELECT * FROM fs_all", con)
df_targets = pd.read_sql("SELECT * FROM fs_target", con)

# %%
df_merge = pd.merge(df_features, df_targets, on=["fixture_id", "team_id"])
df_merge['dt_game'] = pd.to_datetime(df_merge["dt_game"])
# %%
features = df_merge.columns.to_list()[4:-3]
targets = df_merge.columns.to_list()[-3:]

# %%
## OOT
df_oot = df_merge[df_merge['dt_game'] >= df_merge['dt_game'].max() - pd.Timedelta(days=10)].reset_index(drop=True)
X_oot = df_oot[features]
y_oot = df_oot[targets]
y_oot_single = np.argmax(y_oot, axis=1)

# %%
# Train/Test
df_train_test = df_merge[df_merge['dt_game'] < df_merge['dt_game'].max() - pd.Timedelta(days=10)].reset_index(drop=True)
X = df_train_test[features]
y = df_train_test[targets]

y = np.argmax(y, axis=1)

# %%


from sklearn import model_selection

X_train, X_test, y_train, y_test = model_selection.train_test_split(
    X, y, random_state=42, stratify=y, test_size=0.2
)
# %%
from feature_engine import imputation
input_0 = imputation.ArbitraryNumberImputer(arbitrary_number=0,
                                            variables=features)

# %%
print(f"Base Treino: {y_train.shape[0]} Unid.")
print(f"Base Teste: {y_test.shape[0]} Unid.")

# %%
import lightgbm as gbm
from sklearn import ensemble
model = gbm.LGBMClassifier(random_state=42)

params = {
    "n_estimators": [100,200,400,500,1000],
    "min_child_samples": [10, 20, 30],
    "learning_rate": [0.001, 0.01, 0.05, 0.1, 0.2, 0.5, 0.9, 0.99],
}

grid = model_selection.GridSearchCV(model,
                             param_grid=params,
                             cv=3,
                             scoring="roc_auc_ovr",
                             refit=True,
                             verbose=3)

# %%
from sklearn.pipeline import Pipeline

mlflow.sklearn.autolog()
with mlflow.start_run() as r:

    pipe = Pipeline([
        ("fill_na", input_0),
        ("Algoritmo", grid)
    ])

    pipe.fit(X_train, y_train)

    y_train_predict = pipe.predict(X_train)    
    y_train_predict_prob = pipe.predict_proba(X_train)

    y_test_predict = pipe.predict(X_test)    
    y_test_predict_prob = pipe.predict_proba(X_test)

    y_oot_predict = pipe.predict(X_oot)    
    y_oot_predict_prob = pipe.predict_proba(X_oot)

    from sklearn import metrics
    from sklearn.preprocessing import label_binarize

    y_train_bin = label_binarize(y_train, classes=[0,1,2])
    acc_train = metrics.accuracy_score(y_train, y_train_predict)
    auc_train = metrics.roc_auc_score(y_train_bin, y_train_predict_prob, average="macro", multi_class="ovr")

    print("Acurácia Treino:", acc_train)
    print("AUC Treino:", auc_train)

    y_test_bin = label_binarize(y_test, classes=[0,1,2])
    acc_test = metrics.accuracy_score(y_test, y_test_predict)
    auc_test = metrics.roc_auc_score(y_test_bin, y_test_predict_prob, average="macro", multi_class="ovr")

    print("Acurácia Teste:", acc_test)
    print("AUC Teste:", auc_test)

    y_oot_bin = label_binarize(y_oot_single, classes=[0,1,2])
    acc_oot = metrics.accuracy_score(y_oot_single, y_oot_predict)
    auc_oot = metrics.roc_auc_score(y_oot_bin, y_oot_predict_prob, average="macro", multi_class="ovr")

    print("Acurácia OOT:", acc_oot)
    print("AUC OOT:", auc_oot)

    


# %%
fpr = dict()
tpr = dict()
roc_auc = dict()

for i in range(3):  # número de classes
    fpr[i], tpr[i], _ = metrics.roc_curve(y_train_bin[:, i], y_train_predict_prob[:, i])
    roc_auc[i] = metrics.auc(fpr[i], tpr[i])
# %%
import matplotlib.pyplot as plt

for i in range(3):
    plt.plot(fpr[i], tpr[i], label=f'Classe {i} (AUC = {roc_auc[i]:.2f})')

plt.plot([0,1], [0,1], 'k--', label='Aleatório')
plt.xlabel('1 - Especificidade (FPR)')
plt.ylabel('Sensibilidade (TPR)')
plt.title('Curvas ROC - One vs Rest')
plt.legend()
plt.show()
# %%
fpr = dict()
tpr = dict()
roc_auc = dict()

for i in range(3):  # número de classes
    fpr[i], tpr[i], _ = metrics.roc_curve(y_test_bin[:, i], y_test_predict_prob[:, i])
    roc_auc[i] = metrics.auc(fpr[i], tpr[i])

import matplotlib.pyplot as plt

for i in range(3):
    plt.plot(fpr[i], tpr[i], label=f'Classe {i} (AUC = {roc_auc[i]:.2f})')

plt.plot([0,1], [0,1], 'k--', label='Aleatório')
plt.xlabel('1 - Especificidade (FPR)')
plt.ylabel('Sensibilidade (TPR)')
plt.title('Curvas ROC - One vs Rest')
plt.legend()
plt.show()
# %%
