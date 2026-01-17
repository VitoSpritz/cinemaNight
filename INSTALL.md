# Set up ambiente

Per avviare l'app si consgilia di utilizzare l' *apk* presente nella sezione **Releases** di GitHub. Questo perchè nel progetto non sono presenti le variabili di ambiente e chiavi utilizzate per *Firebase* e *TMDB*.


All'interno è anche presente uno zip contenente i file di ambiente necessari per poter avviare l'applicazione in *debug mode*. Per perlo fare sarà necessario inserire correttamente i tre file. Il file `firebase_options.dart` dovrà essere posizionato all'interno della directory `/lib`. Il fiel `.env` all'interno della cartella `/lib/env` e il file `google-service.json` dovrà andare all'interno di `/android/app`

Sarà necessario utilizzare i seguenti comandi per eseguire correttamente l'applicazione:
* `flutter pub get`
* `dart run build_runner build`
* `flutter run` oppure `flutter run --release`