import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

typedef BlocStateListener<S> = Function(BuildContext context, S state);

class BlocRouteListener<E, S> extends StatefulWidget {
  final Bloc<E, S> bloc;
  final Widget child;
  final BlocStateListener<S> listener;

  BlocRouteListener({
    Key key,
    @required this.bloc,
    @required this.child,
    @required this.listener,
  }) : super(key: key);

  _BlocRouteListenerState<E, S> createState() =>
      _BlocRouteListenerState<E, S>();
}

class _BlocRouteListenerState<E, S> extends State<BlocRouteListener<E, S>> {
  StreamSubscription _subscription;

  @override
  void initState() {
    _subscribe();
    super.initState();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  void didUpdateWidget(BlocRouteListener<E, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bloc != widget.bloc) {
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _subscribe() {
    if (widget.bloc != null) {
      widget.bloc.skip(1).listen((state) {
        if (context != null && state != null) {
          widget.listener(context, state);
        }
      });
    }
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
