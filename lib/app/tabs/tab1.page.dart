import 'package:finlytics/app/accounts/account_details.dart';
import 'package:finlytics/app/accounts/account_form.dart';
import 'package:finlytics/app/accounts/all_accounts_balance.dart';
import 'package:finlytics/app/categories/categories_list.dart';
import 'package:finlytics/app/settings/settings.page.dart';
import 'package:finlytics/app/stats/cash_flow.dart';
import 'package:finlytics/app/stats/fund_evolution.dart';
import 'package:finlytics/app/stats/movements_by_categories.dart';
import 'package:finlytics/app/stats/widgets/balance_bar_chart_small.dart';
import 'package:finlytics/app/stats/widgets/chart_by_categories.dart';
import 'package:finlytics/app/stats/widgets/fund_evolution_line_chart.dart';
import 'package:finlytics/app/stats/widgets/incomeOrExpenseCard.dart';
import 'package:finlytics/app/tabs/card_with_header.dart';
import 'package:finlytics/app/tabs/circular_arc.dart';
import 'package:finlytics/app/tabs/tabs.page.dart';
import 'package:finlytics/core/database/services/account/account_service.dart';
import 'package:finlytics/core/database/services/user-setting/user_setting_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/presentation/widgets/currency_displayer.dart';
import 'package:finlytics/core/presentation/widgets/skeleton.dart';
import 'package:finlytics/core/presentation/widgets/trending_value.dart';
import 'package:finlytics/core/services/filters/date_range_service.dart';
import 'package:finlytics/core/services/finance_health_service.dart';
import 'package:finlytics/i18n/translations.g.dart';
import 'package:flutter/material.dart';

import '../../core/presentation/widgets/user_avatar.dart';
import '../transactions/recurrent-transactions.dart';

class Tab1Page extends StatefulWidget {
  const Tab1Page({Key? key}) : super(key: key);

  @override
  State<Tab1Page> createState() => _Tab1PageState();
}

class _Tab1PageState extends State<Tab1Page> {
  final List<Map<String, dynamic>> _tools = [
    {
      'icon': Icons.add_card,
      'label': 'Add acc.',
      'route': const AccountFormPage()
    },
    {
      'icon': Icons.sell_outlined,
      'label': 'Categories',
      'route': const CategoriesList(mode: CategoriesListMode.page)
    },
    {
      'icon': Icons.repeat_rounded,
      'label': 'Trans. recurrents',
      'route': const RecurrentTransactionPage()
    },
    {
      'icon': Icons.settings_outlined,
      'label': 'Settings',
      'route': const SettingsPage()
    },
  ];

  final dateRangeService = DateRangeService();

  late Stream<List<Account>> _accountsStream;

  @override
  void initState() {
    super.initState();

    _accountsStream = AccountService.instance.getAccounts();

    dateRangeService.resetDateRanges();
  }

