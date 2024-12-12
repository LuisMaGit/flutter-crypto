import 'package:crypto_tracker/data/crypto_data_service/crypto_data_constants.dart';
import 'package:crypto_tracker/ui/ui_constants/kcolors.dart';
import 'package:crypto_tracker/ui/widgets/graph.dart';
import 'package:crypto_tracker/ui/ui_helpers.dart';
import 'package:flutter/material.dart';

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

    Color colorPercentage() => decrease! ? kRedAccent : kGreenAccent;

    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
          color: theme.colorScheme.onBackground,
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
                      primaryColor: theme.colorScheme.secondary,
                      backGroundColor: theme.canvasColor,
                      bigTextColor: theme.colorScheme.primary,
                      cardColor: theme.colorScheme.onBackground,
                      primaryTextStyle: theme.textTheme.headlineLarge,
                      secondaryTextStyle: theme.textTheme.bodySmall),
                ),
              ),
              ScaleTransition(
                scale: animation ?? AlwaysStoppedAnimation(0),
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: PhysicalModel(
                      color: theme.colorScheme.onBackground,
                      elevation: 10,
                      shadowColor: theme.colorScheme.background,
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(UIHelper.cryptoPic[cryptoCode]!)),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          //NAME
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: '${UIHelper.cryptoName[cryptoCode]} ',
                style: theme.textTheme.headlineMedium!
                    .copyWith(color: colorCrypto)),
            TextSpan(text: codeStr, style: theme.textTheme.bodySmall),
          ])),
          //PERCENTAGE
          decrease == null
              ? SizedBox()
              : RichText(
                  maxLines: 1,
                  text: TextSpan(children: [
                    TextSpan(
                        text: arrow(),
                        style: theme.textTheme.bodyLarge!
                            .copyWith(color: colorPercentage())),
                    TextSpan(
                        text: '$percentage%',
                        style: theme.textTheme.bodyLarge!
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
                    style: theme.textTheme.headlineLarge,
                  ),
                ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
