import 'dart:typed_data';

import 'package:datatable_export/sampleModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'DealerDataGridSource.dart';

import 'helper/save_file_mobile.dart'
if (dart.library.html) 'helper/save_file_web.dart' as helper;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;



class Home extends SampleView {
  /// Create data grid with editing.
  const Home({Key? key}) : super(key: key);

  @override
  _ExportingDataGridState createState() => _ExportingDataGridState();
}

class _ExportingDataGridState extends SampleViewState {
  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();
  late DealerDataGridSource dataGridSource;

  @override
  void initState() {
    super.initState();

    dataGridSource = DealerDataGridSource(model);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dataGridSource.sampleModel = model;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildExportingButtons(),
        _buildDataGrid(context),
      ],
    );
  }

  Widget _buildExportingButtons() {
    Future<void> exportDataGridToExcel() async {
      final Workbook workbook = _key.currentState!.exportToExcelWorkbook(
          cellExport: (DataGridCellExcelExportDetails details) {
            if (details.cellType == DataGridExportCellType.columnHeader) {
              final bool isRightAlign = details.columnName == 'Product No' ||
                  details.columnName == 'Shipped Date' ||
                  details.columnName == 'Price';
              details.excelRange.cellStyle.hAlign =
              isRightAlign ? HAlignType.right : HAlignType.left;
            }
          });
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, 'DataGrid.xlsx');
    }

    Future<void> exportDataGridToPdf() async {

      final PdfDocument document = _key.currentState!.exportToPdfDocument(
          fitAllColumnsInOnePage: true,
          cellExport: (DataGridCellPdfExportDetails details) {
            if (details.cellType == DataGridExportCellType.row) {
              if (details.columnName == 'Shipped Date') {
                details.pdfCell.value = DateFormat('MM/dd/yyyy')
                    .format(DateTime.parse(details.pdfCell.value));
              }
            }
          },
          headerFooterExport: (DataGridPdfHeaderFooterExportDetails details) {
            final double width = details.pdfPage.getClientSize().width;
            final PdfPageTemplateElement header =
            PdfPageTemplateElement(Rect.fromLTWH(0, 0, width, 65));

            header.graphics.drawString(
              'Product Details',
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, 'DataGrid.pdf');
      document.dispose();
    }

    return Row(
      children: <Widget>[
        _buildExportingButton('Export to Excel', 'images/ExcelExport.png',
            onPressed: exportDataGridToExcel),
        _buildExportingButton('Export to PDF', 'images/PdfExport.png',
            onPressed: exportDataGridToPdf)
      ],
    );
  }

  Widget _buildDataGrid(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(
                    color: const Color.fromRGBO(0, 0, 0, 0.26)

                ))),
        child: SfDataGrid(
          key: _key,
          source: dataGridSource,
          columnWidthMode:  ColumnWidthMode.fill,
          columns: <GridColumn>[
            GridColumn(
                columnName: 'Product No',
                width: 110,
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'Product No',
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            GridColumn(
                columnName: 'Dealer Name',
                width: 110,
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Dealer Name',
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            GridColumn(
                columnName: 'Shipped Date',
                width:  110,
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'Shipped Date',
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            GridColumn(
                columnName: 'Ship Country',
                width: 110,
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Ship Country',
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            GridColumn(
                columnName: 'Ship City',
                width:  110,
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Ship City',
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            GridColumn(
                columnName: 'Price',
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'Price',
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildExportingButton(String buttonName, String imagePath,
      {required VoidCallback onPressed}) {
    return Container(
      height: 60.0,
      padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
      child: MaterialButton(
        onPressed: onPressed,
        color: model.backgroundColor,
        child: SizedBox(
          width: 150.0,
          height: 40.0,
          child: Row(
            children: <Widget>[

              Text(buttonName, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}


abstract class SampleView extends StatefulWidget {
  const SampleView({Key? key}) : super(key: key);
}

abstract class SampleViewState<T extends SampleView> extends State<T> {
  late SampleModel model;

  late bool isCardView;

  @override
  void initState() {
    model = SampleModel.instance;
    isCardView = model.isCardView && !model.isWebFullView;
    super.initState();
  }

  /// Must call super.
  @override
  void dispose() {
    model.isCardView = true;
    super.dispose();
  }

  /// Get the settings panel content.
  Widget? buildSettings(BuildContext context) {
    return null;
  }
}


class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  /// Creates a key to the `SfDataGridState` to access its methods.
  final GlobalKey<SfDataGridState> _key = GlobalKey<SfDataGridState>();

  /// DataGridSource of [SfDataGrid]
  late DealerDataGridSource dataGridSource;

  /// Determine to decide whether the device in landscape or in portrait.
  late bool isLandscapeInMobileView;

  /// Help to identify the desktop or mobile.
  late bool isWebOrDesktop;
  late SampleModel model;

  @override
  void initState() {
    super.initState();
    isWebOrDesktop = model.isWeb || model.isDesktop;
    dataGridSource = DealerDataGridSource(model);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dataGridSource.sampleModel = model;
    isLandscapeInMobileView = !isWebOrDesktop &&
        MediaQuery.of(context).orientation == Orientation.landscape;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildExportingButtons(),
        _buildDataGrid(context),
      ],
    );
  }

  Widget _buildExportingButtons() {
    Future<void> exportDataGridToExcel() async {
      final Workbook workbook = _key.currentState!.exportToExcelWorkbook(
          cellExport: (DataGridCellExcelExportDetails details) {
            if (details.cellType == DataGridExportCellType.columnHeader) {
              final bool isRightAlign = details.columnName == 'Product No' ||
                  details.columnName == 'Shipped Date' ||
                  details.columnName == 'Price';
              details.excelRange.cellStyle.hAlign =
              isRightAlign ? HAlignType.right : HAlignType.left;
            }
          });
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, 'DataGrid.xlsx');
    }

    Future<void> exportDataGridToPdf() async {

      final PdfDocument document = _key.currentState!.exportToPdfDocument(
          fitAllColumnsInOnePage: true,
          cellExport: (DataGridCellPdfExportDetails details) {
            if (details.cellType == DataGridExportCellType.row) {
              if (details.columnName == 'Shipped Date') {
                details.pdfCell.value = DateFormat('MM/dd/yyyy')
                    .format(DateTime.parse(details.pdfCell.value));
              }
            }
          },
          headerFooterExport: (DataGridPdfHeaderFooterExportDetails details) {
            final double width = details.pdfPage.getClientSize().width;
            final PdfPageTemplateElement header =
            PdfPageTemplateElement(Rect.fromLTWH(0, 0, width, 65));

            header.graphics.drawString(
              'Product Details',
              PdfStandardFont(PdfFontFamily.helvetica, 13,
                  style: PdfFontStyle.bold),
              bounds: const Rect.fromLTWH(0, 25, 200, 60),
            );

            details.pdfDocumentTemplate.top = header;
          });
      final List<int> bytes = document.saveSync();
      await helper.FileSaveHelper.saveAndLaunchFile(bytes, 'DataGrid.pdf');
      document.dispose();
    }

    return Row(
      children: <Widget>[
        _buildExportingButton('Export to Excel', 'images/ExcelExport.png',
            onPressed: exportDataGridToExcel),
        _buildExportingButton('Export to PDF', 'images/PdfExport.png',
            onPressed: exportDataGridToPdf)
      ],
    );
  }

  Widget _buildDataGrid(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(
                    color: const Color.fromRGBO(0, 0, 0, 0.26)

                ))),
        child: SfDataGrid(
          key: _key,
          source: dataGridSource,
          columnWidthMode: isWebOrDesktop
              ? (isWebOrDesktop && model.isMobileResolution)
              ? ColumnWidthMode.none
              : ColumnWidthMode.fill
              : isLandscapeInMobileView
              ? ColumnWidthMode.fill
              : ColumnWidthMode.none,
          columns: <GridColumn>[
            GridColumn(
                columnName: 'Product No',
                width: isWebOrDesktop ? double.nan : 110,
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'Product No',
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            GridColumn(
                columnName: 'Dealer Name',
                width: isWebOrDesktop ? double.nan : 110,
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Dealer Name',
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            GridColumn(
                columnName: 'Shipped Date',
                width: isWebOrDesktop ? double.nan : 110,
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'Shipped Date',
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            GridColumn(
                columnName: 'Ship Country',
                width: isWebOrDesktop ? double.nan : 110,
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Ship Country',
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            GridColumn(
                columnName: 'Ship City',
                width: isWebOrDesktop ? double.nan : 110,
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Ship City',
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            GridColumn(
                columnName: 'Price',
                label: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'Price',
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildExportingButton(String buttonName, String imagePath,
      {required VoidCallback onPressed}) {
    return Container(
      height: 60.0,
      padding: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
      child: MaterialButton(
        onPressed: onPressed,
        color: model.backgroundColor,
        child: SizedBox(
          width: 150.0,
          height: 40.0,
          child: Row(
            children: <Widget>[

              Text(buttonName, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
