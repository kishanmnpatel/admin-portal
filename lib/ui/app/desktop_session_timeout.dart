import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/auth/auth_actions.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:invoiceninja_flutter/utils/platforms.dart';

class DesktopSessionTimeout extends StatefulWidget {
  const DesktopSessionTimeout({this.child});
  final Widget child;

  @override
  _DesktopSessionTimeoutState createState() => _DesktopSessionTimeoutState();
}

class _DesktopSessionTimeoutState extends State<DesktopSessionTimeout> {
  Timer _timer;
  bool _isWarned = false;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      //return;
    }

    _timer = Timer.periodic(
      //Duration(minutes: 1),
      Duration(seconds: 1),
      (Timer timer) {
        final store = StoreProvider.of<AppState>(context);
        final state = store.state;
        final sessionTimeout = state.company.sessionTimeout;

        if (sessionTimeout == 0 || isMobile(context)) {
          return;
        }

        final sessionLength = DateTime.now().millisecondsSinceEpoch -
            state.userCompanyState.lastUpdated;

        print('## DESKTOP Timeout: $sessionTimeout, Length: $sessionLength');

        if (sessionLength > sessionTimeout) {
          store.dispatch(UserLogout(context));
        } else if (sessionLength > (sessionTimeout - (1000 * 60))) {
          setState(() {
            _isWarned = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    if (_isWarned) {
      return Material(
        color: Colors.orange,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text(localization.sessionAboutToExpire)),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _isWarned = false;
                        });
                        final store = StoreProvider.of<AppState>(context);
                        store.dispatch(RefreshData());
                      },
                      child: Text(
                        localization.stayLoggedIn,
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ),
            ),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return widget.child;
  }
}
