import 'dart:math';

class BusinessCardParser {

  /// Entry point principale — analizza testo grezzo OCR
  static BusinessCardData parse(String rawText) {
    // Normalizza il testo: rimuovi caratteri strani, normalizza spazi
    final lines = _normalizeText(rawText);

    return BusinessCardData(
      firstName: _extractFirstName(lines),
      lastName: _extractLastName(lines),
      email: _extractEmail(rawText),
      phone: _extractPhone(rawText),
      company: _extractCompany(lines),
      jobTitle: _extractJobTitle(lines),
      website: _extractWebsite(rawText),
      linkedin: _extractLinkedIn(rawText),
    );
  }

  // ─── NORMALIZZAZIONE ───────────────────────────────────────────

  static List<String> _normalizeText(String raw) {
    return raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  // ─── EMAIL ────────────────────────────────────────────────────
  // La più affidabile — regex standard

  static String? _extractEmail(String text) {
    final regex = RegExp(
      r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    return match?.group(0)?.toLowerCase();
  }

  // ─── TELEFONO ────────────────────────────────────────────────
  // Gestisce formati internazionali: +39 02 1234, (02) 1234, ecc.

  static String? _extractPhone(String text) {
    // Prima cerca numeri con prefisso internazionale
    final intlRegex = RegExp(
      r'\+\d{1,3}[\s\-.]?\(?\d{1,4}\)?[\s\-.]?\d{1,4}[\s\-.]?\d{1,9}',
    );
    var match = intlRegex.firstMatch(text);
    if (match != null) return _cleanPhone(match.group(0)!);

    // Poi cerca numeri locali italiani
    final itRegex = RegExp(
      r'(?:0\d{1,4}[\s\-.]?\d{4,8}|3\d{2}[\s\-.]?\d{3}[\s\-.]?\d{4})',
    );
    match = itRegex.firstMatch(text);
    if (match != null) return _cleanPhone(match.group(0)!);

    // Generico: almeno 8 cifre consecutive
    final genericRegex = RegExp(r'\b\d[\d\s\-().]{7,}\d\b');
    match = genericRegex.firstMatch(text);
    return match != null ? _cleanPhone(match.group(0)!) : null;
  }

  static String _cleanPhone(String phone) =>
      phone.trim().replaceAll(RegExp(r'\s+'), ' ');

  // ─── WEBSITE ─────────────────────────────────────────────────

  static String? _extractWebsite(String text) {
    final regex = RegExp(
      r'(?:https?://)?(?:www\.)?[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}(?:/[^\s]*)?',
      caseSensitive: false,
    );
    final matches = regex.allMatches(text);
    for (final match in matches) {
      final url = match.group(0)!;
      // Escludi email e linkedin
      if (!url.contains('@') && !url.contains('linkedin')) {
        return url.startsWith('http') ? url : 'https://$url';
      }
    }
    return null;
  }

  // ─── LINKEDIN ────────────────────────────────────────────────

  static String? _extractLinkedIn(String text) {
    final regex = RegExp(
      r'linkedin\.com/in/([a-zA-Z0-9\-]+)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    return match != null ? 'https://linkedin.com/in/${match.group(1)}' : null;
  }

  // ─── NOME E COGNOME ─────────────────────────────────────────
  // Euristica: la riga con solo parole maiuscole o
  // formato "Nome Cognome" è probabilmente il nome

  static String? _extractFirstName(List<String> lines) {
    final nameLine = _findNameLine(lines);
    if (nameLine == null) return null;
    final parts = nameLine.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? _capitalize(parts.first) : null;
  }

  static String? _extractLastName(List<String> lines) {
    final nameLine = _findNameLine(lines);
    if (nameLine == null) return null;
    final parts = nameLine.trim().split(RegExp(r'\s+'));
    return parts.length > 1
        ? parts.sublist(1).map(_capitalize).join(' ')
        : null;
  }

  static String? _findNameLine(List<String> lines) {
    // Punteggio per ogni linea — vince quella col punteggio più alto
    String? bestLine;
    double bestScore = 0;

    // Linee da escludere — contengono pattern non-nome
    final excludePatterns = [
      RegExp(r'@'),                          // email
      RegExp(r'\d{4,}'),                     // numeri lunghi (telefono)
      RegExp(r'www\.|\.com|\.it|\.io'),      // website
      RegExp(r'linkedin|twitter|instagram'), // social
      RegExp(r'via |str\.|viale ', caseSensitive: false), // indirizzo
      RegExp(r'[&+]'),                       // caratteri aziendali
    ];

    // Parole che indicano job title — non sono nomi
    final titleKeywords = [
      'ceo', 'cto', 'coo', 'cfo', 'director', 'manager', 'engineer',
      'developer', 'designer', 'consultant', 'founder', 'president',
      'vice', 'head', 'lead', 'senior', 'junior', 'partner', 'associate',
      'direttore', 'responsabile', 'ingegnere', 'consulente', 'fondatore',
    ];

    for (final line in lines) {
      final lower = line.toLowerCase();

      // Salta linee escluse
      if (excludePatterns.any((p) => p.hasMatch(line))) continue;

      double score = 0;

      // Bonus: solo lettere e spazi
      if (RegExp(r'^[a-zA-ZÀ-ÿ\s\-\.]+$').hasMatch(line)) score += 3;

      // Bonus: 2-3 parole (nome + cognome)
      final wordCount = line.trim().split(RegExp(r'\s+')).length;
      if (wordCount == 2) score += 4;
      if (wordCount == 3) score += 2;
      if (wordCount == 1 || wordCount > 4) score -= 2;

      // Bonus: ogni parola inizia con maiuscola
      final words = line.trim().split(RegExp(r'\s+'));
      if (words.every((w) => w.isNotEmpty && w[0] == w[0].toUpperCase())) {
        score += 2;
      }

      // Malus: contiene keyword di job title
      if (titleKeywords.any((k) => lower.contains(k))) score -= 5;

      // Bonus: lunghezza ragionevole per un nome (5-30 chars)
      if (line.length >= 5 && line.length <= 30) score += 1;

      // Malus: tutto maiuscolo (probabilmente azienda)
      if (line == line.toUpperCase() && line.length > 3) score -= 1;

      if (score > bestScore) {
        bestScore = score;
        bestLine = line;
      }
    }

    return bestScore > 2 ? bestLine : null;
  }

  // ─── AZIENDA ────────────────────────────────────────────────
  // Euristica: tutto maiuscolo, oppure contiene Srl/Spa/Ltd/Inc

  static String? _extractCompany(List<String> lines) {
    // Pattern aziendali espliciti
    final companyRegex = RegExp(
      r'\b(?:S\.?r\.?l\.?|S\.?p\.?A\.?|S\.?a\.?s\.?|Ltd\.?|'
      r'Inc\.?|Corp\.?|GmbH|S\.?A\.?|B\.?V\.?|LLC)\b',
      caseSensitive: false,
    );

    // Prima cerca linee con suffisso aziendale esplicito
    for (final line in lines) {
      if (companyRegex.hasMatch(line)) return line.trim();
    }

    // Poi cerca linee tutto maiuscolo (lunghezza ragionevole)
    for (final line in lines) {
      if (line == line.toUpperCase() &&
          line.length > 3 &&
          line.length < 50 &&
          !RegExp(r'\d{4,}').hasMatch(line) &&
          !line.contains('@')) {
        return _titleCase(line);
      }
    }

    return null;
  }

  // ─── JOB TITLE ──────────────────────────────────────────────

  static String? _extractJobTitle(List<String> lines) {
    final titleKeywords = [
      'ceo', 'cto', 'coo', 'cfo', 'founder', 'co-founder',
      'director', 'manager', 'engineer', 'developer', 'designer',
      'consultant', 'president', 'vice president', 'vp', 'head of',
      'lead', 'senior', 'partner', 'associate', 'analyst',
      // Italiano
      'direttore', 'responsabile', 'ingegnere', 'sviluppatore',
      'consulente', 'fondatore', 'presidente', 'commerciale',
      'amministratore', 'titolare', 'socio',
    ];

    for (final line in lines) {
      final lower = line.toLowerCase();
      if (titleKeywords.any((k) => lower.contains(k))) {
        return _titleCase(line.trim());
      }
    }
    return null;
  }

  // ─── UTILITIES ───────────────────────────────────────────────

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  static String _titleCase(String s) =>
      s.split(' ').map(_capitalize).join(' ');
}

// Modello risultato parsing
class BusinessCardData {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? company;
  final String? jobTitle;
  final String? website;
  final String? linkedin;

  const BusinessCardData({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.company,
    this.jobTitle,
    this.website,
    this.linkedin,
  });

  // Confidenza del parsing — quanti campi siamo riusciti a estrarre
  double get confidence {
    int found = 0;
    int total = 5; // email, phone, firstName, lastName, company
    if (email != null) found++;
    if (phone != null) found++;
    if (firstName != null) found++;
    if (lastName != null) found++;
    if (company != null) found++;
    return found / total;
  }

  bool get hasMinimumData => firstName != null || email != null || phone != null;
}