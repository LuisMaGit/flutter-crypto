import 'package:crypto_tracker/data/crypto_data_service/crypto_data_constants.dart';
import 'package:crypto_tracker/ui/features/base_view/base_view.dart';
import 'package:crypto_tracker/ui/features/base_view/base_view_state.dart';
import 'package:crypto_tracker/ui/ui_constants/labels.dart';
import 'package:crypto_tracker/ui/widgets/crypto_card.dart';
import 'package:crypto_tracker/ui/widgets/graph.dart';
import 'package:crypto_tracker/ui/features/main_view/main_view_vm.dart';
import 'package:crypto_tracker/ui/widgets/modal_error.dart';
import 'package:crypto_tracker/ui/widgets/modal_fiat_selector.dart';
import 'package:crypto_tracker/ui/ui_helpers.dart';
import 'package:flutter/material.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView>
    with SingleTickerProviderStateMixin {
  final model = MainViewVM();
  late AnimationController _controllerYFactor;
  late CurvedAnimation _curveYAnimation;
  late Animation<double> _animationYFactor;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controllerYFactor =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animationYFactor =
        Tween<double>(begin: 0, end: 1).animate(_controllerYFactor);
    _curveYAnimation =
        CurvedAnimation(curve: Curves.easeIn, parent: _animationYFactor);
  }

  Future<void> _startAnimation() async {
    await _controllerYFactor.forward();
  }

  Future<void> _reverseAnimation() async {
    await _controllerYFactor.reverse();
  }

  @override
  void dispose() {
    super.dispose();
    _controllerYFactor.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _w = MediaQuery.of(context).size.width;

    void _scrollMoveTo(CryptoCode c) {
      final offset = c.index * _w;
      _scrollController.animateTo(
        offset,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    }

    Future<FiatCode?> _showFiatDialog(FiatCode selected) async {
      return await showDialog(
          context: context,
          builder: (context) {
            return ModalFiatSelector(selected: selected);
          });
    }

    Future<void> _showErrorDialog() async {
      await showDialog(
          context: context,
          builder: (context) {
            return ModalError();
          });
    }

    return SafeArea(
      child: Scaffold(
        body: BaseViewBuilder<MainViewVM>(
            initViewModel: (model) {
              _scrollController = ScrollController(
                  initialScrollOffset: _w * model.cryptoSelected.index)
                ..addListener(() {
                  final position = _scrollController.position.pixels;
                  final positionTruncated = position.toInt();
                  final wTruncated = _w.toInt();
                  if (positionTruncated % wTruncated == 0) {
                    final idx = positionTruncated ~/ wTruncated;
                    model.changeCrypto(CryptoCode.values[idx]);
                  }
                });

              model.initMainViewVM(
                startAnimation: _startAnimation,
                reverseAnimation: _reverseAnimation,
                scrollMoveTo: _scrollMoveTo,
                showFiatDialog: _showFiatDialog,
                showErrorDialog: _showErrorDialog,
              );
            },
            viewModel: model,
            builder: (context) {
              final graphModel = GraphModel(
                prefixBigText: UIHelper.fiat[model.fiatSelected] ?? '',
                plots: [],
              );

              if (model.state == BaseViewState.Bussy) {
                return _MainBody(
                  disable: true,
                  scrollController: _scrollController,
                  graphModel: graphModel.copyWith(
                    bigText: Labels.mainViewloading(
                      UIHelper.cryptoName[model.cryptoSelected] ?? '',
                    ),
                  ),
                );
              }
              if (model.state == BaseViewState.Iddle) {
                final plots = UIHelper.getPlotsFromCryptoModel(
                  model.detailsSelected.cryptoData,
                );
                final baseText = '1 ${model.cryptoSelected.uiCode} ≈';
                return _MainBody(
                    curvedAnimation: _curveYAnimation,
                    scrollController: _scrollController,
                    graphModel:
                        graphModel.copyWith(plots: plots, baseText: baseText));
              }
              return SizedBox();
            }),
      ),
    );
  }
}

class _MainBody extends StatelessWidget {
  final GraphModel graphModel;
  final bool disable;
  final CurvedAnimation? curvedAnimation;
  final ScrollController scrollController;

