import 'package:crypto_tracker/ui/views/base_view.dart';
import 'package:crypto_tracker/ui/widgets/crypto_card.dart';
import 'package:crypto_tracker/ui/views/main_view/main_view_models.dart';
import 'package:crypto_tracker/ui/widgets/graph.dart';
import 'package:crypto_tracker/ui/views/main_view/main_view_vm.dart';
import 'package:crypto_tracker/ui/widgets/modal_error.dart';
import 'package:crypto_tracker/ui/widgets/modal_fiat_selector.dart';
import 'package:crypto_tracker/utils/binders.dart';
import 'package:crypto_tracker/utils/enums.dart';
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
                  if (position % _w == 0) {
                    final idx = position ~/ _w;
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
                prefixBigText: Binders.fiat[model.fiatSelected] ?? '',
                plots: [],
              );

              if (model.state == ViewState.Bussy) {
                final baseText =
                    'Loading ${Binders.cryptoName[model.cryptoSelected] ?? ''} data...';
                return _MainBody(
                    disable: true,
                    scrollController: _scrollController,
                    graphModel: graphModel.copyWith(bigText: baseText));
              }
              if (model.state == ViewState.Iddle) {
                final plots = Binders.getPlotsFromCryptoModel(
                    model.detailsSelected.cryptoData);
                final baseText = '1 ${model.strCryptoCodeSelected} ≈';
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
    final _h = MediaQuery.of(context).size.height;
    final _w = MediaQuery.of(context).size.width;
    final _model = BaseViewInheretedWidget.of<MainViewVM>(context).viewModel;
    final _spacer = SizedBox(height: 16);
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
                  child: Text('CryptoTracker',
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(fontSize: 34)),
                ),
              ),
              _ButtonAppBarWrapper(
                  onTap: disable ? () {} : _model.openFiatDialog,
                  child: Text(Binders.fiat[_model.fiatSelected] ?? '',
                      style: Theme.of(context).textTheme.headline1)),
              _ButtonAppBarWrapper(
                  onTap: _model.changeTheme,
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
                          onTap: disable ? () {} : () => _model.changeDate(t),
                          child: Container(
                            margin: const EdgeInsets.only(right: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: t == _model.timeSpanSelected
                                    ? Binders
                                        .cyrptoColor[_model.cryptoSelected]!
                                        .withOpacity(.5)
                                    : Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                borderRadius: BorderRadius.circular(14)),
                            child: Text(Binders.date[t] ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                        color: Theme.of(context)
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
                    primaryColor: Binders.cyrptoColor[_model.cryptoSelected] ??
                        Theme.of(context).colorScheme.primary,
                    backGroundColor: Theme.of(context).canvasColor,
                    bigTextColor: Theme.of(context).colorScheme.primary,
                    cardColor: Theme.of(context).colorScheme.onBackground,
                    primaryTextStyle: Theme.of(context).textTheme.headline1,
                    secondaryTextStyle: Theme.of(context).textTheme.caption,
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
                                  onTap: () => _model.changeCryptoByTap(c),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    padding: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(23),
                                        color: c == _model.cryptoSelected
                                            ? Binders.cyrptoColor[c]!
                                                .withOpacity(.5)
                                            : Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            child: Image.asset(
                                                Binders.cryptoPic[c]!)),
                                        SizedBox(width: 10),
                                        Text(Binders.cryptoName[c] ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1)
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
                      animation: _model.cryptoSelected == cryptoCode
                          ? curvedAnimation
                          : null,
                      cryptoCode: cryptoCode,
                      colorCrypto: Binders.cyrptoColor[cryptoCode] ??
                          Theme.of(context).colorScheme.secondary,
                      decrease: _model.detailsOf(cryptoCode).percentage == 0
                          ? null
                          : _model.detailsOf(cryptoCode).percentage.isNegative,
                      codeStr: _model.strCodeOf(cryptoCode),
                      percentage: _model.detailsOf(cryptoCode).percentageStr,
                      price: _model.detailsOf(cryptoCode).lastStr,
                      fiat: Binders.fiat[_model.fiatSelected] ?? '',
                      plots: Binders.getPlotsFromCryptoModel(
                          _model.detailsOf(cryptoCode).cryptoData),
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
    return Expanded(
        flex: 1,
        child: SizedBox(
            width: 50,
            child: TextButton(
                onPressed: onTap,
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.only(right: 12))),
                child: child)));
  }
}
