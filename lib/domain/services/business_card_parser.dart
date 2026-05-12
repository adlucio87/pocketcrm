class BusinessCardParser {
  /// Main entry point — analyzes raw OCR text
  static BusinessCardData parse(String rawText) {
    // Normalize text: remove odd characters, normalize spaces
    final lines = _normalizeText(rawText);
    // Removed PII-related logging or wrapped in kDebugMode
    // print('PARSER: Normalized ${lines.length} lines');

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

  // ─── NORMALIZATION ───────────────────────────────────────────

  static List<String> _normalizeText(String raw) {
    return raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  // ─── EMAIL ────────────────────────────────────────────────────
  // Most reliable — standard regex

  static String? _extractEmail(String text) {
    // Remove common spaces added by OCR around @
    final normalized = text.replaceAll(RegExp(r'\s*@\s*'), '@');

    final regex = RegExp(
      r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}',
      caseSensitive: false,
    );
    final match = regex.firstMatch(normalized);
    return match?.group(0)?.toLowerCase();
  }

  // ─── TELEFONO ────────────────────────────────────────────────
  // Handles international formats: +39 02 1234, (02) 1234, etc.

  static String? _extractPhone(String text) {
    // First search for numbers with international prefix
    final intlRegex = RegExp(
      r'\+\d{1,3}[\s\-.]?\(?\d{1,4}\)?[\s\-.]?\d{1,4}[\s\-.]?\d{1,9}',
    );
    var match = intlRegex.firstMatch(text);
    if (match != null) return _cleanPhone(match.group(0)!);

    // Then search for local Italian numbers
    final itRegex = RegExp(
      r'(?:0\d{1,4}[\s\-.]?\d{4,8}|3\d{2}[\s\-.]?\d{3}[\s\-.]?\d{4})',
    );
    match = itRegex.firstMatch(text);
    if (match != null) return _cleanPhone(match.group(0)!);

    // Generic: at least 8 consecutive digits
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
      // Exclude email and linkedin
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
  // Heuristic: lines with only uppercase words or
  // "First Last" format are likely the name

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
    // Score for each line — the one with the highest score wins
    String? bestLine;
    double bestScore = 0;

    // Lines to exclude — contains non-name patterns
    final excludePatterns = [
      RegExp(r'@'), // email
      RegExp(r'\d{4,}'), // numeri lunghi (telefono)
      RegExp(r'www\.|\.com|\.it|\.io'), // website
      RegExp(r'linkedin|twitter|instagram'), // social
      RegExp(r'via |str\.|viale ', caseSensitive: false), // address
      RegExp(r'[&+]'), // company characters
    ];

    // Words indicating job titles — not names
    final titleKeywords = [
      'ceo', 'cto', 'coo', 'cfo', 'director', 'manager', 'engineer',
      'developer', 'designer', 'consultant', 'founder', 'president',
      'vice', 'head', 'lead', 'senior', 'junior', 'partner', 'associate',
      'direttore',
      'responsabile',
      'ingegnere',
      'consulente',
      'fondatore', // Italian fallback
    ];

    for (final line in lines) {
      final lower = line.toLowerCase();

      if (excludePatterns.any((p) => p.hasMatch(line)))
        continue; // Skip excluded lines

      double score = 0;

      // Bonus: only letters and spaces
      if (RegExp(r'^[a-zA-ZÀ-ÿ\s\-\.]+$').hasMatch(line)) score += 3;

      // Bonus: 2-3 words (first + last name)
      final wordCount = line.trim().split(RegExp(r'\s+')).length;
      if (wordCount == 2) score += 4;
      if (wordCount == 3) score += 2;
      if (wordCount == 1 || wordCount > 4) score -= 2;

      // Bonus: every word starts with uppercase
      final words = line.trim().split(RegExp(r'\s+'));
      if (words.every((w) => w.isNotEmpty && w[0] == w[0].toUpperCase())) {
        score += 2;
      }

      // Penalty: contains job title keyword
      if (titleKeywords.any((k) => lower.contains(k))) score -= 5;

      // Bonus: reasonable length for a name (5-30 chars)
      if (line.length >= 5 && line.length <= 30) score += 1;

      // Penalty: all uppercase (likely company)
      if (line == line.toUpperCase() && line.length > 3) score -= 1; // Penalty

      if (score > bestScore) {
        bestScore = score;
        bestLine = line;
      }
    }

    return bestScore > 2 ? bestLine : null;
  }

  // ─── COMPANY ────────────────────────────────────────────────
  // Heuristic: all uppercase, or contains Srl/Spa/Ltd/Inc

  static String? _extractCompany(List<String> lines) {
    // Explicit company patterns
    final companyRegex = RegExp(
      r'\b(?:S\.?r\.?l\.?|S\.?p\.?A\.?|S\.?a\.?s\.?|Ltd\.?|'
      r'Inc\.?|Corp\.?|GmbH|S\.?A\.?|B\.?V\.?|LLC)\b',
      caseSensitive: false,
    );

    // First search for lines with explicit company suffix
    for (final line in lines) {
      if (companyRegex.hasMatch(line)) return line.trim();
    }

    // Then search for all-uppercase lines (reasonable length)
    final nameLine = _findNameLine(lines);
    for (final line in lines) {
      if (line == line.toUpperCase() &&
          line.length > 3 &&
          line.length < 50 &&
          line != nameLine && // Avoid mistaking name for company
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
      // Italian
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

  static String _titleCase(String s) => s.split(' ').map(_capitalize).join(' ');
}

// Parsing result model
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

  // Parsing confidence — how many fields were extracted
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

  bool get hasMinimumData =>
      firstName != null || email != null || phone != null;

  @override
  String toString() {
    return 'BusinessCardData(firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, company: $company, jobTitle: $jobTitle, website: $website)';
  }
}