  Widget buildAccountList(List<Account> accounts) {
    return Builder(
      builder: (context) {
        if (accounts.isEmpty) {
          return Column(
            children: [
              Center(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Aun no hay cuentas creadas',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Empieza a usar toda la magia de Finlytics. Crea al menos una cuenta para empezar a añadir tranacciones.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AccountFormPage())),
                            child: Text('Crear cuenta'))
                      ],
                    )),
              )
            ],
          );
        }

        return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: accounts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return const Divider(indent: 56);
            },
            itemBuilder: (context, index) {
              final account = accounts[index];

              return ListTile(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountDetailsPage(
                              account: account,
                              prevPage: const TabsPage(),
                            ))),
                leading: Hero(
                    tag: 'account-icon-${account.id}',
                    child: account.icon.display(size: 22)),
                trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StreamBuilder(
                          initialData: 0.0,
                          stream: AccountService.instance
                              .getAccountMoney(account: account),
                          builder: (context, snapshot) {
                            return CurrencyDisplayer(
                              amountToConvert: snapshot.data!,
                              currency: account.currency,
                            );
                          }),
                      StreamBuilder(
                          initialData: 0.0,
                          stream: AccountService.instance
                              .getAccountsMoneyVariation(
                                  accounts: [account],
                                  startDate: dateRangeService.startDate,
                                  endDate: dateRangeService.endDate,
                                  convertToPreferredCurrency: false),
                          builder: (context, snapshot) {
                            return TrendingValue(
                              percentage: snapshot.data!,
                              decimalDigits: 0,
                            );
                          }),
                    ]),
                title: Text(account.name),
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final t = Translations.of(context);

    final accountService = AccountService.instance;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsPage()));
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StreamBuilder(
                                    stream: UserSettingService.instance
                                        .getSetting(SettingKey.avatar),
                                    builder: (context, snapshot) {
                                      return UserAvatar(avatar: snapshot.data);
                                    }),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Good evening,',
                                        style: TextStyle(fontSize: 12)),
                                    StreamBuilder(
                                        stream: UserSettingService.instance
                                            .getSetting(SettingKey.userName),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Skeleton(
                                                width: 70, height: 14);
                                          }

                                          return Text(snapshot.data!,
                                              style: const TextStyle(
                                                  fontSize: 18));
                                        }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        ActionChip(
                          onPressed: () {
                            dateRangeService
                                .openDateModal(context)
                                .then((_) => setState(() {}));
                          },
                          label: Text(
                            dateRangeService.selectedDateRange
                                .currentText(context),
                          ),
                          avatar: Icon(
                            Icons.calendar_month,
                            color: colors.onBackground,
                          ),
                        )
                      ]),
                  Divider(
                    height: 32,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  StreamBuilder(
                      stream: accountService.getAccounts(),
                      builder: (context, accounts) {
                        if (!accounts.hasData) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.tabs.tab1.total_balance,
                                  style: const TextStyle(fontSize: 12)),
                              const Skeleton(width: 70, height: 40),
                              const Skeleton(width: 30, height: 14),
                            ],
                          );
                        } else {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.tabs.tab1.total_balance,
                                  style: const TextStyle(fontSize: 12)),
                              StreamBuilder(
                                  stream: accountService.getAccountsMoney(
                                      accountIds:
                                          accounts.data!.map((e) => e.id)),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return CurrencyDisplayer(
                                          amountToConvert: snapshot.data!,
                                          textStyle: const TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.w600));
                                    }

                                    return const Skeleton(
                                        width: 90, height: 40);
                                  }),
                              if (dateRangeService.startDate != null &&
                                  dateRangeService.endDate != null)
                                StreamBuilder(
                                    stream: accountService
                                        .getAccountsMoneyVariation(
                                            accounts: accounts.data!,
                                            startDate:
                                                dateRangeService.startDate,
                                            endDate: dateRangeService.endDate,
                                            convertToPreferredCurrency: true),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Skeleton(
                                            width: 52, height: 22);
                                      }

                                      return TrendingValue(
                                        percentage: snapshot.data!,
                                        filled: true,
                                        fontWeight: FontWeight.bold,
                                        outlined: true,
                                      );
                                    }),
                            ],
                          );
                        }
                      }),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IncomeOrExpenseCard(
                          type: AccountDataFilter.income,
                          startDate: dateRangeService.startDate,
                          endDate: dateRangeService.endDate,
                        ),
                        IncomeOrExpenseCard(
                          type: AccountDataFilter.expense,
                          startDate: dateRangeService.startDate,
                          endDate: dateRangeService.endDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder(
                        stream: _accountsStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CardWithHeader(
                                title: t.general.accounts,
                                body: const LinearProgressIndicator());
                          } else {
                            final accounts = snapshot.data!;

                            return CardWithHeader(
                                title: t.general.accounts,
                                onDetailsClick: accounts.isEmpty
                                    ? null
                                    : () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AllAccountBalancePage()));
                                      },
                                body: buildAccountList(accounts));
                          }
                        }),
                    const SizedBox(
                      height: 16,
                    ),
                    CardWithHeader(
                      title: t.financial_health.display,
                      body: StreamBuilder(
                          stream: accountService.getAccounts(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const LinearProgressIndicator();
                            }

                            final accounts = snapshot.data!;

                            return Padding(
                                padding: const EdgeInsets.all(16),
                                child: StreamBuilder(
                                    stream: FinanceHealthService()
                                        .getHealthyValue(
                                            accounts: accounts,
                                            startDate:
                                                dateRangeService.startDate,
                                            endDate: dateRangeService.endDate),
                                    builder: (context, snapshot) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (snapshot.hasData)
                                            Flexible(
                                                flex: 3,
                                                child: Text(
                                                    'Genial! Tu salud financiera es buena. Visita la pestaña de análisis para ver como ahorrar aun mas!')),
                                          if (!snapshot.hasData)
                                            const Column(
                                              children: [
                                                Skeleton(width: 50, height: 12),
                                                Skeleton(width: 50, height: 12),
                                                Skeleton(width: 50, height: 12),
                                                Skeleton(width: 50, height: 12),
                                              ],
                                            ),
                                          const SizedBox(width: 24),
                                          if (snapshot.hasData)
                                            Flexible(
                                                flex: 2,
                                                child: LayoutBuilder(builder:
                                                    (context, constraints) {
                                                  return CircularArc(
                                                    color: HSLColor.fromAHSL(
                                                            1,
                                                            snapshot.data!,
                                                            1,
                                                            0.35)
                                                        .toColor(),
                                                    value: snapshot.data! / 100,
                                                    width: constraints.maxWidth,
                                                  );
                                                }))
                                        ],
                                      );
                                    }));
                          }),
                    ),
                    const SizedBox(height: 16),
                    CardWithHeader(
                        title: 'Tendencia de saldo',
                        body: FundEvolutionLineChart(
                          startDate: dateRangeService.startDate,
                          endDate: dateRangeService.endDate,
                        ),
                        onDetailsClick: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const FundEvolutionPage()));
                        }),
                    const SizedBox(height: 16),
                    CardWithHeader(
                        title: 'Por categorías',
                        body: ChartByCategories(
                          startDate: dateRangeService.startDate,
                          endDate: dateRangeService.endDate,
                        ),
                        onDetailsClick: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const MovementsByCategoryPage()));
                        }),
                    const SizedBox(height: 16),
                    CardWithHeader(
                        title: 'Flujo de fondos',
                        body: Padding(
                          padding: const EdgeInsets.only(
                              top: 16, left: 16, right: 16),
                          child: BalanceChartSmall(
                              dateRangeService: dateRangeService),
                        ),
                        onDetailsClick: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CashFlowPage()));
                        }),
                    const SizedBox(height: 16),
                    CardWithHeader(
                      title: 'Enlaces rápidos',
                      body: GridView.count(
                        primary: false,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 8,
                        crossAxisCount: 4,
                        children: _tools
                            .map((item) => Column(
                                  children: [
                                    IconButton.filledTonal(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      item['route']));
                                        },
                                        icon: Icon(
                                          item['icon'],
                                          size: 32,
                                          color: Theme.of(context).primaryColor,
                                        )),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['label'],
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300),
                                    )
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 85)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
