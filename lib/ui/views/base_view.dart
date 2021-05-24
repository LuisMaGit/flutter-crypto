import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:crypto_tracker/ui/views/base_vm.dart';

class BaseViewBuilder<T extends BaseVM> extends StatefulWidget {
  final T viewModel;
  final void Function(T viewModel)? initViewModel;
  final Widget Function(BuildContext context) builder;

  const BaseViewBuilder({
    Key? key,
    this.initViewModel,
    required this.viewModel,
    required this.builder,
  }) : super(key: key);

  @override
  _BaseViewBuilderState<T> createState() => _BaseViewBuilderState<T>();
}

class _BaseViewBuilderState<T extends BaseVM>
    extends State<BaseViewBuilder<T>> {
  @override
  void initState() {
    super.initState();
    if (widget.initViewModel != null) {
      widget.initViewModel!(widget.viewModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseViewInheretedWidget(
      viewModel: widget.viewModel,
      child: _ProxyBaseView(
        viewModel: widget.viewModel,
        builder: widget.builder,
      ),
    );
  }
}

class BaseViewInheretedWidget<T extends BaseVM> extends InheritedWidget {
  final Widget child;
  final T viewModel;

  static BaseViewInheretedWidget<U> of<U extends BaseVM>(
          BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType()!;

  BaseViewInheretedWidget({
    required this.child,
    required this.viewModel,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

class _ProxyBaseView<T extends BaseVM> extends _BaseViewListener {
  final Listenable viewModel;
  final Widget Function(BuildContext context) builder;
  _ProxyBaseView({
    Key? key,
    required this.viewModel,
    required this.builder,
  }) : super(key: key, listenable: viewModel);

  @override
  Widget build(BuildContext context) => builder(context);
}

abstract class _BaseViewListener extends StatefulWidget {
  final Listenable listenable;
  const _BaseViewListener({
    Key? key,
    required this.listenable,
  }) : super(key: key);

  @override
  __BaseViewListenerState createState() => __BaseViewListenerState();

  @protected
  Widget build(BuildContext context);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<Listenable>('Base LuisMa View', listenable));
  }
}

class __BaseViewListenerState extends State<_BaseViewListener> {
  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(covariant _BaseViewListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listenable != oldWidget.listenable) {
      oldWidget.listenable.removeListener(_handleChange);
      widget.listenable.addListener(_handleChange);
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.build(context);
}
