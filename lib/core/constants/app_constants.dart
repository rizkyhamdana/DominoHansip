class AppConstants {
  AppConstants._();

  static const int defaultTotalStones = 16;
  static const int bigStonePoints = 5;
  static const int smallStonePoints = 1;
  static const int minPlayers = 3;
  static const int maxPlayers = 6;
  static const int minTotalStones = 4;

  // Microcopy
  static const String appName = 'Domino Hansip';
  static const String appTagline = 'Main Domino Hansip Tradisional dengan AI & Simulasi.';
  static const String appSubtitle = 'Main vs Bot AI & Simulasi Mandiri';

  static const String noCrownHolder = 'Belum ada Kepala Desa';
  static const String noHansip = 'Belum ada Hansip';

  static const String bigStoneFallMessage = 'Batu Besar jatuh ke tangan';
  static const String smallStonePassMessage = 'pass dan mengambil Batu Kecil';
  static const String allStonesDistributed = 'Semua batu sudah terbagi.';
  static const String bigStoneLockedMessage =
      'Batu Besar hanya bisa dibagi terakhir.';
  static const String causerNoStoneError =
      'Pemain ini tidak punya batu untuk dibagi.';
  static const String mustDistributeMessage = 'harus membagi 1 batu.';
  static const String zeroStoneMessage =
      'berhasil menghabiskan batu. Status Kepala Desa akan diproses saat game selesai.';
  static const String crownMovedMessage = 'Jabatan Kepala Desa berpindah ke';
  static const String crownStayMessage = 'Jabatan Kepala Desa tetap di';
  static const String newHansipMessage = 'Hansip baru:';
  static const String newRoundMessage = 'Game baru dimulai.';
  static const String hansipReadyMessage = 'Hansip, siap kocok domino!';
  static const String selectCauserTitle = 'Siapa yang bikin dia pass?';
  static const String selectWinnerTitle = 'Pilih pemenang game.';

  // Phase labels
  static const String phaseInitialDraw = 'Pengambilan Batu';
  static const String phasePlaying = 'Bermain';
  static const String phaseDistributing = 'Bagi Batu';
  static const String phaseSettlement = 'Selesaikan Game';
  static const String phaseRoundFinished = 'Game Selesai';
}