  const _MainBody({
    Key? key,
    required this.graphModel,
    required this.scrollController,
    this.curvedAnimation,
    this.disable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _h = size.height;
    final _w = size.width;
    final _vm = BaseViewInheretedWidget.of<MainViewVM>(context).viewModel;
    final _spacer = SizedBox(height: 16);
    final theme = Theme.of(context);
    return Center(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 20),
        physics: BouncingScrollPhysics(),
        children: [
          //App Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(Labels.appName(),
                      style: theme
                          .textTheme
                          .headlineLarge!
                          .copyWith(fontSize: 34)),
                ),
              ),
              _ButtonAppBarWrapper(
                  onTap: disable ? () {} : _vm.openFiatDialog,
                  child: Text(UIHelper.fiat[_vm.fiatSelected] ?? '',
                      style: theme.textTheme.headlineLarge)),
              _ButtonAppBarWrapper(
                  onTap: _vm.changeTheme,
                  child: Icon(Icons.lightbulb_outline_rounded)),
            ],
          ),
          SizedBox(height: 10),
          //Dates
          SizedBox(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                      child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 10),
                    physics: BouncingScrollPhysics(),
                    children: TimeSpan.values.map((t) {
                      return Center(
                        child: GestureDetector(
                          onTap: disable ? () {} : () => _vm.changeDate(t),
                          child: Container(
                            margin: const EdgeInsets.only(right: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: t == _vm.timeSpanSelected
                                    ? UIHelper
                                        .cyrptoColor[_vm.cryptoSelected]!
                                        .withOpacity(.5)
                                    : theme
                                        .colorScheme
                                        .onBackground,
                                borderRadius: BorderRadius.circular(14)),
                            child: Text(UIHelper.date[t] ?? '',
                                style: theme
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: theme
                                            .colorScheme
                                            .secondary)),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
                ],
              )),
          //Graph
          Container(
            height: _h * .3,
            constraints: BoxConstraints(minHeight: 200, maxHeight: 400),
            child: AnimatedBuilder(
                animation: curvedAnimation ?? AlwaysStoppedAnimation(0),
                builder: (context, child) {
                  return Graph(
                    yMoveFactor: curvedAnimation?.value ?? 0,
                    graphData: graphModel,
                    primaryColor: UIHelper.cyrptoColor[_vm.cryptoSelected] ??
                        theme.colorScheme.primary,
                    backGroundColor: theme.canvasColor,
                    bigTextColor: theme.colorScheme.primary,
                    cardColor: theme.colorScheme.onBackground,
                    primaryTextStyle: theme.textTheme.headlineLarge,
                    secondaryTextStyle: theme.textTheme.bodySmall,
                  );
                }),
          ),
          _spacer,
          //Coins
          SizedBox(
            height: 45,
            child: Row(
              children: [
                Expanded(
                    child: ListView(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: CryptoCode.values
                            .map((c) => GestureDetector(
                                  onTap: () => _vm.changeCryptoByTap(c),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    padding: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(23),
                                        color: c == _vm.cryptoSelected
                                            ? UIHelper.cyrptoColor[c]!
                                                .withOpacity(.5)
                                            : theme
                                                .colorScheme
                                                .onBackground),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                            radius: 20,
                                            backgroundColor: theme
                                                .colorScheme
                                                .onBackground,
                                            child: Image.asset(
                                                UIHelper.cryptoPic[c]!)),
                                        SizedBox(width: 10),
                                        Text(UIHelper.cryptoName[c] ?? '',
                                            style: theme
                                                .textTheme
                                                .bodyLarge)
                                      ],
                                    ),
                                  ),
                                ))
                            .toList()))
              ],
            ),
          ),
          _spacer,
          //List Cards
          SizedBox(
            height: 260,
            child: ListView.builder(
              controller: scrollController,
              physics: disable
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(parent: BouncingScrollPhysics()),
              scrollDirection: Axis.horizontal,
              itemCount: CryptoCode.values.length,
              itemBuilder: (context, index) {
                final cryptoCode = CryptoCode.values[index];
                return SizedBox(
                  width: _w,
                  child: Center(
                    child: CriptoCard(
                      animation: _vm.cryptoSelected == cryptoCode
                          ? curvedAnimation
                          : null,
                      cryptoCode: cryptoCode,
                      colorCrypto: UIHelper.cyrptoColor[cryptoCode] ??
                          theme.colorScheme.secondary,
                      decrease: _vm.detailsOf(cryptoCode).percentage == 0
                          ? null
                          : _vm.detailsOf(cryptoCode).percentage.isNegative,
                      codeStr: cryptoCode.uiCode,
                      percentage: _vm.detailsOf(cryptoCode).percentageStr,
                      price: _vm.detailsOf(cryptoCode).lastStr,
                      fiat: UIHelper.fiat[_vm.fiatSelected] ?? '',
                      plots: UIHelper.getPlotsFromCryptoModel(
                          _vm.detailsOf(cryptoCode).cryptoData),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonAppBarWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ButtonAppBarWrapper(
      {Key? key, required this.child, required this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 50,
        child: TextButton(
            onPressed: onTap,
            style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.only(right: 12))),
            child: child));
  }
}
