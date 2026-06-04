import 'export_service_base.dart';
import 'export_service_stub.dart'
    if (dart.library.io) 'export_service_io.dart'
    if (dart.library.html) 'export_service_web.dart'
    if (dart.library.js_interop) 'export_service_web.dart'
    as platform_export;

ExportService createExportService() => platform_export.createExportService();
