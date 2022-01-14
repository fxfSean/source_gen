import 'package:source_gen_example/service/service_annotations.dart';

import 'model.dart';
part 'repository.g.dart';

@ServiceUseCase()
abstract class DeviceTrafficRepository {

  Future<AddOrderBody> addOrder(
      String iccid, String pk, String dn, String goodsId);
}
