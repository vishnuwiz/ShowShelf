import 'package:material_ui/material_ui.dart';

import '../account.dart';
import '../theme.dart';
import '../ui/kit.dart';
import 'login.dart';

/// Profile section: who is signed in, create an account (guests), sign out.
/// Shows nothing when the app has no sign-in.
class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  Future<void> _signOut(BuildContext context, AccountScope scope) async {
    if (scope.user!.isGuest) {
      final c = Ss.of(context);
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: c.card,
          title: Text('Sign out of guest?', style: ts(18, w: FontWeight.w700, color: c.text)),
          content: Text(
            'Your shelf is saved to this guest sign-in only. If you sign out you cannot get it back. Create an account first to keep it.',
            style: ts(14, color: c.sub, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel', style: ts(15, w: FontWeight.w600, color: c.accentInk)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Sign out anyway', style: ts(15, w: FontWeight.w600, color: c.sub)),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await scope.signOut!();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AccountScope.maybeOf(context);
    final user = scope?.user;
    final auth = scope?.auth;
    if (scope == null || user == null || auth == null || scope.signOut == null) return const SizedBox.shrink();
    final c = Ss.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const H2('Account'),
        px(
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardDeco(c, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Ic(user.isGuest ? I.user : I.mail, size: 22, color: c.sub),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.isGuest ? 'Guest' : 'Signed in as', style: ts(13, color: c.sub)),
                          const SizedBox(height: 2),
                          Text(
                            user.isGuest ? 'Not backed up to an account' : (user.email ?? 'Your account'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ts(15, w: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (user.isGuest) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Your shelf is saved to this guest sign-in only. Create an account to keep it and open it on other devices.',
                    style: ts(13, color: c.sub, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  SsButton(
                    label: 'Create account',
                    onTap: () => Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute<void>(
                        fullscreenDialog: true,
                        builder: (_) => LoginScreen(auth: auth, upgrade: true),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SsButton(label: 'Sign out', secondary: true, onTap: () => _signOut(context, scope)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
