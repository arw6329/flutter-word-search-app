import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:word_search_app/banner_ad_page.dart';
import 'package:word_search_app/gamemodes/debug_impossible_gamemode.dart';
import 'package:word_search_app/gamemodes/numeric_gamemode.dart';
import 'package:word_search_app/gamemodes/random_normal_gamemode.dart';
import 'package:word_search_app/gamemodes/themed_normal_gamemode.dart';
import 'package:word_search_app/large_common_button.dart';
import 'package:word_search_app/pages/word_search_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomePage extends StatelessWidget {
    const HomePage({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Container(
                margin: EdgeInsets.all(40),
                child: Column(
                    children: [
                        Container(
                            margin: EdgeInsets.only(top: 70),
                            child: Text('Infinite Word Search',
                                style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.center,
                            )
                        ),
                        Flexible(
                            fit: FlexFit.tight,
                            child: Container(
                                padding: EdgeInsets.symmetric(vertical: 60),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    spacing: 5,
                                    children: [
                                        Text('Gamemodes', style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                        )),
                                        LargeCommonButton(
                                            onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(builder: (context) => BannerAdPage(child: WordSearchPage(gamemode: ThemedNormalGamemode())))
                                                );
                                            },
                                            child: Row(
                                                children: [
                                                    Flexible(
                                                        fit: FlexFit.tight,
                                                        child: Text('Themed Normal')
                                                    ),
                                                    Text('12 x 15')
                                                ]
                                            )
                                        ),
                                        LargeCommonButton(
                                            onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(builder: (context) => BannerAdPage(child: WordSearchPage(gamemode: RandomNormalGamemode())))
                                                );
                                            },
                                            child: Row(
                                                children: [
                                                    Flexible(
                                                        fit: FlexFit.tight,
                                                        child: Text('Random Normal')
                                                    ),
                                                    Text('12 x 15')
                                                ]
                                            )
                                        ),
                                        Container(
                                            margin: EdgeInsets.only(top: 25),
                                            child: LargeCommonButton(
                                                color: const Color.fromARGB(255, 109, 188, 253),
                                                onPressed: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(builder: (context) => BannerAdPage(child: WordSearchPage(gamemode: NumericGamemode())))
                                                    );
                                                },
                                                child: Row(
                                                    children: [
                                                        Flexible(
                                                            fit: FlexFit.tight,
                                                            child: Text('Numeric')
                                                        ),
                                                        Text('12 x 15')
                                                    ]
                                                )
                                            )
                                        ),
                                        if(kDebugMode) Container(
                                            margin: EdgeInsets.only(top: 25),
                                            child: LargeCommonButton(
                                                solid: false,
                                                onPressed: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(builder: (context) => BannerAdPage(child: WordSearchPage(gamemode: ImpossibleToGenerateGamemode())))
                                                    );
                                                },
                                                child: Row(
                                                    children: [
                                                        Flexible(
                                                            fit: FlexFit.tight,
                                                            child: Text('Buggy Generation Test')
                                                        )
                                                    ]
                                                )
                                            )
                                        )
                                    ]
                                )
                            )
                        ),
                        FutureBuilder(
                            future: PackageInfo.fromPlatform(), builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
                                return snapshot.hasData
                                    ? Text('Version ${snapshot.data!.version}+${snapshot.data!.buildNumber}', style: TextStyle(color: Colors.grey))
                                    : snapshot.hasError
                                    ? Text(snapshot.error.toString())
                                    : Container();
                            }
                        )
                    ]
                )
            )
        );
    }
}