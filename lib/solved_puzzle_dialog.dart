import 'package:flutter/material.dart';
import 'package:word_search_app/banner_ad_page.dart';
import 'package:word_search_app/gamemodes/gamemode.dart';
import 'package:word_search_app/large_common_button.dart';
import 'package:word_search_app/navigation.dart';
import 'package:word_search_app/pages/home_page.dart';
import 'package:word_search_app/pages/word_search_page.dart';

Future<void> showSolvedPuzzleDialog(BuildContext context, Gamemode currentGamemode) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
            return SimpleDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                contentPadding: EdgeInsets.all(10),
                titlePadding: EdgeInsets.all(15) + EdgeInsets.only(bottom: 10),
                title: Text('Puzzle Completed',
                    textAlign: TextAlign.center,
                ),
                children: [
                    Column(
                        spacing: 6,
                        children: [
                            LargeCommonButton(
                                onPressed: () {
                                    clearHistoryAndNavigateToPage(context, BannerAdPage(child: WordSearchPage(gamemode: currentGamemode)));
                                },
                                child: Row(
                                    children: [
                                        Flexible(
                                            child: Text('Next Puzzle')
                                        )
                                    ]
                                )
                            ),
                            LargeCommonButton(
                                onPressed: () {
                                    clearHistoryAndNavigateToPage(context, const HomePage());
                                },
                                color: Color(0xFFAAAAAA),
                                solid: false,
                                child: Row(
                                    children: [
                                        Flexible(
                                            child: Text('Home')
                                        )
                                    ]
                                )
                            )
                        ]
                    )
                ]
            );
        }
    );
}
