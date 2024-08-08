import 'package:get_it/get_it.dart';
import 'package:anyradio/services/audio_service_handler.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<AudioServiceHandler>(await initAudioService());
}
