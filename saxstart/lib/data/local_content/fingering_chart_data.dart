class FingeringNote {
  final String name;
  final String octave;
  final List<bool> keys; // true = pressed, 7 keys indexed
  final String tip;
  final String audioAsset;
  final bool isPremium;

  const FingeringNote({
    required this.name,
    required this.octave,
    required this.keys,
    required this.tip,
    required this.audioAsset,
    required this.isPremium,
  });
}

final List<FingeringNote> beginnerNotes = [
  const FingeringNote(
    name: 'B',
    octave: '4',
    keys: [true, false, false, false, false, false, false],
    tip: 'Press only the top left key. Keep other fingers raised.',
    audioAsset: 'assets/audio/notes/note_b4.mp3',
    isPremium: false,
  ),
  const FingeringNote(
    name: 'A',
    octave: '4',
    keys: [true, true, false, false, false, false, false],
    tip: 'Add your second finger. Note A is lower than B.',
    audioAsset: 'assets/audio/notes/note_a4.mp3',
    isPremium: false,
  ),
  const FingeringNote(
    name: 'G',
    octave: '4',
    keys: [true, true, true, false, false, false, false],
    tip: 'Three fingers down. Slow steady air gives the best G.',
    audioAsset: 'assets/audio/notes/note_g4.mp3',
    isPremium: false,
  ),
  const FingeringNote(
    name: 'C',
    octave: '4',
    keys: [false, true, true, false, true, false, false],
    tip: 'C requires a jump in fingering. Practice slowly.',
    audioAsset: 'assets/audio/notes/note_c4.mp3',
    isPremium: true,
  ),
  const FingeringNote(
    name: 'D',
    octave: '4',
    keys: [false, false, false, false, false, false, false],
    tip: 'D is an open note — no keys pressed.',
    audioAsset: 'assets/audio/notes/note_d4.mp3',
    isPremium: true,
  ),
];
