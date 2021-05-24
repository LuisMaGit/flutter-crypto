
import 'package:crypto_tracker/ui/widgets/graph.dart';
import 'package:crypto_tracker/utils/binders.dart';
import 'package:flutter/material.dart';

import '../views/main_view/main_view_models.dart';

class CriptoCard extends StatelessWidget {
  final CryptoCode cryptoCode;
  final Color colorCrypto;
  final String codeStr;
  final Animation<double>? animation;
  final String percentage;
  final bool? decrease;
  final String price;
  final String fiat;
  final List<Plot> plots;

  CriptoCard({
    required this.cryptoCode,
    required this.colorCrypto,
    required this.decrease,
    required this.codeStr,
    required this.price,
    required this.plots,
    required this.fiat,
    this.animation,
    this.percentage = '',
  });

  @override
  Widget build(BuildContext context) {
    String arrow() => decrease! ? '↓ ' : '↑ ';

    Color colorPercentage() =>
        decrease! ? Colors.redAccent : Colors.greenAccent;

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onBackground,
          borderRadius: BorderRadius.circular(40)),
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //LOGO
          Stack(
            alignment: Alignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 200, maxHeight: 100),
                child: AnimatedBuilder(
                  animation: animation ?? AlwaysStoppedAnimation(0),
                  builder: (context, _) => Graph(
                      yMoveFactor: animation?.value ?? 0,
                      graphData:
                          GraphModel(typeCard: TypeGraph.preview, plots: plots),
                      primaryColor: Theme.of(context).colorScheme.secondary,
                      backGroundColor: Theme.of(context).canvasColor,
                      bigTextColor: Theme.of(context).colorScheme.primary,
                      cardColor: Theme.of(context).colorScheme.onBackground,
                      primaryTextStyle: Theme.of(context).textTheme.headline1,
                      secondaryTextStyle: Theme.of(context).textTheme.caption),
                ),
              ),
              ScaleTransition(
                scale: animation ?? AlwaysStoppedAnimation(0),
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: PhysicalModel(
                      color: Theme.of(context).colorScheme.onBackground,
                      elevation: 10,
                      shadowColor: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(Binders.cryptoPic[cryptoCode]!)),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          //NAME
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: '${Binders.cryptoName[cryptoCode]} ',
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(color: colorCrypto)),
            TextSpan(text: codeStr, style: Theme.of(context).textTheme.caption),
          ])),
          //PERCENTAGE
          decrease == null
              ? SizedBox()
              : RichText(
                  maxLines: 1,
                  text: TextSpan(children: [
                    TextSpan(
                        text: arrow(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(color: colorPercentage())),
                    TextSpan(
                        text: '$percentage%',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(color: colorPercentage())),
                  ])),
          SizedBox(height: 10),
          //PRICE
          price.isEmpty
              ? SizedBox()
              : FadeTransition(
                  opacity: animation ?? AlwaysStoppedAnimation(0),
                  child: Text(
                    '$fiat $price',
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
