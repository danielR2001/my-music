import 'package:flutter/material.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';
import 'package:provider/provider.dart';

class BasePage<T extends BaseModel> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget child) builder;
  final Function(T) onModelReady;
  final Function(T) onModelDisposed;

  BasePage({this.builder, this.onModelReady,this.onModelDisposed});

  @override
  _BasePageState<T> createState() => _BasePageState<T>();
}

class _BasePageState<T extends BaseModel> extends State<BasePage<T>> {
  T model = locator<T>();

  @override
  void initState() {
    if (widget.onModelReady != null) {
      widget.onModelReady(model);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.onModelDisposed != null) {
      widget.onModelDisposed(model);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      builder: (context) => model,
      child: Consumer<T>(
        builder: widget.builder,
      ),
    );
  }
}
