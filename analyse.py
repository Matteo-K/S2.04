#!/usr/bin/env -S python3 -i
import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression


def start_operation(name: str) -> None:
    print(name+'...', end='', file=sys.stderr)


def end_operation(status: str) -> None:
    print(status, file=sys.stderr)


def Centreduire(T):
    T = np.array(T, dtype=np.float64)  # données ne sont pas de type float donc cette ligne le change
    (n, p) = T.shape
    Moyennes = np.mean(T, 0)
    EcartTypes = np.std(T, 0)
    Res = np.eye(n, p)
    for j in range(p):
        Res[:, j] = (T[:, j]-Moyennes[j])/(1 if EcartTypes[j] == 0 else EcartTypes[j])
    return Res


def DiagBatons(colonne, nom_image: str, titre: str):
    min = sys.maxsize  # taille minimum
    Max = -sys.maxsize - 1  # taille maximum
    for i in colonne:
        if min > i:
            min = i
        if Max < i:
            Max = i
    inter = np.linspace(min, Max, num=21)
    print("\n", list(inter))
    x = [i*20 for i in range(20)]
    plt.figure()
    plt.title(titre)
    plt.hist(colonne, inter, histtype="bar", color="g")
    plt.savefig(nom_image)


def save_bar(x, y, title: str, out: str):
    fig, ax = plt.subplots()
    ax: plt.Axes
    ax.bar(x, y)
    plt.xticks(rotation=20, ha='right')
    ax.set_title(title)
    fig.savefig(out)


# Import des données
start_operation('Import des données')

CollegesDF = pd.read_csv("Colleges.csv")
CollegesDF = CollegesDF.dropna()  # to fix nan :supprime les lignes ayant des cases vides, sans changer le nom des lignes conservées

CollegesAr = np.delete(CollegesDF.to_numpy(), 0, axis=1)  # enlève la colonne uai car elle n'est pas numérique
CollegesAr_CR = Centreduire(CollegesAr)

CollegesAr0 = CollegesAr[:, 1:]  # enlever la variable endogène
CollegesAr0_CR = Centreduire(CollegesAr0)

end_operation('ok')

# Exploration des données
# représentations graphiques


def diag_batons():
    start_operation('Création du diagramme en bâtons')

    for data, col in zip(CollegesAr.transpose(), CollegesDF.columns.drop('uai')):
        DiagBatons(data, f"out/baton_{col}.png", f"Effectifs {col}")

    end_operation('ok')

# matrice de covariance


start_operation('Matrice de coviariance')

MatriceCov = np.cov(CollegesAr0_CR, rowvar=False)

end_operation('ok')

# Régression linéaire multiple

start_operation('Calcul de la régression linéaire')

linear_regression = LinearRegression()
x, y = CollegesAr0_CR, CollegesAr_CR[:, 0]
linear_regression.fit(x, y)
regression_coefs = linear_regression.coef_
regression_score = linear_regression.score(x, y)

end_operation('ok')

def y_pred(i):
    return sum(regression_coefs * CollegesAr0_CR[i])

def test_performance_prediction():
    from statistics import mean, median
    diff = [y_pred(i) - CollegesAr_CR[i, 0] for i in range(len(CollegesAr0_CR))]
    print('Différence moyenne entre y et y_pred :', mean(diff))
    print('Différence médiane entre y et y_pred :', median(diff))
