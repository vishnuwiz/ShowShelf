import 'package:material_ui/material_ui.dart';

import '../auth_service.dart';
import '../theme.dart';
import '../ui/kit.dart';

final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Sign in, create an account, or carry on as a guest.
///
/// With [upgrade] set it is shown on top of the app for a guest who wants to
/// keep their shelf: create-account only, and it closes itself when done.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth, this.upgrade = false});
  final AuthService auth;
  final bool upgrade;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  late int _mode = widget.upgrade ? 1 : 0; // 0 sign in, 1 create account
  bool _busy = false;
  bool _show = false;
  String? _emailErr, _passErr, _formErr, _info;

  bool get _create => _mode == 1;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _clear() {
    _emailErr = _passErr = _formErr = _info = null;
  }

  void _fail(Object e) {
    final f = e is AuthFailure ? e : const AuthFailure('Something went wrong. Try again.');
    switch (f.field) {
      case AuthField.email:
        _emailErr = f.message;
      case AuthField.password:
        _passErr = f.message;
      case null:
        _formErr = f.message;
    }
  }

  Future<void> _run(Future<void> Function() job, {bool closes = false}) async {
    setState(() {
      _busy = true;
      _clear();
    });
    try {
      await job();
      if (!mounted) return;
      // Signing in swaps this screen out by itself; an upgrade closes its own route.
      if (closes) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _fail(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _validEmail() {
    if (_emailRe.hasMatch(_email.text.trim())) return true;
    setState(() {
      _clear();
      _emailErr = _email.text.trim().isEmpty ? 'Enter your email address.' : 'That email address does not look right.';
    });
    return false;
  }

  Future<void> _submit() async {
    if (_busy || !_validEmail()) return;
    final pw = _password.text;
    if (pw.isEmpty || (_create && pw.length < 6)) {
      setState(() {
        _clear();
        _passErr = pw.isEmpty ? 'Enter your password.' : 'Use at least 6 characters.';
      });
      return;
    }
    await _run(() => _create ? widget.auth.register(_email.text, pw) : widget.auth.signIn(_email.text, pw), closes: widget.upgrade);
  }

  Future<void> _forgot() async {
    if (_busy || !_validEmail()) return;
    await _run(() async {
      await widget.auth.sendReset(_email.text);
      if (mounted) setState(() => _info = 'Reset link sent to ${_email.text.trim()}. Check your inbox and spam folder.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    final up = widget.upgrade;
    final title = up
        ? 'Keep your shelf'
        : _create
        ? 'Start your shelf'
        : 'Welcome back';
    final sub = up
        ? 'Create an account to keep everything you have tracked and open it on any device.'
        : _create
        ? 'Track movies, series and anime, and keep them on every device.'
        : 'Sign in to pick up where you left off.';

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: AutofillGroup(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  if (up)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconBtn(I.x, label: 'Close', onTap: () => Navigator.of(context).pop()),
                    ),
                  const SizedBox(height: 8),
                  const ExcludeSemantics(child: _Spines()),
                  const SizedBox(height: 22),
                  Entrance(key: ValueKey('t$_mode'), duration: 320, child: H1(title, size: 30)),
                  const SizedBox(height: 6),
                  Text(sub, style: ts(15, color: c.sub, height: 1.4)),
                  if (!up) ...[
                    const SizedBox(height: 20),
                    Segmented(
                      labels: const ['Sign in', 'Create account'],
                      index: _mode,
                      onTap: (i) {
                        if (_busy) return;
                        setState(() {
                          _mode = i;
                          _clear();
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  _Field(
                    label: 'Email',
                    controller: _email,
                    error: _emailErr,
                    keyboard: TextInputType.emailAddress,
                    hints: const [AutofillHints.email],
                    action: TextInputAction.next,
                    onChanged: () {
                      if (_emailErr != null || _formErr != null) setState(() => _emailErr = _formErr = null);
                    },
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'Password',
                    controller: _password,
                    error: _passErr,
                    obscure: !_show,
                    hints: [_create ? AutofillHints.newPassword : AutofillHints.password],
                    action: TextInputAction.done,
                    onSubmit: _submit,
                    onChanged: () {
                      if (_passErr != null || _formErr != null) setState(() => _passErr = _formErr = null);
                    },
                    help: _create ? 'At least 6 characters.' : null,
                    trailing: Tap(
                      label: _show ? 'Hide password' : 'Show password',
                      onTap: () => setState(() => _show = !_show),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(child: Ic(_show ? I.eyeOff : I.eye, size: 20, color: c.sub)),
                      ),
                    ),
                  ),
                  if (!_create)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Tap(
                        onTap: _forgot,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          child: Text('Forgot password?', style: ts(14, w: FontWeight.w600, color: c.accentInk)),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 8),
                  if (_formErr != null) _Note(_formErr!, error: true),
                  if (_info != null) _Note(_info!),
                  const SizedBox(height: 6),
                  SsButton(label: _create ? 'Create account' : 'Sign in', busy: _busy, onTap: _submit),
                  if (!up) ...[
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(child: Container(height: 1, color: c.line)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or', style: ts(13, color: c.sub)),
                        ),
                        Expanded(child: Container(height: 1, color: c.line)),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SsButton(
                      label: 'Continue as guest',
                      secondary: true,
                      onTap: () {
                        if (!_busy) _run(widget.auth.continueAsGuest);
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Try ShowShelf without an account. Create one later to keep your shelf.',
                      textAlign: TextAlign.center,
                      style: ts(13, color: c.sub, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _errColor(Ss c) => c.isDark ? const Color(0xFFFF8A80) : const Color(0xFFC62828);

/// Inline message under the form. Error or info, never colour alone: it has an icon.
class _Note extends StatelessWidget {
  const _Note(this.text, {this.error = false});
  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    final col = error ? _errColor(c) : c.accentInk;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Semantics(
        liveRegion: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Ic(error ? I.alert : I.check, size: 16, color: col),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: ts(13, color: col, height: 1.4))),
          ],
        ),
      ),
    );
  }
}

/// Labelled text field on a card surface with a lime focus ring.
class _Field extends StatefulWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.error,
    this.help,
    this.obscure = false,
    this.keyboard,
    this.hints,
    this.action,
    this.onSubmit,
    this.onChanged,
    this.trailing,
  });
  final String label;
  final TextEditingController controller;
  final String? error, help;
  final bool obscure;
  final TextInputType? keyboard;
  final Iterable<String>? hints;
  final TextInputAction? action;
  final VoidCallback? onSubmit, onChanged;
  final Widget? trailing;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    final f = _focus.hasFocus;
    final err = widget.error;
    final ring = err != null ? _errColor(c) : c.accentInk;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: ts(13, w: FontWeight.w600, color: c.sub)),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: ms(context, 250),
          constraints: const BoxConstraints(minHeight: 52),
          padding: EdgeInsets.only(left: 14, right: widget.trailing == null ? 14 : 2),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: f || err != null ? ring : c.cardEdge),
            boxShadow: [BoxShadow(color: f ? ring.withValues(alpha: .22) : Colors.transparent, spreadRadius: 3)],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  obscureText: widget.obscure,
                  keyboardType: widget.keyboard,
                  textInputAction: widget.action,
                  autofillHints: widget.hints,
                  autocorrect: false,
                  enableSuggestions: !widget.obscure,
                  onChanged: (_) => widget.onChanged?.call(),
                  onSubmitted: (_) => widget.onSubmit?.call(),
                  style: ts(16, color: c.text),
                  decoration: const InputDecoration.collapsed(hintText: ''),
                ),
              ),
              ?widget.trailing,
            ],
          ),
        ),
        if (err != null) _Note(err, error: true) else if (widget.help != null) Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(widget.help!, style: ts(13, color: c.sub)),
        ),
      ],
    );
  }
}

