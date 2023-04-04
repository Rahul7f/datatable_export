import 'dart:math';

import 'package:collection/collection.dart';
import 'package:datatable_export/sampleModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'Dealer.dart';

/// Set dealer's data collection to data grid source.
class DealerDataGridSource extends DataGridSource {
  /// Creates the dealer data source class with required details.
  DealerDataGridSource(this.sampleModel) {
    textStyle =  const TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: Color.fromRGBO(255, 255, 255, 1));
    dealers = _getDealerDetails(100);
    buildDataGridRows();
  }

  /// Helps to change the widget appearance based on the sample browser theme.
  SampleModel sampleModel;

  /// Collection of dealer info.
  late List<Dealer> dealers;

  /// Collection of [DataGridRow].
  late List<DataGridRow> dataGridRows;

  /// Helps to change the [TextStyle] of editable widget.
  /// Decide the text appearance of editable widget based on [Brightness].
  late TextStyle textStyle;

  /// Help to generate the random number.
  Random random = Random();

  /// Help to control the editable text in [TextField] widget.
  TextEditingController editingController = TextEditingController();

  /// Helps to hold the new value of all editable widget.
  /// Based on the new value we will commit the new value into the corresponding
  /// [DataGridCell] on [onSubmitCell] method.
  dynamic newCellValue;

  /// Helps to prevent the multiple time calling of [showDatePicker] when focus
  /// get into it.By default, datagrid sets the focus to editable widget. As
  /// Date picker showing when the container got focused, this flag helps to
  /// prevent to show the date picker again after date is picked from popup.
  bool isDatePickerVisible = false;

  /// Building the [DataGridRow]'s.
  void buildDataGridRows() {
    dataGridRows = dealers
        .map<DataGridRow>((Dealer dealer) => dealer.getDataGridRow())
        .toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((DataGridCell dataGridCell) {
          final bool isRightAlign = dataGridCell.columnName == 'Product No' ||
              dataGridCell.columnName == 'Shipped Date' ||
              dataGridCell.columnName == 'Price';

          String value = dataGridCell.value.toString();

          if (dataGridCell.columnName == 'Price') {
            value = NumberFormat.currency(locale: 'en_US', symbol: r'$')
                .format(dataGridCell.value);
          } else if (dataGridCell.columnName == 'Shipped Date') {
            value = DateFormat('MM/dd/yyyy').format(dataGridCell.value);
          }

          return Container(
            padding: const EdgeInsets.all(8.0),
            alignment: isRightAlign ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList());
  }


  @override
  Future<void> onCellSubmit(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column) async {
    final dynamic oldValue = dataGridRow
        .getCells()
        .firstWhereOrNull((DataGridCell dataGridCell) =>
    dataGridCell.columnName == column.columnName)
        ?.value ??
        '';

    final int dataRowIndex = dataGridRows.indexOf(dataGridRow);

    if (newCellValue == null || oldValue == newCellValue) {
      return;
    }

    if (column.columnName == 'Shipped Date') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<DateTime>(
              columnName: 'Shipped Date', value: newCellValue);
      dealers[dataRowIndex].shippedDate = newCellValue as DateTime;
    } else if (column.columnName == 'Product No') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<int>(columnName: 'Product No', value: newCellValue);
      dealers[dataRowIndex].productNo = newCellValue as int;
    } else if (column.columnName == 'Price') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<double>(columnName: 'Price', value: newCellValue);
      dealers[dataRowIndex].productPrice = newCellValue as double;
    } else if (column.columnName == 'Dealer Name') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'Dealer Name', value: newCellValue);
      dealers[dataRowIndex].dealerName = newCellValue.toString();
    } else if (column.columnName == 'Ship Country') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'Ship Country', value: newCellValue);
      final dynamic dataGridCell = dataGridRows[dataRowIndex]
          .getCells()
          .firstWhereOrNull(
              (DataGridCell element) => element.columnName == 'Ship City');
      final int dataCellIndex =
      dataGridRows[dataRowIndex].getCells().indexOf(dataGridCell);
      dataGridRows[dataRowIndex].getCells()[dataCellIndex] =
      const DataGridCell<String>(columnName: 'Ship City', value: '');
      dealers[dataRowIndex].shipCountry = newCellValue.toString();
    } else {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'Ship City', value: newCellValue);
      dealers[dataRowIndex].shipCity = newCellValue.toString();
    }
  }

  RegExp _getRegExp(bool isNumericKeyBoard, String columnName) {
    return isNumericKeyBoard
        ? columnName == 'Price'
        ? RegExp('[0-9.]')
        : RegExp('[0-9]')
        : RegExp('[a-zA-Z ]');
  }



  List<Dealer> _getDealerDetails(int count) {
    final List<Dealer> dealerDetails = <Dealer>[];
    final List<DateTime> shippedDate = getDateBetween(2001, 2016, count);
    for (int i = 1; i <= count; i++) {
      final String selectedShipCountry = _shipCountry[random.nextInt(5)];
      final List<String> selectedShipCities = _shipCity[selectedShipCountry]!;
      final Dealer ord = Dealer(
          _productNo[random.nextInt(15)],
          i.isEven
              ? _customersMale[random.nextInt(15)]
              : _customersFemale[random.nextInt(14)],
          shippedDate[i - 1],
          selectedShipCountry,
          selectedShipCities[random.nextInt(selectedShipCities.length - 1)],
          next(2000, 10000).toDouble());
      dealerDetails.add(ord);
    }

    return dealerDetails;
  }

  /// Helps to populate the random number between the [min] and [max] value.
  int next(int min, int max) => min + random.nextInt(max - min);

  /// Populate the random date between the [startYear] and [endYear]
  List<DateTime> getDateBetween(int startYear, int endYear, int count) {
    final List<DateTime> date = <DateTime>[];
    for (int i = 0; i < count; i++) {
      final int year = next(startYear, endYear);
      final int month = random.nextInt(12);
      final int day = random.nextInt(30);
      date.add(DateTime(year, month, day));
    }

    return date;
  }

  final Map<String, List<String>> _shipCity = <String, List<String>>{
    'Argentina': <String>['Rosario', 'Catamaran', 'Formosa', 'Salta'],
    'Austria': <String>['Graz', 'Salzburg', 'Linz', 'Wels'],
    'Belgium': <String>['Bruxelles', 'Charleroi', 'Namur', 'Mons'],
    'Brazil': <String>[
      'Campinas',
      'Resende',
      'Recife',
      'Manaus',
    ],
    'Canada': <String>[
      'Alberta',
      'Montreal',
      'Tsawwassen',
      'Vancouver',
    ],
    'Denmark': <String>[
      'Svendborg',
      'Farum',
      'Åarhus',
      'København',
    ],
    'Finland': <String>['Helsinki', 'Espoo', 'Oulu'],
    'France': <String>[
      'Lille',
      'Lyon',
      'Marseille',
      'Nantes',
      'Paris',
      'Reims',
      'Strasbourg',
      'Toulouse',
      'Versailles'
    ],
    'Germany': <String>[
      'Aachen',
      'Berlin',
      'Brandenburg',
      'Cunewalde',
      'Frankfurt',
      'Köln',
      'Leipzig',
      'Mannheim',
      'München',
      'Münster',
      'Stuttgart'
    ],
    'Ireland': <String>['Cork', 'Waterford', 'Bray', 'Athlone'],
    'Italy': <String>[
      'Bergamo',
      'Reggio Calabria',
      'Torino',
      'Genoa',
    ],
    'Mexico': <String>[
      'Mexico City',
      'Puebla',
      'León',
      'Zapopan',
    ],
    'Norway': <String>['Stavern', 'Hamar', 'Harstad', 'Narvik'],
    'Poland': <String>['Warszawa', 'Gdynia', 'Rybnik', 'Legnica'],
    'Portugal': <String>['Lisboa', 'Albufeira', 'Elvas', 'Estremoz'],
    'Spain': <String>[
      'Barcelona',
      'Madrid',
      'Sevilla',
      'Bilboa',
    ],
    'Sweden': <String>['Bräcke', 'Piteå', 'Robertsfors', 'Luleå'],
    'Switzerland': <String>[
      'Bern',
      'Genève',
      'Charrat',
      'Châtillens',
    ],
    'UK': <String>['Colchester', 'Hedge End', 'London', 'Bristol'],
    'USA': <String>[
      'Albuquerque',
      'Anchorage',
      'Boise',
      'Butte',
      'Elgin',
      'Eugene',
      'Kirkland',
      'Lander',
      'Portland',
      'San Francisco',
      'Seattle',
    ],
    'Venezuela': <String>[
      'Barquisimeto',
      'Caracas',
      'Isla de Margarita',
      'San Cristóbal',
      'Cantaura',
    ],
  };

  final List<String> _customersMale = <String>[
    'Adams',
    'Owens',
    'Thomas',
    'Doran',
    'Jefferson',
    'Spencer',
    'Vargas',
    'Grimes',
    'Edwards',
    'Stark',
    'Cruise',
    'Fitz',
    'Chief',
    'Blanc',
    'Stone',
    'Williams',
    'Jobs',
    'Holmes'
  ];

  final List<String> _customersFemale = <String>[
    'Crowley',
    'Waddell',
    'Irvine',
    'Keefe',
    'Ellis',
    'Gable',
    'Mendoza',
    'Rooney',
    'Lane',
    'Landry',
    'Perry',
    'Perez',
    'Newberry',
    'Betts',
    'Fitzgerald',
  ];

  final List<int> _productNo = <int>[
    1803,
    1345,
    4523,
    4932,
    9475,
    5243,
    4263,
    2435,
    3527,
    3634,
    2523,
    3652,
    3524,
    6532,
    2123
  ];

  final List<String> _shipCountry = <String>[
    'Argentina',
    'Austria',
    'Belgium',
    'Brazil',
    'Canada',
    'Denmark',
    'Finland',
    'France',
    'Germany',
    'Ireland',
    'Italy',
    'Mexico',
    'Norway',
    'Poland',
    'Portugal',
    'Spain',
    'Sweden',
    'UK',
    'USA',
  ];
}
