import 'package:droidcon_app/models/models.dart';
import 'package:droidcon_app/providers/selected_date/selected_date_provider.dart';
import 'package:droidcon_app/providers/sessions/event_dates_provider.dart';
import 'package:droidcon_app/providers/sessions/filtered_sessions_provider.dart';
import 'package:droidcon_app/providers/sessions/sessions_provider.dart';
import 'package:droidcon_app/providers/sessions_display_style/sessions_display_style.dart';
import 'package:droidcon_app/providers/show_favorited_sessions/state/sessions_filter_state.dart';
import 'package:droidcon_app/styles/colors/colors.dart';
import 'package:droidcon_app/user_interfaces/home/sessions/sessions_filter_screen.dart';
import 'package:droidcon_app/user_interfaces/home/sessions/widgets/button_group.dart';
import 'package:droidcon_app/user_interfaces/home/sessions/widgets/session_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/show_favorited_sessions/sessions_filter_provider.dart';
import '../../widgets/afrikon_icon.dart';
import '../../widgets/droidcon_logo.dart';
import 'widgets/droidcon_switch.dart';
import 'widgets/session_cards.dart';

class SessionsPage extends ConsumerWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(eventDatesProvider, (previous, next) {
      final index = next.value
              ?.indexWhere((element) => element.isSameDay(DateTime.now())) ??
          0;
      ref
          .read(selectedDateProvider.notifier)
          .set(next.value?[index > -1 ? index : 0]);
    });
    ref.listen(sessionsFilterProvider, (previous, next) {
      if (![previous, next].contains(SessionsFilterState.bookmarked())) {
        ref.refresh(sessionsProvider);
      }
    });

    AsyncValue<List<Session>> sessions =
        ref.watch(filteredSessionsListProvider);
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const DroidconLogo(),
              const Spacer(),
              IconButton(
                onPressed: () {
                  ref
                      .read(sessionsDisplayStyleProvider.notifier)
                      .set(SessionsDisplayStyle.list);
                },
                icon: AfrikonIcon(
                  'list-alt',
                  color: ref.watch(sessionsDisplayStyleProvider) ==
                          SessionsDisplayStyle.list
                      ? AppColors.blueColor
                      : AppColors.greyTextColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  ref
                      .read(sessionsDisplayStyleProvider.notifier)
                      .set(SessionsDisplayStyle.cards);
                },
                icon: AfrikonIcon(
                  'view-agenda',
                  color: ref.watch(sessionsDisplayStyleProvider) ==
                          SessionsDisplayStyle.cards
                      ? AppColors.blueColor
                      : AppColors.greyTextColor,
                ),
              ),
              TextButton(
                onPressed: ref.watch(sessionsFilterProvider) ==
                        SessionsFilterState.bookmarked()
                    ? null
                    : () async {
                        await showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          transitionDuration: const Duration(milliseconds: 500),
                          barrierLabel:
                              MaterialLocalizations.of(context).dialogLabel,
                          barrierColor: Colors.black.withOpacity(0.5),
                          pageBuilder: (context, _, __) =>
                              SessionsFilterScreen(),
                          transitionBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ).drive(
                                Tween<Offset>(
                                  begin: const Offset(0, -1.0),
                                  end: Offset.zero,
                                ),
                              ),
                              child: child,
                            );
                          },
                        );
                      },
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Row(children: const [
                      Text('Filter'),
                      SizedBox(width: 8),
                      AfrikonIcon('filter-outline'),
                    ]),
                    ref.watch(sessionsFilterProvider).maybeWhen(
                          custom: (filter) => Container(
                            height: 10,
                            width: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.tealColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          orElse: () => const SizedBox(),
                        ),
                  ],
                ),
              )
            ],
          ),
        ),
        body: sessions.when(
          error: (err, stack) {
            debugPrintStack(stackTrace: stack);
            return Center(
                child: Column(
              children: [
                Text('Error: $err'),
                TextButton(
                  onPressed: () {
                    ref.refresh(sessionsProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ));
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          data: (sessions) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ref.watch(eventDatesProvider).when(
                                data: (dates) {
                                  final index = dates.toList().indexWhere(
                                      (date) =>
                                          date ==
                                          ref.watch(selectedDateProvider));

                                  return ButtonGroup(
                                    selectedIndex: index > -1 ? index : 0,
                                    onSelectedIndexChanged: (val) {
                                      ref
                                          .read(selectedDateProvider.notifier)
                                          .set(val);
                                    },
                                    options: dates.toList(),
                                  );
                                },
                                error: (err, stack) {
                                  debugPrintStack(stackTrace: stack);
                                  return Text(err.toString());
                                },
                                loading: () =>
                                    const CircularProgressIndicator()),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    DroidconSwitch(
                                      value:
                                          ref.watch(sessionsFilterProvider) ==
                                              SessionsFilterState.bookmarked(),
                                      onChanged: (val) {
                                        ref
                                            .read(
                                                sessionsFilterProvider.notifier)
                                            .change(val
                                                ? SessionsFilterState
                                                    .bookmarked()
                                                : SessionsFilterState.none());
                                      },
                                    ),
                                    Text(
                                      'My Sessions',
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    ref.watch(sessionsFilterProvider) ==
                            SessionsFilterState.bookmarked()
                        ? 'My sessions'
                        : 'All sessions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  if (ref.watch(sessionsDisplayStyleProvider) ==
                      SessionsDisplayStyle.list)
                    SessionList(list: sessions),
                  if (ref.watch(sessionsDisplayStyleProvider) ==
                      SessionsDisplayStyle.cards)
                    SessionCards(sessions: sessions),
                ],
              ),
            );
          },
        ));
  }
}
