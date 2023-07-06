import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:finlytics/core/database/services/app-data/app_data_service.dart';
import 'package:finlytics/core/database/services/category/category_service.dart';
import 'package:finlytics/core/database/services/user-setting/user_setting_service.dart';
import 'package:finlytics/core/models/account/account.dart';
import 'package:finlytics/core/models/budget/budget.dart';
import 'package:finlytics/core/models/category/category.dart';
import 'package:finlytics/core/models/exchange-rate/exchange_rate.dart';
import 'package:finlytics/core/models/transaction/transaction.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'database_impl.g.dart';

final databaseProvider = Provider<DatabaseImpl>(
  (ref) => DatabaseImpl.instance,
);

@DriftDatabase(include: {
  'sql/initial/tables.drift',
  'sql/initial/data.drift',
  'sql/queries/select-full-data.drift'
})
class DatabaseImpl extends _$DatabaseImpl {
  DatabaseImpl._({
    required this.dbName,
    required this.inMemory,
    required this.logStatements,
  }) : super(_openConnection(dbName, logStatements: logStatements));

  static final DatabaseImpl instance = DatabaseImpl._(
    dbName: 'database.db',
    inMemory: false,
    logStatements: false,
  );

  final String dbName;
  final bool inMemory;
  final bool logStatements;

  Future<String> get databasePath async =>
      join((await getApplicationDocumentsDirectory()).path, dbName);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        print(
            'DB found! Version ${details.versionNow} (previous was ${details.versionBefore}).');

