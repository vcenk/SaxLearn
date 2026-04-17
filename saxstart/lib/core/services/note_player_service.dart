import 'package:audioplayers/audioplayers.dart';

class NotePlayerService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playNote(String noteName) async {
    final asset = 'audio/notes/note_${noteName.toLowerCase()}4.mp3';
    await _player.stop();
    await _player.play(AssetSource(asset));
  }

  void dispose() {
    _player.dispose();
  }
}