/// A row of spines on a shelf. They rise in turn and the last one tips over,
/// the same gesture as the app icon.
class _Spines extends StatelessWidget {
  const _Spines();

  static const _books = [(26.0, 88.0, 28), (34.0, 112.0, 200), (22.0, 98.0, 330), (38.0, 124.0, 150), (28.0, 94.0, 48), (32.0, 116.0, 262)];

  Widget _shelf(Ss c, double t) {
    double seg(int i) => kEase.transform(((t * 1300 - i * 90) / 420).clamp(0.0, 1.0));
    final lean = kSpring.transform(((t * 1300 - 700) / 380).clamp(0.0, 1.0));
    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(height: 4, decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.only(bottom: 4, right: 26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < _books.length; i++)
                  Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                    child: Opacity(
                      opacity: seg(i),
                      child: Transform.translate(
                        offset: Offset(0, 36 * (1 - seg(i))),
                        child: Transform.rotate(
                          angle: i == _books.length - 1 ? .21 * lean : 0,
                          alignment: Alignment.bottomRight,
                          child: _Spine(_books[i].$1, _books[i].$2, _books[i].$3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Ss.of(context);
    final d = ms(context, 1300);
    if (d == Duration.zero) return _shelf(c, 1);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: d,
      builder: (_, t, _) => _shelf(c, t),
    );
  }
}

class _Spine extends StatelessWidget {
  const _Spine(this.w, this.h, this.hue);
  final double w, h;
  final int hue;

  @override
  Widget build(BuildContext context) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [hsl(hue, 58, 40), hsl(hue, 62, 20)]),
    ),
    child: Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: w * .5,
        height: 3,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .35), borderRadius: BorderRadius.circular(2)),
      ),
    ),
  );
}
