

import 'package:retrofit/http.dart';
part 'retrofit.g.dart';

@RestApi()
abstract class DeviceTrafficHttpApi {

  ///添加订单
  @GET('/v1/gateway/iot/add_order')
  Future<String> addOrder(@Query('iccid') String param);
}