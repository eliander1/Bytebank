import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

final url = Uri.http('192.168.1.12:8080', 'transactions');
Client client = InterceptedClient.build(interceptors: [LoggingInterceptor()],
requestTimeout: Duration(seconds: 5));