        if (details.wasCreated) {
          print('Executing seeders... Populating the database...');

          try {
            // TODO: The next calls won't work if we call insertInitialCurrencies() here. WHY?!

            // await insertInitialCurrencies();
            await customStatement(
                "INSERT INTO currencies VALUES ('AED', 'dh'), ('AFN', 'Af.'), ('ALL', 'Lek'), ('AMD', 'Dram'), ('ANG', 'ƒ'), ('AOA', 'Kz'), ('ARS', '\$'), ('AUD', '\$'), ('AWG', 'Afl.'), ('AZN', 'man.'), ('BAM', 'KM'), ('BBD', '\$'), ('BDT', '৳'), ('BGN', 'lev'), ('BHD', 'din'), ('BIF', 'FBu'), ('BND', '\$'), ('BOB', 'Bs'), ('BRL', 'R\$'), ('BSD', '\$'), ('BTN', 'Nu.'), ('BWP', 'P'), ('BYR', 'BYR'), ('BZD', '\$'), ('CAD', '\$'), ('CDF', 'FrCD'), ('CHF', 'CHF'), ('CLP', '\$'), ('CNY', '¥'), ('COP', '\$'), ('CRC', '₡'), ('CUP', '\$'), ('CVE', 'CVE'), ('CZK', 'Kč'), ('DJF', 'Fdj'), ('DKK', 'kr'), ('DOP', '\$'), ('DZD', 'din'), ('EGP', 'E£'), ('ERN', 'Nfk'), ('ETB', 'Birr'), ('EUR', '€'), ('FJD', '\$'), ('FKP', '£'), ('GBP', '£'), ('GEL', 'GEL'), ('GHS', 'GHS'), ('GIP', '£'), ('GMD', 'GMD'), ('GNF', 'FG'), ('GTQ', 'Q'), ('HKD', '\$'), ('HNL', 'L'), ('HRK', 'kn'), ('HTG', 'HTG'), ('HUF', 'Ft'), ('IDR', 'Rp'), ('ILS', '₪'), ('INR', '₹'), ('IQD', 'din'), ('IRR', 'Rial'), ('ISK', 'kr'), ('JMD', '\$'), ('JOD', 'din'), ('JPY', '¥'), ('KES', 'Ksh'), ('KGS', 'KGS'), ('KHR', 'Riel'), ('KMF', 'CF'), ('KPW', '₩'), ('KRW', '₩'), ('KWD', 'din'), ('KYD', '\$'), ('KZT', '₸'), ('LAK', '₭'), ('LBP', 'L£'), ('LKR', 'Rs'), ('LRD', '\$'), ('LSL', 'LSL'), ('LYD', 'din'), ('MAD', 'dh'), ('MDL', 'MDL'), ('MGA', 'Ar'), ('MKD', 'din'), ('MMK', 'K'), ('MNT', '₮'), ('MOP', 'MOP'), ('MUR', 'Rs'), ('MVR', 'Rf'), ('MWK', 'MWK'), ('MXN', '\$'), ('MYR', 'RM'), ('MZN', 'MTn'), ('NAD', '\$'), ('NGN', '₦'), ('NIO', 'C\$'), ('NOK', 'kr'), ('NPR', 'Rs'), ('NZD', '\$'), ('OMR', 'Rial'), ('PAB', 'B/.'), ('PEN', 'S/'), ('PGK', 'PGK'), ('PHP', '₱'), ('PKR', 'Rs'), ('PLN', 'zł'), ('PYG', 'Gs'), ('QAR', 'Rial'), ('RON', 'RON'), ('RSD', 'din'), ('RUB', '₽'), ('RWF', 'RF'), ('SAR', 'Riyal'), ('SBD', '\$'), ('SCR', 'SCR'), ('SDG', 'SDG'), ('SEK', 'kr'), ('SGD', '\$'), ('SLL', 'SLL'), ('SOS', 'SOS'), ('SRD', '\$'), ('SSP', 'SSP'), ('STD', 'Db'), ('SVC', '₡'), ('SYP', '£'), ('SZL', 'SZL'), ('THB', '฿'), ('TJS', 'Som'), ('TMT', 'TMT'), ('TND', 'din'), ('TOP', 'T\$'), ('TRY', 'TL'), ('TTD', '\$'), ('TWD', 'NT\$'), ('TZS', 'TSh'), ('UAH', '₴'), ('UGX', 'UGX'), ('USD', '\$'), ('UYU', '\$'), ('UZS', 'soʼm'), ('VEF', 'Bs'), ('VND', '₫'), ('VUV', 'VUV'), ('WST', 'WST'), ('XAF', 'FCFA'), ('XCD', '\$'), ('XOF', 'CFA'), ('XPF', 'FCFP'), ('YER', 'Rial'), ('ZAR', 'R'), ('ZMW', 'ZK'), ('ZWL', '\$')");

            // await insertInitialCurrencyNames();
            await customStatement(
                "INSERT INTO currencyNames (currencyCode, en, es) VALUES ('AED', 'UAE Dirham', 'Dírham de los Emiratos Árabes Unidos'), ('AFN', 'Afghani', 'Afgani'), ('ALL', 'Lek', 'Lek'), ('AMD', 'Armenian Dram', 'Dram armenio'), ('ANG', 'Netherlands Antillian Guilder', 'Florín antillano neerlandés'), ('AOA', 'Kwanza', 'Kwanza'), ('ARS', 'Argentine Peso', 'Peso argentino'), ('AUD', 'Australian Dollar', 'Dólar australiano'), ('AWG', 'Aruban Guilder', 'Florín arubeño'), ('AZN', 'Azerbaijanian Manat', 'Manat azerbaiyano'), ('BAM', 'Convertible Marks', 'Marco convertible'), ('BBD', 'Barbados Dollar', 'Dólar de Barbados'), ('BDT', 'Taka', 'Taka'), ('BGN', 'Bulgarian Lev', 'Lev búlgaro'), ('BHD', 'Bahraini Dinar', 'Dinar bareiní'), ('BIF', 'Burundi Franc', 'Franco de Burundi'), ('BND', 'Brunei Dollar', 'Dólar de Brunéi'), ('BOB', 'Boliviano', 'Boliviano'), ('BRL', 'Brazilian Real', 'Real brasileño'), ('BSD', 'Bahamian Dollar', 'Dólar bahameño'), ('BTN', 'Ngultrum', 'Ngultrum'), ('BWP', 'Pula', 'Pula'), ('BYR', 'Belarussian Ruble', 'Rublo bielorruso'), ('BZD', 'Belize Dollar', 'Dólar beliceño'), ('CAD', 'Canadian Dollar', 'Dólar canadiense'), ('CDF', 'Congolese Franc', 'Franco congoleño'), ('CHF', 'Swiss Franc', 'Franco suizo'), ('CLP', 'Chilean Peso', 'Peso chileno'), ('CNY', 'Chinese Yuan', 'Yuan chino'), ('COP', 'Colombian Peso', 'Peso colombiano'), ('CRC', 'Costa Rican Colon', 'Colón costarricense'), ('CUP', 'Cuban Peso', 'Peso cubano'), ('CVE', 'Cape Verde Escudo', 'Escudo caboverdiano'), ('CZK', 'Czech Koruna', 'Corona checa'), ('DJF', 'Djibouti Franc', 'Franco yibutiano'), ('DKK', 'Danish Krone', 'Corona danesa'), ('DOP', 'Dominican Peso', 'Peso dominicano'), ('DZD', 'Algerian Dinar', 'Dinar argelino'), ('EGP', 'Egyptian Pound', 'Libra egipcia'), ('ERN', 'Nakfa', 'Nakfa'), ('ETB', 'Ethiopian Birr', 'Birr etíope'), ('EUR', 'Euro', 'Euro'), ('FJD', 'Fiji Dollar', 'Dólar fiyiano'), ('FKP', 'Falkland Islands Pound', 'Libra malvinense'), ('GBP', 'Pound Sterling', 'Libra esterlina'), ('GEL', 'Lari', 'Lari'), ('GHS', 'Cedi', 'Cedi ghanés'), ('GIP', 'Gibraltar Pound', 'Libra de Gibraltar'), ('GMD', 'Dalasi', 'Dalasi'), ('GNF', 'Guinea Franc', 'Franco guineano'), ('GTQ', 'Quetzal', 'Quetzal'), ('HKD', 'Hong Kong Dollar', 'Dólar de Hong Kong'), ('HNL', 'Lempira', 'Lempira'), ('HRK', 'Croatian Kuna', 'Kuna'), ('HTG', 'Gourde', 'Gourde'), ('HUF', 'Hungary Forint', 'Forinto'), ('IDR', 'Rupiah', 'Rupia indonesia'), ('ILS', 'Israeli Sheqel', 'Nuevo shéquel israelí'), ('INR', 'Indian Rupee', 'Rupia india'), ('IQD', 'Iraqi Dinar', 'Dinar iraquí'), ('IRR', 'Iranian Rial', 'Rial iraní'), ('ISK', 'Iceland Krona', 'Corona islandesa'), ('JMD', 'Jamaican Dollar', 'Dólar jamaiquino'), ('JOD', 'Jordanian Dinar', 'Dinar jordano'), ('JPY', 'Japan Yen', 'Yen'), ('KES', 'Kenyan Shilling', 'Chelín keniano'), ('KGS', 'Som', 'Som'), ('KHR', 'Riel', 'Riel'), ('KMF', 'Comoro Franc', 'Franco comorense'), ('KPW', 'North Korean Won', 'Won norcoreano'), ('KRW', 'Won', 'Won'), ('KWD', 'Kuwaiti Dinar', 'Dinar kuwaití'), ('KYD', 'Cayman Islands Dollar', 'Dólar de las Islas Caimán'), ('KZT', 'Tenge', 'Tenge'), ('LAK', 'Kip', 'Kip'), ('LBP', 'Lebanese Pound', 'Libra libanesa'), ('LKR', 'Sri Lanka Rupee', 'Rupia de Sri Lanka'), ('LRD', 'Liberian Dollar', 'Dólar liberiano'), ('LSL', 'Loti', 'Loti'), ('LYD', 'Libyan Dinar', 'Dinar libio'), ('MAD', 'Moroccan Dirham', 'Dírham marroquí'), ('MDL', 'Moldovan Leu', 'Leu moldavo'), ('MGA', 'Malagasy Ariary', 'Ariary malgache'), ('MKD', 'Denar', 'Denar'), ('MMK', 'Kyat', 'Kyat'), ('MNT', 'Tugrik', 'Tugrik'), ('MOP', 'Pataca', 'Pataca'), ('MUR', 'Mauritius Rupee', 'Rupia de Mauricio'), ('MVR', 'Rufiyaa', 'Rufiyaa'), ('MWK', 'Kwacha', 'Kwacha'), ('MXN', 'Mexican Peso', 'Peso mexicano'), ('MYR', 'Malaysian Ringgit', 'Ringgit malayo'), ('MZN', 'Metical', 'Metical mozambiqueño'), ('NAD', 'Namibia Dollar', 'Dólar namibio'), ('NGN', 'Naira', 'Naira'), ('NIO', 'Cordoba Oro', 'Córdoba'), ('NOK', 'Norwegian Krone', 'Corona noruega'), ('NPR', 'Nepalese Rupee', 'Rupia nepalí'), ('NZD', 'New Zealand Dollar', 'Dólar neozelandés'), ('OMR', 'Rial Omani', 'Rial omaní'), ('PAB', 'Balboa', 'Balboa'), ('PEN', 'Nuevo Sol', 'Sol'), ('PGK', 'Kina', 'Kina'), ('PHP', 'Philippine Peso', 'Peso filipino'), ('PKR', 'Pakistan Rupee', 'Rupia pakistaní'), ('PLN', 'Polish Zloty', 'Złoty'), ('PYG', 'Guarani', 'Guaraní'), ('QAR', 'Qatari Rial', 'Riyal qatarí'), ('RON', 'New Leu', 'Leu rumano'), ('RSD', 'Serbian Dinar', 'Dinar serbio'), ('RUB', 'Russian Ruble', 'Rublo ruso'), ('RWF', 'Rwanda Franc', 'Franco ruandés'), ('SAR', 'Saudi Riyal', 'Riyal saudí'), ('SBD', 'Solomon Islands Dollar', 'Dólar de las Islas Salomón'), ('SCR', 'Seychelles Rupee', 'Rupia seychelense'), ('SDG', 'Sudanese Pound', 'Dinar sudanés'), ('SEK', 'Swedish Krona', 'Corona sueca'), ('SGD', 'Singapore Dollar', 'Dólar de Singapur'), ('SLL', 'Leone', 'Leone'), ('SOS', 'Somali Shilling', 'Chelín somalí'), ('SRD', 'Surinam Dollar', 'Dólar surinamés'), ('SSP', 'South Sudanese pound', 'Libra sursudanesa'), ('STD', 'Dobra', 'Dobra'), ('SVC', 'Salvadoran Colon', 'Colon Salvadoreño'), ('SYP', 'Syrian Pound', 'Libra siria'), ('SZL', 'Lilangeni', 'Lilangeni'), ('THB', 'Baht', 'Baht'), ('TJS', 'Somoni', 'Somoni tayiko'), ('TMT', 'Manat', 'Manat turcomano'), ('TND', 'Tunisian Dinar', 'Dinar tunecino'), ('TOP', 'Pa´anga', 'Pa´anga'), ('TRY', 'Turkish Lira', 'Lira turca'), ('TTD', 'Trinidad and Tobago Dollar', 'Dólar de Trinidad y Tobago'), ('TWD', 'Taiwan Dollar', 'Nuevo dólar taiwanés'), ('TZS', 'Tanzanian Shilling', 'Chelín tanzano'), ('UAH', 'Hryvnia', 'Grivna'), ('UGX', 'Uganda Shilling', 'Chelín ugandés'), ('USD', 'US Dollar', 'Dólar estadounidense'), ('UYU', 'Peso Uruguayo', 'Peso uruguayo'), ('UZS', 'Uzbekistan Sum', 'Som uzbeko'), ('VEF', 'Bolivar Fuerte', 'Fuerte bolivar'), ('VND', 'Dong', 'Dong vietnamita'), ('VUV', 'Vatu', 'Vatu'), ('WST', 'Tala', 'Tala'), ('XAF', 'CFA Franc', 'Franco CFA de África Central'), ('XCD', 'East Caribbean Dollar', 'Dólar del Caribe Oriental'), ('XOF', 'CFA Franc', 'Franco CFA de África Occidental'), ('XPF', 'CFP Franc', 'Franco CFP'), ('YER', 'Yemeni Rial', 'Rial yemení'), ('ZAR', 'Rand', 'Rand'), ('ZMW', 'Zambian Kwacha', 'Kwacha zambiano'), ('ZWL', 'Zimbabwean dollar', 'Dólar de Zimbawe')");

            // await insertInitialSettings();
            await customStatement(
                "INSERT INTO userSettings VALUES ('avatar', 'man'), ('userName', 'User'), ('appLanguage', null), ('themeMode', 'system')");

            await customStatement(
                "INSERT INTO appData VALUES ('dbVersion', '${schemaVersion.toStringAsFixed(0)}'), ('appVersion', null), ('introSeen', 'false'), ('lastExportDate', null)");

            String defaultCategories = await rootBundle
                .loadString('assets/sql/default_categories.json');

            await CategoryService.instance
                .initializeCategories(jsonDecode(defaultCategories));

            print('Initial data correctly inserted!');
          } catch (e) {
            print('ERROR: $e');
            throw Exception(e);
          }
        }

        await customStatement('PRAGMA foreign_keys = ON');
      },
      onCreate: (m) async {
        print('Creating database tables...');

        await m.createAll(); // create all tables

        print('Database tables created!');
      },
    );
  }

  /// Return a WHERE clause expression that is the equivalent to the conjunction of some expressions. If no expressions are passed, the WHERE clause will have no effect.
  Expression<bool> buildExpr(List<Expression<bool>> expressions) {
    if (expressions.isEmpty) return const CustomExpression('(TRUE)');

    Expression<bool> toReturn = expressions.first;

    for (var i = 1; i < expressions.length; i++) {
      final exprToPush = expressions[i];

      toReturn = toReturn & exprToPush;
    }

    return toReturn;
  }
}

LazyDatabase _openConnection(String dbName, {bool logStatements = false}) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(join(dbFolder.path, dbName));
    return NativeDatabase.createBackgroundConnection(file,
        logStatements: logStatements);
  });
}
