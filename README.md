# CineNight

## Introduzione al progetto

**CineNight** è un'app interamente sviluppata in **Flutter** che permette di esprimere la passione per il cinema e condividerla con gli amici, permettendo di creare e condividere recensioni e, allo stesso tempo, organizzare serate a tema cinema, suggerendo film tramite apposite API sempre aggiornate sul mondo del cinema.

## Obiettivi

L'obiettivo principale è quello di produrre un'applicazione che permetta di organizzare con gli amici serate a tema cinema in modo facile e veloce, integrando all'interno di una chat di gruppo la possibilità di gestire e proporre film da vedere tramite una API pubblica chiamata [TMDB](https://www.themoviedb.org/). Inoltre, permette di recensire film e condividere le recensioni con altri utenti condividendone il link.

***

Per avviare l'app si consgilia di utilizzare l' *apk* presente nella sezione **Releases** di GitHub. Questo perchè nel progetto non sono presenti le variabili di ambiente e chiavi utilizzate per *Firebase* e *TMDB*.


In caso si volesse provare ad eseguire una build dell'app sarà necessario utilizzare i seguenti comandi:
* `flutter pub get`
* `dart run build_runner build`
* `flutter run --release`